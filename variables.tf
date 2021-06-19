variable "cluster_name" {
  description = "A name for your cluster."
  type        = string
  default     = "default"
}

variable "provisioner_public_key" {
  description = "SSH Public Key for Terraform provisioner access."
  type        = string
}

variable "extra_public_keys" {
  description = "Extra(in addition the provisioner key) SSH Keys to add to the cluster nodes."
  type        = list(string)
  default     = []
}

variable "region" {
  description = "Vultr deployment region."
  type        = string
  default     = "ewr"
}

variable "node_subnet" {
  description = "Subnet to use for the Vultr Private Network."
  type        = string
  default     = "10.240.0.0/24"
}

variable "controller_count" {
  description = "Number of Control plane nodes."
  type        = number
  default     = 1
}

variable "ha_lb_algorithm" {
  description = "Control Plane VLB balancing algorithm."
  type        = string
  default     = "roundrobin"
}

variable "ha_lb_health_response_timeout" {
  description = "Control Plane VLB healthcheck response timeout."
  type        = number
  default     = 3
}

variable "ha_lb_health_unhealthy_threshold" {
  description = "Control Plane VLB healthcheck unhealthy node threshold."
  type        = number
  default     = 1
}

variable "ha_lb_health_check_interval" {
  description = "Control Plane VLB healthcheck interval."
  type        = number
  default     = 3
}

variable "ha_lb_health_healthy_threshold" {
  description = "Control Plane VLB healthcheck healthy node threshold."
  type        = number
  default     = 2
}

variable "enable_ipv6" {
  description = "Cluster IPv6 for future use NOT CURRENTLY SUPPORTED."
  type        = bool
  default     = false
}

variable "activation_email" {
  description = "Enable/disable cluster node activation emails."
  type        = bool
  default     = false
}

variable "ddos_protection" {
  description = "Enable/disable cluster node DDOS Protection."
  type        = bool
  default     = false
}

variable "tag" {
  description = "Cluster node tags."
  type        = string
  default     = ""
}

variable "worker_count" {
  description = "Number of cluster workers to deploy."
  type        = string
  default     = 3
}

variable "pod_cidr" {
  description = "Pod CIDR Subnet."
  type        = string
  default     = "10.244.0.0/16"
}

variable "svc_cidr" {
  description = "Cluster Service CIDR subnet."
  type        = string
  default     = "10.96.0.0/12"
}

variable "calico_wireguard" {
  description = "Enable/disable Calico Wireguard."
  type        = bool
  default     = true
}

variable "pod_sec_policy" {
  description = "K0s Pod Security Policy."
  type        = string
  default     = "00-k0s-privileged"
}

variable "konnectivity_version" {
  description = "K0s Configuration Konnectivity Version."
  type        = string
  default     = "v0.0.13"
}

variable "metrics_server_version" {
  description = "K0s Configuration Kube Metrics Version."
  type        = string
  default     = "v0.3.7"
}

variable "kube_proxy_version" {
  description = "K0s Configuration Kube Proxy version."
  type        = string
  default     = "v1.21.1"
}

variable "core_dns_version" {
  description = "K0s Configuration CoreDNS version."
  type        = string
  default     = "1.7.0"
}

variable "calico_version" {
  description = "K0s Configuration Calico version."
  type        = string
  default     = "v3.16.2"
}

variable "cluster_os" {
  description = "Cluster node OS."
  type        = string
  default     = "Debian 10 x64 (buster)"
}

variable "worker_plan" {
  description = "Cluster worker node Vultr machine type/plan."
  type        = string
  default     = "vc2-2c-4gb"
}

variable "controller_plan" {
  description = "Cluster controller node Vultr machine type/plan."
  type        = string
  default     = "vc2-2c-4gb"
}

variable "k0s_version" {
  description = "K0s Configuration K0s version."
  type        = string
  default     = "v1.21.1+k0s.0"
}

variable "write_kubeconfig" {
  description = "Write Kubeconfig locally."
  type        = bool
  default     = true
}

variable "cluster_vultr_api_key" {
  description = "Vultr API Key for CCM and CSI."
  type        = string
  sensitive   = true
}

variable "vultr_ccm_version" {
  description = "Vultr Cloud Controller Manager version."
  type        = string
  default     = "v0.2.0"
}

variable "vultr_csi_version" {
  description = "Vultr Cloud Storage Interface version."
  type        = string
  default     = "v0.1.1"
}

variable "control_plane_firewall_rules" {
  description = "Control Plane VLB Firewall Rules."
  type = list(object({
    port    = number
    ip_type = string
    source  = string
  }))
}

variable "allow_ssh" {
  description = "Vultr Firewall Rule to allow SSH globally to all cluster nodes(control plane + workers)."
  type        = bool
  default     = true
}

variable "helm_repositories" {
  type    = list(map(any))
  default = []
}

variable "helm_charts" {
  type    = list(map(any))
  default = []
}

variable "vultr_csi_image" {
  type    = string
  default = "vultr/vultr-csi"
}
