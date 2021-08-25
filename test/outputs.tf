output "cluster_id" {
  value = module.k0s.cluster_id
}

output "cluster_network_id" {
  value = module.k0s.cluster_network_id
}

output "control_plane_lb_id" {
  value = module.k0s.control_plane_lb_id
}

output "control_plane_address" {
  value = module.k0s.control_plane_address
}

output "cluster_firewall_group_id" {
  value = module.k0s.cluster_firewall_group_id
}

output "controller_ips" {
  value = module.k0s.controller_ips
}

output "controller_ids" {
  value = module.k0s.controller_ids
}

output "worker_ips" {
  value = module.k0s.worker_ips
}

output "worker_ids" {
  value = module.k0s.worker_ids
}
