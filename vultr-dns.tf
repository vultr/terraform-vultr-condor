resource "vultr_dns_domain" "cluster_domain" {
  count = var.cluster_domain != null ? 1 : 0
  domain = var.cluster_domain
  server_ip = vultr_load_balancer.external_lb.ipv4
}

resource "vultr_dns_record" "kube_api_server" {
  domain = vultr_dns_domain.cluster_domain.id
  name = "kubeapi"
  data = vultr_load_balancer.external_lb.ipv4
  type = "A"
}
