terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

resource "talos_machine_secrets" "talos" {
  #talos_version    = var.talos_version
}

## Loop machines with control-plane variable
locals {
  vms_talos_role_cp = {
    for name, vm in var.vms :
    name => vm
    if try(vm.talos.node_role, "") == "control-plane"
  }
}

## Loop machines with worker variable
locals {
  vms_talos_role_worker = {
    for name, vm in var.vms :
    name => vm
    if try(vm.talos.node_role, "") == "worker"
  }
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.talos_k8s_cluster_name
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoints            =  [for cp in local.vms_talos_role_cp : cp.ip]
}

data "talos_machine_configuration" "controller" {
  for_each         = local.vms_talos_role_cp
  cluster_name     = var.talos_k8s_cluster_name
  cluster_endpoint = var.talos_k8s_cluster_endpoint
  machine_secrets  = talos_machine_secrets.talos.machine_secrets
  machine_type     = "controlplane"
  talos_version    = var.talos_version
  kubernetes_version = var.k8s_version
  config_patches = [
    # Patch to configure the control plane disk
    templatefile("${path.root}/modules/talos/templates/control-plane-disk-patch.yaml", {
      root_disk_size = each.value.root_disk_size
    }),
    templatefile("${path.root}/modules/talos/templates/network-config.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/l2-vip-config.yaml", {
      talos_k8s_cluster_vip = var.talos_k8s_cluster_vip
    }),
    templatefile("${path.root}/modules/talos/templates/flannel-cni-config.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/time-server-conf.yaml", {
      ntp_servers = [for key, value in each.value.ntp_servers : value]
    }),
    templatefile("${path.root}/modules/talos/templates/kube-api-server-config.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/admission-control-config.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/kube-proxy.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/unattended-install-config.yaml", {
      image = each.value.talos.talos_image != null ? each.value.talos.talos_image : var.talos_image
    }),
    templatefile("${path.root}/modules/talos/templates/cp-kubelet-config.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/cp-sysctls.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/hostname.yaml", {
      hostname = each.key
    }),
    templatefile("${path.root}/modules/talos/templates/kube-node-config.yaml", {
      labels   = { for key, value in each.value.labels : key => value }
      infra_node = false
    }),
    templatefile("${path.root}/modules/talos/templates/registry-mirror.yaml", {
      image_registry_mirror = var.image_registry_mirror
    }),
    yamlencode({
      machine = {
        systemDiskEncryption = each.value.talos.enable_systemdisk_encryption ? {
          ephemeral = {
            provider = "luks2"
            keys = [
              {
                slot = 0
                tpm  = {}
              }
            ]
          }
          state = {
            provider = "luks2"
            keys = [
              {
                slot = 0
                tpm  = {}
              }
            ]
          }
        } : null
        features = {
          rbac = true
          kubernetesTalosAPIAccess = {
            enabled = true
            allowedRoles = [
              "os:reader"
            ]
            allowedKubernetesNamespaces = [
              "kube-system"
            ]
          }
        }
      }
    })
  ]
}

data "talos_machine_configuration" "worker" {
  for_each         = local.vms_talos_role_worker
  cluster_name     = var.talos_k8s_cluster_name
  cluster_endpoint = var.talos_k8s_cluster_endpoint
  machine_secrets  = talos_machine_secrets.talos.machine_secrets
  machine_type     = "worker"
  talos_version    = var.talos_version
  kubernetes_version = var.k8s_version
  config_patches = compact([
    templatefile("${path.root}/modules/talos/templates/hostname.yaml", {
      hostname = each.key
    }),
    templatefile("${path.root}/modules/talos/templates/kube-node-config.yaml", {
      labels   = { for key, value in each.value.labels : key => value }
      infra_node = try(each.value.kubernetes.infra_node, false)
    }),
    templatefile("${path.root}/modules/talos/templates/network-config.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/flannel-cni-config.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/time-server-conf.yaml", {
      ntp_servers = [for key, value in each.value.ntp_servers : value]
    }),
    templatefile("${path.root}/modules/talos/templates/unattended-install-config.yaml", {
      image = each.value.talos.talos_image != null ? each.value.talos.talos_image : var.talos_image
    }),
    templatefile("${path.root}/modules/talos/templates/worker-kubelet-config.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/worker-sysctls.yaml", {
    }),
    templatefile("${path.root}/modules/talos/templates/worker-kernel-module.yaml", {
    }),
    # Conditionally include the worker data disk patch
    coalesce(try(each.value.data_disk1_size, null), 0) > 0 ?
    templatefile("${path.root}/modules/talos/templates/worker-disk-patch.yaml", {
      data_disk1_size = coalesce(try(each.value.data_disk1_size, null), 0)
    }) : null,
    templatefile("${path.root}/modules/talos/templates/registry-mirror.yaml", {
      image_registry_mirror = var.image_registry_mirror
    }),
    yamlencode({
      machine = {
        systemDiskEncryption = each.value.talos.enable_systemdisk_encryption ? {
          ephemeral = {
            provider = "luks2"
            keys = [
              {
                slot = 0
                tpm  = {}
              }
            ]
          }
          state = {
            provider = "luks2"
            keys = [
              {
                slot = 0
                tpm  = {}
              }
            ]
          }
        } : null
        features = {
          rbac = true
        }
      }
    })
  ])
}

resource "talos_machine" "cp_config_apply" {
  for_each          = local.vms_talos_role_cp
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration = data.talos_machine_configuration.controller[each.key].machine_configuration
  node      = each.value.ip
  image = each.value.talos.talos_image != null ? each.value.talos.talos_image : var.talos_image
  kubeconfig_wo = talos_cluster_kubeconfig.talos.kubeconfig_raw
  drain_on_upgrade = true
  ignore_kubernetes_upgrade_drift = true
}

resource "talos_machine" "worker_config_apply" {
  for_each          = local.vms_talos_role_worker
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration = data.talos_machine_configuration.worker[each.key].machine_configuration
  node      = each.value.ip
  image = each.value.talos.talos_image != null ? each.value.talos.talos_image : var.talos_image
  kubeconfig_wo = talos_cluster_kubeconfig.talos.kubeconfig_raw
  drain_on_upgrade = true
  ignore_kubernetes_upgrade_drift = true
}


resource "talos_machine_bootstrap" "talos" {
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoint             = values(local.vms_talos_role_cp)[0].ip
  node                 = values(local.vms_talos_role_cp)[0].ip
}


resource "talos_cluster" "this" {
  depends_on           = [talos_machine.cp_config_apply]
  node                 = values(local.vms_talos_role_cp)[0].ip
  control_plane_nodes = [for vm in local.vms_talos_role_cp : vm.ip]
  client_configuration = talos_machine_secrets.talos.client_configuration
  kubernetes_version   = var.k8s_version
}

data "talos_cluster_health" "health" {
  depends_on           = [ talos_machine.cp_config_apply, talos_machine.worker_config_apply ]
  client_configuration = talos_machine_secrets.talos.client_configuration
  control_plane_nodes = [for vm in local.vms_talos_role_cp : vm.ip]
  endpoints            = [for vm in local.vms_talos_role_cp : vm.ip]
  skip_kubernetes_checks = true
  timeouts = {
    read = "5m"
  }
}

resource "talos_cluster_kubeconfig" "talos" {
  client_configuration = talos_machine_secrets.talos.client_configuration
  node                 = values(local.vms_talos_role_cp)[0].ip
  depends_on = [
    talos_machine_bootstrap.talos
  ]
}

resource "local_file" "kubeconfig" {
  filename = "${pathexpand("~")}/.kube/config"
  content  = talos_cluster_kubeconfig.talos.kubeconfig_raw
}

resource "local_file" "talosconfig" {
  filename = "${pathexpand("~")}/.talos/config"
  content  = data.talos_client_configuration.talosconfig.talos_config
}

resource "time_sleep" "bootstrap_wait_90_seconds" {
  create_duration = "90s"
  depends_on = [ data.talos_cluster_health.health ]
}
