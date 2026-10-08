variable "name_prefix" {
  description = "Prefix for all network resource names, e.g. the team name."
  type        = string
}

variable "external_network_name" {
  description = "Name of the provider external network (discovered with: openstack network list --external)."
  type        = string
}

variable "mgmt_cidr" {
  description = "Instructor/team-assigned CIDR for the management network (edge-01). Real value kept in private tfvars."
  type        = string
}

variable "k8s_cidr" {
  description = "Instructor/team-assigned CIDR for the Kubernetes network. Real value kept in private tfvars."
  type        = string
}

variable "vpn_cidr" {
  description = "WireGuard client CIDR. The router needs a return route for it via edge-01."
  type        = string
}

variable "vpn_gateway_ip" {
  description = "Fixed management IP of edge-01; next hop for the VPN return route."
  type        = string
}

variable "dns_nameservers" {
  description = "DNS resolvers handed out by DHCP during bootstrap (before Pi-hole takes over)."
  type        = list(string)
  default     = []
}
