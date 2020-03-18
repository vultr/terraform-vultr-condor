provider "vultr" {
  rate_limit = 3000
}

module "vultr_lib" {
  source		= "github.com/vultr/terraform-datalib-vultr"
}


