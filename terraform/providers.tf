terraform {
  required_version = ">= 1.0.11"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.1.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.2.0"
    }

    local = {
      source = "hashicorp/local"
      version = "~> 2.2.3"
    }

    archive = {
      source = "hashicorp/archive"
      version = "~> 2.2.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.2.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17.1"
    }
  }
}

provider "aws" {
  profile = var.profile
  region = var.region-master
  alias = "region-master"
}

provider "aws" {
  profile = var.profile
  region = var.region-worker
  alias = "region-worker"
}