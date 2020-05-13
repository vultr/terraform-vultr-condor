resource "vultr_load_balancer" "external_lb" {
  count = var.controller_count > 1 ? 1 : 0

  region_id = data.vultr_region.cluster_region.id
  label = "${var.cluster_name}-external-lb"
  attached_instances = vultr_server.controllers.*.id
  
  forwarding_rules {
    frontend_protocol = "tcp"
    frontend_port = var.external_lb_frontend_port
    backend_protocol = "tcp"
    backend_port = var.external_lb_frontend_port
  }
}
