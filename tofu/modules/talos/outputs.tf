output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.talos.kubeconfig_raw
  sensitive = true
}

output "kubernetes_client_configuration" {
  value     = talos_cluster_kubeconfig.talos.kubernetes_client_configuration
  sensitive = true
}

output "machine_config_controller" {
  value = data.talos_machine_configuration.controller
}

output "machine_config_worker" {
  value = data.talos_machine_configuration.worker
  sensitive = true
}

output "talos_k8s_cluster_vip" {
  value = var.talos_k8s_cluster_vip
  sensitive = true
}

output "talos_image" {
  value = var.talos_image
}

output "k8s_version" {
  value = var.k8s_version
}