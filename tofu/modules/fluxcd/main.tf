terraform {
  required_providers {
    flux = {
      source = "fluxcd/flux"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "flux_bootstrap_git" "this" {
  path               = "clusters/live"
  version = "v2.8.3"
  kustomization_override = file("${path.root}/modules/fluxcd/templates/kustomization.yaml")
}

resource "kubernetes_secret_v1" "sops_key" {
  metadata {
    name      = "sops-age"
    namespace = "flux-system"
  }

  data = {
    "age.agekey" = var.sops_key
  }
  depends_on = [ flux_bootstrap_git.this ]
}

resource "kubernetes_config_map_v1" "cilium-kustomization" {
  metadata {
    name      = "cilium-kustomization"
    namespace = "flux-system"
  }
  data = {
    CILIUM_PEER_ROUTER_IP = "${var.cilium_peer_router_ip}"
    CILIUM_PEER_ROUTER_ASN = "${var.cilium_peer_router_asn}"
    K8S_HOST_NETWORK = "${var.k8s_host_network}"
    MGMT_NETWORK = "${var.mgmt_network}"
  }
  depends_on = [ flux_bootstrap_git.this ]
}
