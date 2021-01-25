output "cluster_name" {
  description = "Cluster Name"
  value       = module.condor.cluster_name
}

output "controller_public_ips" {
  description = "Controller Nodes: Public IP's"
  value       = module.condor.controller_public_ips
}

output "worker_public_ips" {
  description = "Worker Nodes: Public IP's"
  value       = module.condor.worker_public_ips
}

output "controller_hostnames" {
  description = "Controller Nodes: Hostnames"
  value       = module.condor.controller_hostnames
}

output "worker_hostnames" {
  description = "Worker Nodes: Hostnames"
  value       = module.condor.worker_hostnames
}

output "condor_firewall_group_id" {
  description = "Default Condor firewall group."
  value       = module.condor.condor_firewall_group_id
}

output "condor_network_id" {
  description = "Condor internal network."
  value       = module.condor.condor_network_id
}

output "condor_cluster_id" {
  description = "Condor Cluster ID"
  value       = module.condor.condor_cluster_id
}
