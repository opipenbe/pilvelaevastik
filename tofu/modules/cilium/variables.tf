variable "cilium_version" {
  type        = string
  description = "Cilium CNI version"
}

variable "cilium_peer_router_asn" {
  type        = string
  description = "ASN for peer router"
}

variable "cilium_peer_router_ip" {
  type        = string
  description = "Peer router IP, usually it is also a gateway"
}

variable "talos_k8s_cluster_name" {
  type        = string
  description = "Kubernetes cluster name"
}
