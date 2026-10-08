output "edge_secgroup_id" {
  value = openstack_networking_secgroup_v2.edge.id
}

output "internal_secgroup_id" {
  value = openstack_networking_secgroup_v2.internal.id
}
