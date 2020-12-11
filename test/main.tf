variable api_key {
  type = string
}

module "condor" {
  source  = "../"
  cluster_api_key = var.api_key
  cluster_name = "condor-test"
}
