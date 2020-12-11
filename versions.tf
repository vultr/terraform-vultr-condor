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
      version = "1.5.0"
    }
  }
  required_version = ">= 0.13"
}
