# Look up the provider's external network by name (we never create it).
data "openstack_networking_network_v2" "external" {
  name     = var.external_network_name
  external = true
}

# --- Management network (edge-01) ---
resource "openstack_networking_network_v2" "mgmt" {
  name           = "${var.name_prefix}-mgmt"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "mgmt" {
  name            = "${var.name_prefix}-mgmt-subnet"
  network_id      = openstack_networking_network_v2.mgmt.id
  cidr            = var.mgmt_cidr
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = var.dns_nameservers

  # DHCP only hands out .100-.250; fixed host IPs live below .100.
  allocation_pool {
    start = cidrhost(var.mgmt_cidr, 100)
    end   = cidrhost(var.mgmt_cidr, 250)
  }
}

# --- Kubernetes network (api-lb-01, k8s-cp-01, workers) ---
resource "openstack_networking_network_v2" "k8s" {
  name           = "${var.name_prefix}-k8s"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "k8s" {
  name            = "${var.name_prefix}-k8s-subnet"
  network_id      = openstack_networking_network_v2.k8s.id
  cidr            = var.k8s_cidr
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = var.dns_nameservers

  allocation_pool {
    start = cidrhost(var.k8s_cidr, 100)
    end   = cidrhost(var.k8s_cidr, 250)
  }
}

# --- Router: both subnets + gateway to the provider network ---
resource "openstack_networking_router_v2" "main" {
  name                = "${var.name_prefix}-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "mgmt" {
  router_id = openstack_networking_router_v2.main.id
  subnet_id = openstack_networking_subnet_v2.mgmt.id
}

resource "openstack_networking_router_interface_v2" "k8s" {
  router_id = openstack_networking_router_v2.main.id
  subnet_id = openstack_networking_subnet_v2.k8s.id
}

# --- Static route for the VPN return path (week1 README section 6) ---
# Replies to WireGuard clients are sent back via edge-01's management IP.
resource "openstack_networking_router_route_v2" "vpn_return" {
  router_id        = openstack_networking_router_v2.main.id
  destination_cidr = var.vpn_cidr
  next_hop         = var.vpn_gateway_ip

  depends_on = [openstack_networking_router_interface_v2.mgmt]
}
