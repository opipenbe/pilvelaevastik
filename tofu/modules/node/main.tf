terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}


resource "kubernetes_labels" "infra-node" {
  for_each = {
    for vm_name, vm in var.vms :
    vm_name => vm
    if try(vm.kubernetes.infra_node, false) == true
  }
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = split(".", each.key)[0] # Extract shortname
  }
  labels = {
    "node-role.kubernetes.io/infra" = ""
  }
}
