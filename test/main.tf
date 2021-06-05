module "k0s" {
  source                 = "../"
  provisioner_public_key = chomp(file("~/.ssh/id_rsa.pub"))
  cluster_vultr_api_key = var.cluster_vultr_api_key
}
