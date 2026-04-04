module "pve" {
  source = "./modules/pve"
  vms = var.vms
  talos_image = var.talos_image
}

module "talos" {
  source = "./modules/talos"
  talos_k8s_cluster_name = var.talos_k8s_cluster_name
  talos_k8s_cluster_endpoint = var.talos_k8s_cluster_endpoint
  talos_k8s_cluster_vip = var.talos_k8s_cluster_vip
  talos_version = var.talos_version
  image_registry_mirror = var.image_registry_mirror
  k8s_version = var.k8s_version
  talos_image = var.talos_image
  vms = var.vms
  depends_on = [module.pve]
}

module "node" {
  source = "./modules/node"
  vms = var.vms
  depends_on = [module.talos]
}

module "cilium" {
  source = "./modules/cilium"
  talos_k8s_cluster_name = var.talos_k8s_cluster_name
  cilium_version = var.cilium_version
  cilium_peer_router_ip = var.cilium_peer_router_ip
  cilium_peer_router_asn = var.cilium_peer_router_asn
  depends_on = [module.node]
}

module "fluxcd" {
  source = "./modules/fluxcd"
  sops_key = var.sops_key
  cilium_peer_router_ip = var.cilium_peer_router_ip
  cilium_peer_router_asn = var.cilium_peer_router_asn
  k8s_host_network = var.k8s_host_network
  mgmt_network = var.mgmt_network
  talos_k8s_cluster_vip = var.talos_k8s_cluster_vip
  depends_on = [module.cilium]
}

module "audit" {
  source = "./modules/audit"
  controller_machine_configuration = module.talos.machine_config_controller
  worker_machine_configuration = module.talos.machine_config_worker
  vms = var.vms
  depends_on = [module.fluxcd]
}
