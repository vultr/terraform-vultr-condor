module "k0s" {
  source                 = "../"
  provisioner_public_key = chomp(file("~/.ssh/id_rsa.pub"))
  cluster_vultr_api_key  = var.cluster_vultr_api_key
  control_plane_firewall_rules = [
    {
      port    = 6443
      ip_type = "v4"
      source  = "73.178.251.33/32"
    }
  ]
}
