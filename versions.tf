terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
      version = "2.0.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.0.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.0.1"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "2.1.3"
    }
  }
  required_version = ">= 0.13"
}
