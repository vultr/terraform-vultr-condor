# Change Log
## [v2.0.0](https://github.com/vultr/terraform-vultr-condor/releases/tag/v2.0.0) (2021-09-03)
### Breaking Changes
* Condor is now based on Mirantis K0s rather than Kubeadm, as such v2 is completely incompatible with previous releases.
### Features
* HA Control Plane
* Isolated control plane(Control Plane nodes are not part of the cluster)
* Control Plane and Worker Node firewalls. 
* Declarative cluster and component(Vultr CCM, CSI, Calico, etc.) upgrades
* K0s manifest deployer support 

## [v1.3.0](https://github.com/3letteragency/terraform-vultr-k0s/releases/tag/v1.3.0) (2021-08-25)
### Breaking Changes
* Remove `calico_wireguard` variable - nodes were not properly configured, will need to revisit
* Add `calico_mode` variable - previously defaulted to `vxlan`, is now configurable but defaults to `bird`
### Changes
* Bump K0s release from `v1.21.1+k0s.0` to `v1.21.3+k0s.0`
* Bump kube-system component versions

## [v1.2.3](https://github.com/3letteragency/terraform-vultr-k0s/releases/tag/v1.2.3) (2021-07-14)
### Fixes
* Handle dynamic NIC names.

## [v1.2.2](https://github.com/3letteragency/terraform-vultr-k0s/releases/tag/v1.2.2) (2021-06-21)
### Fixes
* Fix firewall configuration after Vultr image changes. 

## [v1.2.1](https://github.com/3letteragency/terraform-vultr-k0s/releases/tag/v1.2.1) (2021-06-19)
### Changes
* Template Vultr CSI 
* Add Vultr CSI image/version vars
* Add kubeconfig filename tf workspace suffix

## [v1.2.0](https://github.com/3letteragency/terraform-vultr-k0s/releases/tag/v1.2.0) (2021-06-12)
### Features
* Support K0s Helm deployments.
### Changes
* Convert module internal K0sctl configuration to HCL from YAML.
### Fixes
* Change Controller/Worker network interfaces from ens3/ens7 to enp1s0/enp6s0 due to Vultr image changes. 

## [v1.1.0](https://github.com/3letteragency/terraform-vultr-k0s/releases/tag/v1.1.0) (2021-06-06)
### Features
* Write Kubeconfig locally option.
* Control Plane VLB Firewall. 
### Changes
* Add variable descriptions.
* Lock up cluster firewall, SSH only by default. 
* Docs updates.
### Fixes
* README markdown.

## [v1.0.1](https://github.com/3letteragency/terraform-vultr-k0s/releases/tag/v1.0.1) (2021-06-05)
### Fixes
* Remove unused variables from triggers map.

## [v1.0.0](https://github.com/3letteragency/terraform-vultr-k0s/releases/tag/v1.0.0) (2021-06-05)
### First Release
