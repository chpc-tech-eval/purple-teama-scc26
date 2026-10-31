locals {
  # cloud-init: install every team member's public key for the image's default user.
  user_data = "#cloud-config\n${yamlencode({ ssh_authorized_keys = var.ssh_public_keys })}"

  public_hosts = { for name, h in var.hosts : name => h if h.public }
}

# One port per host with a fixed private IP (week1 README section 8).
resource "openstack_networking_port_v2" "host" {
  for_each = var.hosts

  name               = "${each.key}-port"
  network_id         = var.network_ids[each.value.network]
  admin_state_up     = true
  security_group_ids = each.value.security_group_ids

  fixed_ip {
    subnet_id  = var.subnet_ids[each.value.network]
    ip_address = each.value.fixed_ip
  }

  # Lets edge-01 forward traffic for VPN clients without anti-spoofing drops.
  dynamic "allowed_address_pairs" {
    for_each = each.value.allowed_cidrs
    content {
      ip_address = allowed_address_pairs.value
    }
  }
}

resource "openstack_compute_instance_v2" "host" {
  for_each = var.hosts

  name      = each.key
  image_id  = var.image_id
  flavor_id = each.value.flavor_id
  user_data = local.user_data

  network {
    port = openstack_networking_port_v2.host[each.key].id
  }

  lifecycle {
    # user_data is only read at first boot; changing it would rebuild the VM.
    # Later SSH key changes are Ansible's job (week1 README step 19).
    ignore_changes = [user_data]
  }
}

# Exactly one public address per public host (only edge-01 in this design).
resource "openstack_networking_floatingip_v2" "public" {
  for_each = local.public_hosts

  pool        = var.floating_ip_pool
  description = "${each.key} public access"
}

resource "openstack_networking_floatingip_associate_v2" "public" {
  for_each = local.public_hosts

  floating_ip = openstack_networking_floatingip_v2.public[each.key].address
  port_id     = openstack_networking_port_v2.host[each.key].id
}
