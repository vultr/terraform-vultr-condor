variable "controller_count" {
  description = "Number of controller plane instances. Currently only 1 is supported."
  type        = number
  default     = 1
}

variable "worker_count" {
  description = "Number of worker instances."
  type        = number
  default     = 2
}

variable "cluster_region" {
  description = "Cluster deployment region."
  type        = string
  default     = "ewr"
}

variable "cluster_os" {
  description = "Cluster operating system. Currently only Debian 10 is supported."
  type        = string
  default     = "Debian 10 x64 (buster)"
}

variable "cluster_name" {
  description = "A human readable cluster name, used as part of instance hostnames and labels."
  type        = string
  default     = "condor-default"
}

variable "enable_ipv6" {
  description = "Enables/disables IPv6, note: IPv6 clusters are not currently supported."
  type        = bool
  default     = false
}

variable "enable_backups" {
  description = "Enable/disable instance backups"
  type        = bool
  default     = false
}

variable "enable_ddos_protection" {
  description = "Enable/disable Vultr Instance DDOS Protection"
  type        = bool
  default     = false
}

variable "enable_activation_email" {
  description = "Enable/Disable Vultr Instance activation email."
  type        = bool
  default     = false
}

variable "tag" {
  description = "Tags to be applied to all cluster instances(Controllers and Workers)."
  type        = string
  default     = ""
}

variable "condor_network_subnet" {
  description = "Vultr Private Network subnet for instances. Cannot overlap Cluster Service IP's(10.96.0.0/12) or Pod Network IPs(10.244.0.0/16)."
  type        = string
  default     = "10.240.0.0"
}

variable "condor_network_subnet_mask" {
  description = "Subnetmask for the clusters Vultr Private Network."
  type        = number
  default     = 24
}

variable "firewall_group_id" {
  description = "User provided firewall group ID. If provided, this is attached to all cluster instances(Controllers and Workers) and the default Vultr Firewall Group is not created."
  type        = string
  default     = ""
}

variable "controller_machine_type" {
  description = "Vultr Plan to use for controller instances."
  type        = string
  default     = "vc2-2c-4gb"
}

variable "worker_machine_type" {
  description = "Vultr Plan to use for worker instances."
  type        = string
  default     = "vc2-1c-1gb"
}

variable "containerd_release" {
  description = "Version of Containerd runtime package to install via APT to use on cluster instances. Format should be in APT package version string format: x.y.z-00"
  type        = string
  default     = "1.4.3-1"
}

variable "k8_version" {
  description = "Version of Kubernetes packages to install via APT. Format should be in APT package version string format: x.y.z-00"
  type        = string
  default     = "1.20.2-00"
}

variable "pod_network_cidr" {
  description = "Kubernetes Pod Network CIDR. Cannot overlap Cluster Private Network IP's(default: 10.240.0.0/24) or Cluster Service IPs(10.96.0.0/12)."
  type        = string
  default     = "10.244.0.0/16"
}

variable "vultr_ccm_version" {
  description = "Version of the Vultr Cloud Controller Manager to install in the Cluster."
  type        = string
  default     = "v0.1.2"
}

variable "vultr_csi_version" {
  description = "Version of the Vultr Container Storage Interface to install in the Cluster."
  type        = string
  default     = "v0.1.1"
}

variable "cluster_vultr_api_key" {
  description = "Vultr API Key to be used by the Vultr CCM and Vultr CSI. This may be the same API key as your Terraform Vultr API Key, however it is recommended you use a separate key."
  type        = string
}

variable "provisioner_public_key" {
  description = "SSH Public Key for the provisioning machine where Terraform will be ran. When running locally it will be convenient to provide this via Terraform Functions: chomp(file(\"~/.ssh/id_rsa.pub\")) - Otherwise, for example in automation it may be better to provide the key as a string."
  type        = string
}

variable "extra_public_keys" {
  description = "Extra SSH Public keys to be used for regular administration if different from the Provisioner Public Key. For example, jump boxes, administrator workstation keys, etc."
  type        = list(string)
  default     = []
}

variable "kube_calico_version" {
  description = "Version of Calico Network Overlay to install as your cluster CNI."
  type        = string
  default     = "3.18"
}

variable "custom_snapshot_description" {
  description = "A pre-provisioned Condor snapshot(built from packer-vultr-condor) description. For improved stability and deployment time. Note: description must be unique to one snapshot on your account."
  type = string
  default = ""
}
