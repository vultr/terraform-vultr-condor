terraform {
  required_providers {
    http = {
      source = "hashicorp/http"
    }
    null = {
      source = "hashicorp/null"
    }/*
    vultr = {
      source  = "vultr/vultr"
      version = "2.1.2"
    }*/
    vultr = {
      source  = "vultr.com/vultr/vultr"
      version = "0.0.7"
    }
  }
  required_version = ">= 0.13"
}
