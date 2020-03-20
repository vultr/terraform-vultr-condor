#### Usage:
1. Export your Vultr API Keys as an environment variable:
```
$ export VULTR_API_KEY=EXAMPLEAPIKEYABCXYZ
$ export TF_VAR_ccm_api_key=ANOTHEREXAMPLEAPIKEYABCXYZ # You can re-use your Terraform API key, however I prefer a separate Kubernetes sub-user API Key.
```
2. Create `main.tf` and `variables.tf` files with the following(adjust parameters as necessary). 
```
# main.tf
module "cluster" {
  source          = "git::https://github.com/vultr/k8-tf?ref=master"

  vultr_ccm_image  = "vultr/vultr-cloud-controller-manager:v0.0.2"
  ccm_api_key      = var.ccm_api_key                       # Should configure as environment variable and define in variables.tf
  cluster_name     = "cluster-name"
  cluster_os       = "CentOS 7 x64"                        # Currently only supports CentOS 7
  cluster_region   = "New Jersey"                          # Block Storage only available in NJ
  controller_count = 1                                     # HA Controllers not yet supported
  worker_count     = 1
  controller_plan  = "8192 MB RAM,160 GB SSD,4.00 TB BW"
  worker_plan      = "4096 MB RAM,80 GB SSD,3.00 TB BW"
  k8_release       = "v1.17.4"
  docker_release   = "19.03.4"
  pod_network_cidr = "10.244.0.0/16"                       # Flannel 
}

# variables.tf
variable "ccm_api_key" {
  type = string
}
```
3. Deploy the cluster
```
$ terraform init
$ terraform apply
```


                
