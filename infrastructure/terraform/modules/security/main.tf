# --- edge-01: the only host with public exposure ---
resource "openstack_networking_secgroup_v2" "edge" {
  name        = "${var.name_prefix}-edge"
  description = "edge-01 public access: temporary bootstrap SSH + WireGuard"
}

resource "openstack_networking_secgroup_rule_v2" "edge_bootstrap_ssh" {
  for_each = toset(var.bootstrap_ssh_cidrs)

  security_group_id = openstack_networking_secgroup_v2.edge.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.value
  description       = "TEMPORARY bootstrap SSH - remove after WireGuard is proven"
}

resource "openstack_networking_secgroup_rule_v2" "edge_wireguard" {
  for_each = toset(var.wireguard_source_cidrs)

  security_group_id = openstack_networking_secgroup_v2.edge.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = var.wireguard_port
  port_range_max    = var.wireguard_port
  remote_ip_prefix  = each.value
  description       = "WireGuard admin VPN"
}

# --- internal: attached to all five hosts ---
resource "openstack_networking_secgroup_v2" "internal" {
  name        = "${var.name_prefix}-internal"
  description = "Trust traffic originating from the team's private ranges"
}

resource "openstack_networking_secgroup_rule_v2" "internal_from_private" {
  for_each = toset(var.internal_cidrs)

  security_group_id = openstack_networking_secgroup_v2.internal.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = each.value
  description       = "All protocols from a private team range"
}
