variable "name_prefix" {
  description = "Prefix for security group names."
  type        = string
}

variable "internal_cidrs" {
  description = "Private team ranges (management, Kubernetes, VPN) trusted for host-to-host traffic."
  type        = list(string)
}

variable "bootstrap_ssh_cidrs" {
  description = "TEMPORARY public SSH sources for edge-01. Set to [] once WireGuard is proven (week1 README step 22)."
  type        = list(string)
}

variable "wireguard_port" {
  description = "UDP port WireGuard listens on at edge-01."
  type        = number
  default     = 51820
}

variable "wireguard_source_cidrs" {
  description = "Where WireGuard clients may connect from."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
