# Change Log
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
