module "condor" {
  source                = "../"
  cluster_name          = "condor-test"
  cluster_vultr_api_key = var.cluster_vultr_api_key
}
