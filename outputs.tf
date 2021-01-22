output "cluster_name" {
  description = "Cluster Name"
  value       = (local.cluster_name)
}

output "controller_public_ips" {
  description = "Controller Nodes: Public IP's"
  value       = vultr_instance.controllers.*.main_ip
}

output "worker_public_ips" {
  description = "Worker Nodes: Public IP's"
  value       = vultr_instance.workers.*.main_ip
}

output "controller_hostnames" {
  description = "Controller Nodes: Hostnames"
  value       = vultr_instance.controllers.*.hostname
}

output "worker_hostnames" {
  description = "Worker Nodes: Hostnames"
  value       = vultr_instance.workers.*.hostname
}

output "default_firewall_group_id" {
  description = "Default Condor firewall group."
  value       = vultr_firewall_group.condor_firewall[0].id
}

output "condor_network_id" {
  description = "Condor internal network."
  value       = vultr_private_network.condor_network.id
}

output "condor_cluster_id" {
  description = "Condor Cluster ID"
  value       = random_id.cluster.hex
}
