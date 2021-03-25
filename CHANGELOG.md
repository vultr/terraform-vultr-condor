# Change Log
## [v1.1.1](https://github.com/vultr/terraform-vultr-condor/releases/tag/v1.1.1) (2021-03-25)
### Fixes
* Bump CCM and CSI versions for Vultr Metadata Fix

## [v1.1.0](https://github.com/vultr/terraform-vultr-condor/releases/tag/v1.1.0) (2021-03-24)
### Features
* Pre-provisioned image option for use with [packer-vultr-condor](https://github.com/vultr/packer-vultr-condor)

### Breaking Changes
* Requires a configured ssh-agent for instance access

## [v1.0.1](https://github.com/vultr/terraform-vultr-condor/releases/tag/v1.0.1) (2021-02-16)
### Bug Fixes
* Remove leading `v` in Vultr CCM and CSI version strings to support named tags, e.g. `latest`, `nightly`, etc.

## [v1.0.0](https://github.com/vultr/terraform-vultr-condor/releases/tag/v1.0.0) (2021-01-27)
### Breaking Changes
* Upgrade to v2 of the Vultr Terraform Provider
* Restructure repository

## [v0.1.1](https://github.com/vultr/terraform-vultr-condor/releases/tag/v0.1.1) (2020-12-11)
### Fixes
* Pin Vultr Terraform provider to `v1.5.0` for resource name and resource parameter compatibility

## [v0.1.0](https://github.com/vultr/terraform-vultr-condor/releases/tag/v0.1.0) (2020-09-16)
### Features
* Initial release
* Deploys a Kubernetes cluster to Vultr

