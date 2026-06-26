terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0" # Strictly pinned to v2
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}