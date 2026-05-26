variable "sops_key" {
  description = "Private key for SOPS"
  type        = string
  sensitive   = true
}

variable "cilium_peer_router_asn" {
  type        = string
  description = "ASN for peer router"
}

variable "cilium_peer_router_ip" {
  type        = string
  description = "Peer router IP, usually it is also a gateway"
}

variable "k8s_host_network" {
  type        = string
  description = "CIDR for Kubernetes host network"
}

variable "mgmt_network" {
  type        = string
  description = "CIDR for management network"
}

variable "talos_k8s_cluster_vip" {
  type        = string
  description = "VIP to connect to the Kubernetes cluster"
}

variable "flux_version" {
  type        = string
  description = "Version of FluxCD to deploy"
}

variable "flux_bootstrap_path" {
  type        = string
  description = "Path within the Git repository for FluxCD bootstrap"
}
