output "kubeconfig" {
  value     = module.talos.kubeconfig
  sensitive = true
}

output "talosconfig" {
  value     = module.talos.talosconfig
  sensitive = true
}

output "kubernetes_client_configuration" {
  value     = module.talos.kubernetes_client_configuration
  sensitive = true
}

output "machine_config_controller" {
  value = module.talos.machine_config_controller
  sensitive = true
}

output "machine_config_worker" {
  value = module.talos.machine_config_worker
  sensitive = true
}

output "talos_k8s_cluster_vip" {
  value = var.talos_k8s_cluster_vip
}

output "talos_image" {
  value = var.talos_image
}

output "k8s_version" {
  value = var.k8s_version
}
