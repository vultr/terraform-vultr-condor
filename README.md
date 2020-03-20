# k8-tf

#### Import as module:
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
```
### Create cluster
```
$ export TF_VAR_ccm_api_key=EXAMPLEAPIKEYABCXYZ
$ terraform apply
```


                
