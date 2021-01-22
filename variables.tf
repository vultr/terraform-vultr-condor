variable "controller_count" {
  type    = number
  default = 1
}

variable "worker_count" {
  type    = number
  default = 2
}

variable "cluster_region" {
  type    = string
  default = "ewr"
}

variable "cluster_os" {
  type    = string
  default = "Debian 10 x64 (buster)"
}

variable "cluster_name" {
  type    = string
  default = "condor-default"
}

variable "enable_ipv6" {
  type    = bool
  default = false
}

variable "enable_backups" {
  type    = bool
  default = false
}

variable "enable_ddos_protection" {
  type    = bool
  default = false
}

variable "enable_activation_email" {
  type    = bool
  default = false
}

variable "tag" {
  type    = string
  default = ""
}

variable "condor_network_subnet" {
  type    = string
  default = "10.240.0.0"
}

variable "condor_network_subnet_mask" {
  type    = number
  default = 24
}

variable "firewall_group_id" {
  type    = string
  default = ""
}

variable "controller_machine_type" {
  type    = string
  default = "vc2-2c-4gb"
}

variable "worker_machine_type" {
  type    = string
  default = "vc2-1c-1gb"
}

variable "containerd_release" {
  type    = string
  default = "1.4.3-1"
}

variable "k8_version" {
  type    = string
  default = "1.20.2-00"
}

variable "pod_network_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "vultr_ccm_version" {
  type    = string
  default = "0.1.1"
}

variable "cluster_vultr_api_key" {
  type      = string
}
