terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
    }
    null = {
      source = "hashicorp/null"
    }
    vultr = {
      source = "vultr/vultr"
    }
  }
  required_version = ">= 0.13"
}
