output "cluster_id" {
  value = random_id.cluster.hex
}

output "cluster_network_id" {
  value = vultr_private_network.cluster.id
}

output "control_plane_lb_id" {
  value = vultr_load_balancer.control_plane_ha.id
}

output "control_plane_address" {
  value = vultr_load_balancer.control_plane_ha.ipv4
}

output "cluster_firewall_group_id" {
  value = vultr_firewall_group.cluster.id
}

output "controller_ips" {
  value = vultr_instance.control_plane.*.main_ip
}

output "controller_ids" {
  value = vultr_instance.control_plane.*.id
}

output "worker_ips" {
  value = vultr_instance.worker.*.main_ip
}

output "worker_ids" {
  value = vultr_instance.worker.*.id
}
