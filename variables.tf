variable "cluster_name" {
  type    = string
  default = "default"
}

variable "provisioner_public_key" {
  type = string
}

variable "extra_public_keys" {
  type    = list(string)
  default = []
}

variable "region" {
  type    = string
  default = "ewr"
}

variable "node_subnet" {
  type    = string
  default = "10.240.0.0/24"
}

variable "controller_count" {
  type    = number
  default = 1
}

variable "ha_lb_algorithm" {
  type    = string
  default = "roundrobin"
}

variable "ha_lb_health_response_timeout" {
  type    = number
  default = 3
}

variable "ha_lb_health_unhealthy_threshold" {
  type    = number
  default = 1
}

variable "ha_lb_health_check_interval" {
  type    = number
  default = 3
}

variable "ha_lb_health_healthy_threshold" {
  type    = number
  default = 2
}

variable "enable_ipv6" {
  type    = bool
  default = false
}

variable "activation_email" {
  type    = bool
  default = false
}

variable "ddos_protection" {
  type    = bool
  default = false
}

variable "tag" {
  type    = string
  default = ""
}

variable "worker_count" {
  type    = string
  default = 3
}

variable "pod_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "svc_cidr" {
  type    = string
  default = "10.96.0.0/12"
}

variable "calico_wireguard" {
  type    = bool
  default = true
}

variable "pod_sec_policy" {
  type    = string
  default = "00-k0s-privileged"
}

variable "konnectivity_version" {
  type    = string
  default = "v0.0.13"
}

variable "metrics_server_version" {
  type    = string
  default = "v0.3.7"
}

variable "kube_proxy_version" {
  type    = string
  default = "v1.21.1"
}

variable "core_dns_version" {
  type    = string
  default = "1.7.0"
}

variable "calico_version" {
  type    = string
  default = "v3.16.2"
}

variable "cluster_os" {
  type    = string
  default = "Debian 10 x64 (buster)"
}

variable "worker_plan" {
  type    = string
  default = "vc2-2c-4gb"
}

variable "controller_plan" {
  type    = string
  default = "vc2-2c-4gb"
}

variable "k0s_version" {
  type    = string
  default = "v1.21.1+k0s.0"
}

variable "write_kubeconfig" {
  type    = bool
  default = true
}

variable "cluster_vultr_api_key" {
  type      = string
  sensitive = true
}

variable "vultr_ccm_version" {
  type    = string
  default = "v0.2.0"
}

variable "vultr_csi_version" {
  type    = string
  default = "v0.1.1"
}
