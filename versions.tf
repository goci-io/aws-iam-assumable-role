terraform {
  required_version = ">= 0.12.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.50"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2"
    }
  }
}
