# Vultr k0s

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

1. Create a `main.tf` file with the [Required Inputs](https://registry.terraform.io/modules/3letteragency/k0s/vultr/latest?tab=inputs#required-inputs):
``` hcl
# main.tf

module "k0s" {
  source                 = "3letteragency/k0s/vultr"
  version                = "1.0.0"
  provisioner_public_key = chomp(file("~/.ssh/id_rsa.pub")) 
  cluster_vultr_api_key  = "<vultr-api-key>" # 
}
```
  * Note, passing the Cluster API Key as plain text is not recommended for anything beyond testing, use an environment variable as described [here](https://www.terraform.io/docs/cli/config/environment-variables.html#tf_var_name).

2. Configure any [Optional Inputs](https://registry.terraform.io/modules/vultr/condor/vultr/latest?tab=inputs#optional-inputs) if you wish to change from the defaults.

3. Deploy
``` sh
$ terraform init && terraform apply
```

4. The Admin Kubeconfig is not written locally, to create one from the Terraform working directory directory use k0sctl:
``` sh
$ k0sctl kubeconfig > /path/to/admin.conf
```

5. Verify cluster functionality
``` sh
kubectl --kubeconfig admin.conf get no 
kubectl --kubeconfig admin.conf get po -n kube-system
```
