# Vultr k0s

[Terraform Module Registry Docs](https://registry.terraform.io/modules/3letteragency/k0s/vultr/latest)

## Table of Contents
* [Requirements](#requirements)
* [Quick Start](#quick-start)
* [Firewall Configuration](#firewall-configuration)
  * [Control Plane HA VLB Firewall](#control-plane-ha-vlb-firewall)
  * [Cluster Nodes Vultr Firewall](#cluster-nodes-vultr-firewall)
* [Extensions](#extensions)
* [Limitagions](#limitagions)

## Requirements
  * A funded Vultr account and API Key, should be configured as an environment variable to be consumed by the Terraform provider:
  ```sh
  export VULTR_API_KEY="<api-key-here>"
  ```
  * The [k0sctl](https://github.com/k0sproject/k0sctl) executable must be installed and in your executable path.
  * A configured ssh-agent, i.e.:
  ```sh
  ssh-add ~/.ssh/id_rsa
  ```

## Cloud Addons
  * Installs the [Vultr CCM](https://github.com/vultr/vultr-cloud-controller-manager)
  * Installs the [Vultr CSI](https://github.com/vultr/vultr-csi)

## Quick Start
Usage and input details can be found in the [Terraform Module Registry Docs](https://registry.terraform.io/modules/3letteragency/k0s/vultr/latest), or use the quickstart below.

1) Create a `main.tf` file with the [Required Inputs](https://registry.terraform.io/modules/3letteragency/k0s/vultr/latest?tab=inputs#required-inputs):
``` hcl
# main.tf

module "k0s" {
  source                 = "3letteragency/k0s/vultr"
  version                = "1.1.0"
  provisioner_public_key = chomp(file("~/.ssh/id_rsa.pub"))
  cluster_vultr_api_key  = var.cluster_vultr_api_key
  control_plane_firewall_rules = [
    {
      port    = 6443
      ip_type = "v4"
      source  = "0.0.0.0/0"
    }
  ]
}
```
  * The Control Plane Firewall rule in this example exposes the Kubernetes API globally, it is recommended you configure a more restrictive rule or rules on production clusters. 
  * Passing the Cluster API Key as plain text is not recommended for anything beyond testing, use an environment variable as described [here](https://www.terraform.io/docs/cli/config/environment-variables.html#tf_var_name).

2) Configure any [Optional Inputs](https://registry.terraform.io/modules/vultr/condor/vultr/latest?tab=inputs#optional-inputs) if you wish to change from the defaults.

3) Deploy
``` sh
$ terraform init && terraform apply
```

4) The Admin Kubeconfig is not written locally, to create one from the Terraform working directory directory use k0sctl:
``` sh
$ k0sctl kubeconfig > /path/to/admin.conf
```

5) Verify cluster functionality
``` sh
kubectl --kubeconfig admin.conf get no 
kubectl --kubeconfig admin.conf get po -n kube-system
```

## Firewall Configuration
### Control Plane HA VLB Firewall
The Control Plane LB Firewall is configured to allow only what is needed by the cluster as described in the [K0s Networking Docs](https://docs.k0sproject.io/v1.21.1+k0s.0/networking/#required-ports-and-protocols) by default. The Kubernetes API will not be accessible without configuring an additional rule or rules(as shown in the quickstart example) via the `control_plane_firewall_rules` input variable. E.g.:
``` hcl
  control_plane_firewall_rules = [
    {
      port    = 6443
      ip_type = "v4"
      source  = "0.0.0.0/0"
    }
  ]
```
As also stated in the quickstart, this example rule exposes the Kubernetes API globally, your rules should be more restrictive for production clusters.

### Cluster Nodes Vultr Firewall
The cluster nodes(control plane and workers) Vultr Firewall defaults to allowing only SSH globally. This is generally acceptable, however if you would like to restrict access further you may disable this rule by setting the `allow_ssh` input variable to `false` then configuring the desired rule/rules outside of this module using the `cluster_firewall_group_id` output in your rules. 

## Extensions
You may deploy any Kubernetes manifests automatically with the [K0s Manifest Deployer](https://docs.k0sproject.io/v1.21.1+k0s.0/manifests/#manifest-deployer) by placing your manifests in the `/var/lib/k0s/manifests` directory. Doing so via this module is not supported, however you may use the resulting `controller_ips` module output as arguments to a separate module that copies your manifests to the specified directory(or as stated in the linked K0s docs, a "stack" subdirectory).

Please note the [Helm Chart Deployer](https://docs.k0sproject.io/v1.21.1+k0s.0/helm-charts/#helm-charts) is not currently supported by this module. 

## Limitations
* Shrinking of the Control Plane is not supported, only growing. You will need to manually run `k0s etcd leave` on all Control Plane nodes with index > 0 prior to shrinking the `controller_count`. An initial attempt was made to implement this in a destroy time provisioner, however it caused issues when running `terraform destroy` to destroy the entire plan. This may be revisited at a later date. 
