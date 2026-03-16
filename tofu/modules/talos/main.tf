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
  talos_version    = var.talos_version
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
    templatefile("${path.root}/modules/talos/templates/hostname.yaml", {
      hostname = each.key
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
        time = {
          servers = [
            for key, value in each.value.ntp_servers : value
          ]
        }
        install = {
          disk  = "/dev/sda"
          image = var.talos_image
        }
        nodeLabels = {
          for key, value in each.value.labels : key => value
        }
        network = {
          interfaces = [
            {
              interface = "eth0"
              vip = {
                ip = var.talos_k8s_cluster_vip
              }
            }
          ]
        }
        kubelet = {
          extraArgs = {
            rotate-server-certificates = true
          }
        }
        sysctls = {
          "net.ipv4.conf.all.send_redirects" = "0",
          "net.ipv4.conf.default.send_redirects" = "0",
          "net.ipv4.conf.all.log_martians" = "1",
          "net.ipv4.conf.default.log_martians" = "1",
          "net.ipv4.conf.all.secure_redirects" = "0",
          "net.ipv4.conf.default.secure_redirects" = "0",
          "net.ipv4.conf.all.accept_redirects" = "0",
          "net.ipv4.conf.default.accept_redirects" = "0",
          "net.ipv4.conf.all.accept_source_route" ="0",
          "net.ipv4.conf.default.accept_source_route" = "0",
          "net.ipv4.icmp_echo_ignore_broadcasts" = "1",
          "net.ipv4.icmp_ignore_bogus_error_responses" = "1",
          "net.ipv4.tcp_syncookies" = "1"
        }
        features = {
          rbac = true
          hostDNS = {
            enabled               = true
            resolveMemberNames    = true
          }
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
      cluster = {
        apiServer = {
          admissionControl = [
            {
              name = "PodSecurity"
              configuration = {
                defaults = {
                  enforce = "restricted"
                }
              }
            }
          ],
          extraArgs = {
            "default-not-ready-toleration-seconds"  = "60"
            "default-unreachable-toleration-seconds" = "60"
          }
        },
        network = {
          cni = {
            name = "none"
          }
          podSubnets = ["10.245.0.0/16"]
          serviceSubnets = ["10.96.0.0/12"]
        }
        proxy = {
          disabled = true
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
        time = {
          servers = [
            for key, value in each.value.ntp_servers : value
          ]
        }
        install = {
          disk  = "/dev/sda"
          image = var.talos_image
        }
        nodeLabels = {
          for key, value in each.value.labels : key => value
        }
        features = {
          rbac = true
          hostDNS = {
            enabled               = true
            resolveMemberNames    = true
          }
        }
        kubelet = {
          extraArgs = {
            rotate-server-certificates = true,
          }
          extraMounts = [
            {
              destination = "/var/mnt/longhorn"
              type        = "bind"
              source      = "/var/mnt/longhorn"
              options     = ["bind", "rshared", "rw"]
            }
          ],
          extraConfig = try(each.value.kubernetes.infra_node, false) == true ? {
            registerWithTaints = [
              {
                key    = "node-role.kubernetes.io/infra"
                value  = ""
                effect = "NoSchedule"
              }
            ]
          } : {}
        }
        sysctls = {
          "vm.nr_hugepages"            = "1024"
          "fs.inotify.max_user_watches" = "2099999999"
          "fs.inotify.max_user_instances" = "2099999999"
          "fs.inotify.max_queued_events" = "2099999999",
          "net.ipv4.conf.all.send_redirects" = "0",
          "net.ipv4.conf.default.send_redirects" = "0",
          "net.ipv4.conf.all.log_martians" = "1",
          "net.ipv4.conf.default.log_martians" = "1",
          "net.ipv4.conf.all.secure_redirects" = "0",
          "net.ipv4.conf.default.secure_redirects" = "0",
          "net.ipv4.conf.all.accept_redirects" = "0",
          "net.ipv4.conf.default.accept_redirects" = "0"
          "net.ipv4.conf.all.accept_source_route" ="0",
          "net.ipv4.conf.default.accept_source_route" = "0",
          "net.ipv4.icmp_echo_ignore_broadcasts" = "1",
          "net.ipv4.icmp_ignore_bogus_error_responses" = "1",
          "net.ipv4.tcp_syncookies" = "1"
        }
        kernel = {
          modules = [
            { name = "nvme_tcp" },
            { name = "vfio_pci" },
            { name = "uio_pci_generic" },
            { name = "iscsi_tcp" },
            { name = "configfs" }
          ]
        }
      }
      cluster = {
        network = {
          cni = {
            name = "none"
          }
          podSubnets = ["10.245.0.0/16"]
          serviceSubnets = ["10.96.0.0/12"]
        }
        proxy = {
          disabled = true
        }
      }
    })
  ])
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  for_each          = local.vms_talos_role_cp
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controller[each.key].machine_configuration
  node      = each.value.ip
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  for_each          = local.vms_talos_role_worker
  client_configuration        = talos_machine_secrets.talos.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration
  node      = each.value.ip
}

resource "talos_machine_bootstrap" "talos" {
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoint             = values(local.vms_talos_role_cp)[0].ip
  node                 = values(local.vms_talos_role_cp)[0].ip
}


data "http" "health" {
  url      = "https://${var.talos_k8s_cluster_vip}:6443"
  insecure = true
  retry {
    attempts     = 120
    min_delay_ms = 1000
    max_delay_ms = 1000
  }
}

#data "talos_cluster_health" "health" {
#  depends_on           = [ talos_machine_configuration_apply.cp_config_apply, talos_machine_configuration_apply.worker_config_apply ]
#  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
#  control_plane_nodes  = ["172.16.90.10", "172.16.90.12", "172.16.90.13", "172.16.90.14", "172.16.90.15", "172.16.90.16", "172.16.90.17", "172.16.90.18", "172.16.90.19"]
#  endpoints            = ["172.16.90.10", "172.16.90.12", "172.16.90.13", "172.16.90.14", "172.16.90.15", "172.16.90.16", "172.16.90.17", "172.16.90.18", "172.16.90.19"]
#  skip_kubernetes_checks = true
#}

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
  depends_on = [ data.http.health ]
}
