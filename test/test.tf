variable "cluster_api_key" {
  type = string
}

module "cluster" {
  source = "git::https://github.com/oogy/condor?ref=debian-ha"

  cluster_api_key           = var.cluster_api_key
  cluster_name              = "ha-test"
  controller_count          = 3
  external_lb_frontend_port = 443
  external_lb_backend_port  = 6443
  cluster_domain            = "3letter.agency"
  manage_ssl                = true
}
