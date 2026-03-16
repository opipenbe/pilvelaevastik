#### TALOS ###
variable "talos_k8s_cluster_name" {
  type        = string
  description = "Kubernetes cluster name"
}

variable "talos_k8s_cluster_vip" {
  type        = string
  description = "VIP to connect to the Kubernetes cluster"
}

variable "talos_k8s_cluster_endpoint" {
  type        = string
  description = "URL for the Kubernetes API e.g. https://server.yourdomain.tld:6443 or https://VIP:6443"
}

variable "talos_image" {
  type        = string
  description = "image for Talos OS"
}

variable "talos_version" {
  type        = string
  description = "Talos version"
}

variable "image_registry_mirror" {
  type        = string
  description = "Container registry mirror URL"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
}

variable "vms" {
  description = "Map of VMs to deploy"
  type = map(object({
    ip = string
    network_cidr = number
    root_disk_size = number
    data_disk1_size = optional(number)
    labels = optional(map(string))
    ntp_servers = optional(list(string))
    talos = optional(object({
      node_role  = optional(string)
      enable_systemdisk_encryption = optional(bool, false)
    }))
    # Kubernetes settings
    kubernetes = optional(object({
      infra_node = optional(bool, false)
    }))
  }))
}