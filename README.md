# Condor

Condor is easiest and fastest way to deploy a Kubernetes cluster on Vultr. 

Some notable configurations are 

- Installs the [Vultr CCM](https://github.com/vultr/vultr-cloud-controller-manager)
- Installs the [Vultr CSI](https://github.com/vultr/vultr-csi)
- Installs Flannel CNI
- Configures private networking
- Define how many worker nodes you would like
- Configure Kuberbetes, Docker, and ContainerD release versions

While Condor defaults many cluster configurations you are also able to adjust and fine tune the cluster to your specific needs.


#### Usage:
1. Export your Vultr API Keys as an environment variable:
```
$ export VULTR_API_KEY=EXAMPLEAPIKEYABCXYZ
$ export TF_VAR_cluster_api_key=ANOTHEREXAMPLEAPIKEYABCXYZ # You can re-use your Terraform API key, however it is recommened to use a separate Kubernetes sub-user API Key.
```
2. Create `main.tf` file and `cluster_api_key` variable with the following(adjust parameters as necessary). 
```hcl
# main.tf
variable "cluster_api_key" {
  type = string
}

module "cluster" {
  source          = "git::https://github.com/vultr/condor?ref=debian"

  cluster_api_key          = var.cluster_api_key                       
  cluster_name             = "cluster-name"
}
```
3. Deploy the cluster
```sh
$ terraform init
$ terraform validate
$ terraform apply
```

#### Optional module parameters and defaults:
```sh
vultr_ccm_release  - default: "latest" (If specifying a version use the form `vX.Y.Z`)
vultr_csi_release  - default: "latest" (If specifying a version use the form `vX.Y.Z`)
cluster_cni        - default: "https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
controller_count   - default: 1 (HA not yet supported)
worker_count       - default: 3
controller_plan    - default: "8192 MB RAM,160 GB SSD,4.00 TB BW"
worker_plan        - default: "4096 MB RAM,80 GB SSD,3.00 TB BW"
cluster_region     - default: "New Jersey" (Block Storage is currently only available in New Jersey)
cluster_os         - default: "Debian 10 x64 (buster)" (Should only test new releases of Debian, not other flavors of Linux).
k8_release         - default: "v1.17.4"
docker_release     - default: "5:19.03.4~3-0~debian-$(lsb_release -cs)"
containerd_release - default: "1.2.10-3"
pod_network_cidr   - default: "10.244.0.0/16" (Should change if changing `cluster_cni`) 
```
#### HA Control Plane

**Please note, this is a beta feature.**

It is possible to deploy a highly available control plane using Condor, however in contrast with a single control node deployment a domain *must* be provided via the `cluster_domain` variable and the `controller_count` must be an odd number greater than 1(e.g 3 or 5). 

#### HA Control Plane parameters and defaults:
```sh
cluster_domain            - default: null
kube_api_dns_subdomain    - default: "kubeapi"
external_lb_frontend_port - default: 443
external_lb_backend_port  - default: 6443
```
A minimal HA Control Plane `main.tf` is as follows:
```hcl
variable "cluster_api_key" {
  type = string
}

module "cluster" {
  source = "git::https://github.com/vultr/condor?ref=debian"

  cluster_api_key           = var.cluster_api_key
  cluster_name              = "ha-control-plane"
  controller_count          = 3
  cluster_domain            = "some.domain"
}
```
