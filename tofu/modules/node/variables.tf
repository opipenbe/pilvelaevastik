variable "vms" {
  description = "Map of VMs to deploy"
  type = map(object({
    # Kubernetes settings
    kubernetes = optional(object({
      infra_node = optional(bool, false)
    }))
  }))
}