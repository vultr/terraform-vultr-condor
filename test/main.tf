module "condor" {
  source                 = "../"
  cluster_name           = "condor-test"
  cluster_vultr_api_key  = var.cluster_vultr_api_key
  provisioner_public_key = chomp(file("~/.ssh/id_rsa.pub"))
}
