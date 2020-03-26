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

data "http" "vultr_ccm_file" {
  url = "https://raw.githubusercontent.com/vultr/vultr-cloud-controller-manager/master/docs/releases/${var.vultr_ccm_release}.yml"
}

data "http" "vultr_csi_file" {
  url = "https://github.com/vultr/vultr-csi/blob/ef0c9f591b8c0e72d5f7356c1c2fb4bf1e4c5577/docs/releases/${var.vultr_csi_release}.yml"
}
