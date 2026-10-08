variable "cloud" {
  description = "Name of the cloud entry in each team member's local clouds.yaml (never committed)."
  type        = string
  default     = "openstack"
}

variable "name_prefix" {
  description = "Prefix for OpenStack resource names."
  type        = string
  default     = "purple-teama"
}

variable "external_network_name" {
  description = "Provider external network (from: openstack network list --external)."
  type        = string
}

variable "mgmt_cidr" {
  description = "Management network CIDR (edge-01). Real value only in private terraform.tfvars."
  type        = string
}

variable "k8s_cidr" {
  description = "Kubernetes network CIDR. Real value only in private terraform.tfvars."
  type        = string
}

variable "vpn_cidr" {
  description = "WireGuard client CIDR. Real value only in private terraform.tfvars."
  type        = string
}

variable "dns_nameservers" {
  description = "Bootstrap DNS resolvers handed out by DHCP."
  type        = list(string)
  default     = []
}
