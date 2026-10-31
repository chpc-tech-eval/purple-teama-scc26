output "private_ips" {
  description = "Hostname => fixed private IP (for the Ansible inventory)."
  value       = { for name, p in openstack_networking_port_v2.host : name => p.all_fixed_ips[0] }
}

output "floating_ips" {
  description = "Hostname => public floating IP (edge-01 only)."
  value       = { for name, f in openstack_networking_floatingip_v2.public : name => f.address }
}
