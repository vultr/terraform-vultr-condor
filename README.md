# Condor

Condor is easiest and fastest way to deploy a Kubernetes cluster on Vultr. 

Some notable configurations are 

- Installs the [Vultr CCM](https://github.com/vultr/vultr-cloud-controller-manager)
- Installs the [Vultr CSI](https://github.com/vultr/vultr-csi)
- Installs Flannel CNI
- Configures private networking
- Define how many worker nodes you would like
- Configure Kuberbetes, and ContainerD release versions

While Condor defaults many cluster configurations you are also able to adjust and fine tune the cluster to your specific needs.

Please refer to the [Terraform Module Registry Docs](https://registry.terraform.io/modules/vultr/condor/vultr/latest) for usage and required inputs. 

