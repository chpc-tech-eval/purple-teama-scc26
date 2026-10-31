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

module "security" {
  source = "../modules/security"

  name_prefix         = var.name_prefix
  internal_cidrs      = [var.mgmt_cidr, var.k8s_cidr, var.vpn_cidr]
  bootstrap_ssh_cidrs = var.bootstrap_ssh_cidrs
  wireguard_port      = var.wireguard_port
}

# The five-node POC from week1 README section 5.
locals {
  hosts = {
    "edge-01" = {
      flavor_id          = var.flavor_ids.edge
      network            = "mgmt"
      fixed_ip           = local.edge_mgmt_ip
      security_group_ids = [module.security.edge_secgroup_id, module.security.internal_secgroup_id]
      public             = true
      allowed_cidrs      = [var.vpn_cidr]
    }
    "api-lb-01" = {
      flavor_id          = var.flavor_ids.api_lb
      network            = "k8s"
      fixed_ip           = cidrhost(var.k8s_cidr, 10)
      security_group_ids = [module.security.internal_secgroup_id]
    }
    "k8s-cp-01" = {
      flavor_id          = var.flavor_ids.control_plane
      network            = "k8s"
      fixed_ip           = cidrhost(var.k8s_cidr, 11)
      security_group_ids = [module.security.internal_secgroup_id]
    }
    "k8s-worker-01" = {
      flavor_id          = var.flavor_ids.worker
      network            = "k8s"
      fixed_ip           = cidrhost(var.k8s_cidr, 21)
      security_group_ids = [module.security.internal_secgroup_id]
    }
    "k8s-worker-02" = {
      flavor_id          = var.flavor_ids.worker
      network            = "k8s"
      fixed_ip           = cidrhost(var.k8s_cidr, 22)
      security_group_ids = [module.security.internal_secgroup_id]
    }
  }
}

module "compute" {
  source = "../modules/compute"

  image_id         = var.image_id
  hosts            = local.hosts
  floating_ip_pool = module.network.external_network_name
  ssh_public_keys  = var.ssh_public_keys

  network_ids = {
    mgmt = module.network.mgmt_network_id
    k8s  = module.network.k8s_network_id
  }
  subnet_ids = {
    mgmt = module.network.mgmt_subnet_id
    k8s  = module.network.k8s_subnet_id
  }

  # Router interfaces must exist before the floating IP can be associated.
  depends_on = [module.network]
}
