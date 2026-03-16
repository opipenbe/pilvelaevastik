variable "vms" {
  description = "Map of VMs to deploy"
  type = map(object({
    memory = optional(number)
    cpus = optional(number)
    ip = optional(string)
    network_cidr = optional(number)
    dns_server1 = optional(string)
    dns_server2 = optional(string)
    gw_ip = optional(string)
    root_disk_size = optional(number)
    data_disk1_size = optional(number)
    cpu_hot_add_enabled = optional(bool, false)
    memory_hot_add_enabled = optional(bool, false)
    labels = optional(map(string))
    # PVE settings
    pve = optional(object({
      node_name = optional(string)
      vm_storage   = optional(string)
      template_storage = optional(string)
    }))
  }))
}

variable "talos_image" {
  type        = string
  description = "image for Talos OS"
}