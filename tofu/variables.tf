variable "pve_url" {
  description = "Proxmox endpoint url"
  type        = string
}

variable "vms" {
  description = "Map of VMs to deploy"
  type = map(object({

    # global variables
    admin_pw = optional(string) 
    description = optional(string)
    memory = optional(number)
    cpus = optional(number)
    ip = optional(string)
    dns_server1 = optional(string)
    dns_server2 = optional(string)
    ntp_servers = optional(list(string))
    gw_ip = optional(string)
    network_cidr = optional(number)
    cpu_hot_add_enabled = optional(bool, false)
    memory_hot_add_enabled = optional(bool, false)
    root_disk_size = optional(number)
    data_disk1_size = optional(number)
    labels = optional(map(string))

    # PVE settings
    pve = optional(object({
      node_name        = optional(string)
      vm_storage       = optional(string)
      template_storage = optional(string)
    }))

    ## Talos-specific settings
    talos = optional(object({
      node_role             = optional(string)
      enable_systemdisk_encryption = optional(bool, false)
    }))

    # Kubernetes settings
    kubernetes = optional(object({
      infra_node = optional(bool, false)
    }))
  }))
}
### TOFU ###
variable "tofu_s3_backend_bucket" {
  type        = string
  description = "S3 bucket name for Terraform state storage"
}

variable "tofu_s3_backend_key" {
  type        = string
  description = "S3 key for Terraform state file"
}

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
  description = "URL for the Kubernetes API e.g. https://VIP:6443"
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

variable "k8s_host_network" {
  type        = string
  description = "CIDR for Kubernetes host network"
}

variable "mgmt_network" {
  type        = string
  description = "CIDR for management network"
}
variable "talos_image" {
  type        = string
  description = "image for Talos OS"
}

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

variable "git_pat_token" {
  type        = string
  sensitive  = true
  description = "Git Personal Access Token for the Git repository"
}

variable "sops_key" {
  description = "Private key for SOPS"
  type        = string
  sensitive   = true
}

variable "git_repo" {
  type        = string
  description = "Git repository URL for FluxCD to sync with"
}
