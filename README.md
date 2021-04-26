# Condor

Condor is easiest and fastest way to deploy a Kubernetes cluster on Vultr. 

## Addons
  * Installs the [Vultr CCM](https://github.com/vultr/vultr-cloud-controller-manager)
  * Installs the [Vultr CSI](https://github.com/vultr/vultr-csi)
  * Installs Calico CNI

While Condor defaults many cluster configurations you are also able to adjust and fine tune the cluster to your specific needs.

## Usage

Usage and input details can be found in the [Terraform Module Registry Docs](https://registry.terraform.io/modules/vultr/condor/vultr/latest), or use the quickstart below.

1. Create a `main.tf` file:
``` hcl
# main.tf

module "condor" {
  source                 = "vultr/condor/vultr"
  version                = "1.1.1"
  provisioner_public_key = chomp(file("~/.ssh/id_rsa.pub"))
}
```
2. Configure the [Required Inputs](https://registry.terraform.io/modules/vultr/condor/vultr/latest?tab=inputs#required-inputs):
  * `provisioner_public_key` -  For example, using Terraform functions: `chomp(file("~/.ssh/id_rsa.pub"))`, or as a string. Note: You will need to have an SSH Agent configured with the accompanying private key:

``` sh
$ ssh-add ~/.ssh/id_rsa
```

  * `cluster_vultr_api_key` - This is a Vultr API Key to be used by the Vultr CCM and CSI Kubernetes Addons and should be different from your Terraform provisioning API Key(however can be re-used for testing). Can be configured as an environment variable in your shell(Recommended) or as a string in your `main.tf`(Only recommended for testing).

3. Configure the [Optional Inputs](https://registry.terraform.io/modules/vultr/condor/vultr/latest?tab=inputs#optional-inputs) if you wish to change from the defaults.

4. Deploy
``` sh
terraform init && terraform apply
```

5. The Admin Kubeconfig is copied to your working directory(`admin.conf`), check your cluster:

``` sh
kubectl get no --kubeconfig ./admin.conf
NAME                                        STATUS   ROLES                  AGE   VERSION
<cluster-name>-<cluster-id>-controller-0   Ready    control-plane,master   16h   v1.20.2
<cluster-name>-<cluster-id>-worker-0       Ready    <none>                 16h   v1.20.2
<cluster-name>-<cluster-id>-worker-1       Ready    <none>                 16h   v1.20.2
```

## Notes
 * The Admin Kubeconfig is copied to the directory that your Terraform plan was ran from and is stored as `admin.conf`. An `admin.conf.bak` file is also created, which contains the control plane private IP and cannot be used remotely. 
 * If an Existing Firewall Group ID is not provided via the `firewall_group_id` input, an empty Vultr Firewall Group will be created and exposed via the `condor_firewall_group_id` output. You may wish to configure firewall rules in your `main.tf` referencing the `condor_firewall_group_id` output to lock down your cluster as needed. 
