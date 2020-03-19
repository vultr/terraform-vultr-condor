variable "vultr_ccm_image" {
  type = string
}

variable "ccm_api_key" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "controller_count" {
  type = number
}

variable "worker_count" {
  type = number
}

variable "controller_plan" {
  type = string
}

variable "worker_plan" {
  type = string
}

variable "cluster_region" {
  type = string
}

variable "cluster_os" {
  type = string
}

variable "k8_release" {
  type = string
}

variable "docker_release" {
  type = string
}

variable "pod_network_cidr" {
  type = string
}
