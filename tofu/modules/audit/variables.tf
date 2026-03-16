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

variable "controller_machine_configuration" {
  description = "The Talos controller machine configuration data"
  type        = map(any)
}

variable "worker_machine_configuration" {
  description = "The Talos worker machine configuration data"
  type        = map(any)
}
