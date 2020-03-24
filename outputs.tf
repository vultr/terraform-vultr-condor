output "controllers" {
  value = vultr_server.controllers.*.internal_ip
}

output "controller_names" {
  value = vultr_server.controllers.*.hostname
}

output "workers" {
  value = vultr_server.workers.*.internal_ip
}

output "worker_names" {
  value = vultr_server.workers.*.hostname
}


