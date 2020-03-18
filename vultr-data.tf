data "vultr_plan" "controller_plan" {
  filter {
    name   = "name"
    values = [var.controller_plan]
  }
}

data "vultr_plan" "worker_plan" {
  filter {
    name   = "name"
    values = [var.worker_plan]
  }
}

data "vultr_region" "cluster_region" {
  filter {
    name   = "name"
    values = [var.cluster_region]
  }
}

data "vultr_os" "cluster_os" {
  filter {
    name   = "name"
    values = [var.cluster_os]
  }
}


