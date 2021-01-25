terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
    }
    null = {
      source = "hashicorp/null"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "2.1.2"
    }
  }
  required_version = ">= 0.13"
}
