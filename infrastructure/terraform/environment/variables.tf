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

variable "bootstrap_ssh_cidrs" {
  description = "TEMPORARY public SSH sources for edge-01 (e.g. team members' /32s). Set to [] after WireGuard is proven."
  type        = list(string)
}

variable "wireguard_port" {
  description = "UDP port WireGuard listens on at edge-01."
  type        = number
  default     = 51820
}

variable "image_id" {
  description = "Rocky 9 image ID (from openstack image list). Real value only in private terraform.tfvars."
  type        = string
}

variable "flavor_ids" {
  description = "Flavor IDs per role (IDs, not names - see week1 README step 3)."
  type = object({
    edge          = string
    api_lb        = string
    control_plane = string
    worker        = string
  })
}

variable "ssh_public_keys" {
  description = "Public SSH keys installed at first boot. Further team keys are managed by Ansible."
  type        = list(string)
}
