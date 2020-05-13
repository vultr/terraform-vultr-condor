variable "cluster_api_key" {
  type = string
}

module "cluster" {
  source          = ""

  cluster_api_key          = var.cluster_api_key                       
  cluster_name             = "ha-test"
  
}
