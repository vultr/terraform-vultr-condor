resource "vultr_dns_domain" "dns_zone" {
  domain    = var.cluster_domain
  server_ip = "0.0.0.0" # Dummy IP just to create the "zone"
}

resource "vultr_dns_record" "controllers" {
  count  = var.controller_count

  domain = vultr_dns_domain.dns_zone.id
  name   = var.cluster_name
  type   = "A"
  data   = vultr_server.controllers[count.index].main_ip
}

resource "vultr_dns_record" "etcds" {
  count  = var.controller_count

  domain = vultr_dns_domain.dns_zone.id
  name   = "${var.cluster_name}-etcd${count.index}"
  type   = "A"
  data   = vultr_server.controllers[count.index].internal_ip
}


/*
resourece "vultr_dns_record" "controllers" {

}

resourece "vultr_dns_record" "workers" {

}
*/
