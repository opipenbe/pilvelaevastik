terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "helm_release" "cilium" {
  name       = "cilium"
  namespace = "kube-system"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = var.cilium_version
  timeout = 600
  values = [
    templatefile("${path.root}/modules/cilium/templates/cilium-values.yaml", {
      talos_k8s_cluster_name = lower(var.talos_k8s_cluster_name)
    })
  ]
}
