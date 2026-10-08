# Week 1 environment: wires the network, security and compute modules together.

# Fixed host addresses are expressed as offsets inside each private CIDR,
# so the public code never contains the real internal ranges.
locals {
  edge_mgmt_ip = cidrhost(var.mgmt_cidr, 10)
}

module "network" {
  source = "../modules/network"

  name_prefix           = var.name_prefix
  external_network_name = var.external_network_name
  mgmt_cidr             = var.mgmt_cidr
  k8s_cidr              = var.k8s_cidr
  vpn_cidr              = var.vpn_cidr
  vpn_gateway_ip        = local.edge_mgmt_ip
  dns_nameservers       = var.dns_nameservers
}
