variable "image_id" {
  description = "Glance image ID (discovered, not guessed). Real value in private tfvars."
  type        = string
}

variable "hosts" {
  description = "Hosts to create, keyed by hostname."
  type = map(object({
    flavor_id          = string
    network            = string # key into network_ids / subnet_ids, e.g. "mgmt" or "k8s"
    fixed_ip           = string
    security_group_ids = list(string)
    public             = optional(bool, false)
    allowed_cidrs      = optional(list(string), []) # extra source ranges this port may send from
  }))
}

variable "network_ids" {
  description = "Map of network key => network ID."
  type        = map(string)
}

variable "subnet_ids" {
  description = "Map of network key => subnet ID."
  type        = map(string)
}

variable "floating_ip_pool" {
  description = "External network name used as the floating IP pool."
  type        = string
}

variable "ssh_public_keys" {
  description = "Public keys of every team member, installed for the image's default user on first boot."
  type        = list(string)
}
