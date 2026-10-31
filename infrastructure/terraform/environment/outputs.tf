output "edge_floating_ip" {
  description = "Public address of edge-01 (the single intended public exposure)."
  value       = module.compute.floating_ips["edge-01"]
}

output "private_ips" {
  description = "Fixed private IP of every host, for the private Ansible inventory."
  value       = module.compute.private_ips
}
