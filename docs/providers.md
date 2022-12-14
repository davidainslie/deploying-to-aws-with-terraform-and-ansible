# Providers

Providers carry out interactions with vendor APIs such as AWS and Azure.
They also provide logic for managing, updating, and creating resources in Terraform.

Example:
```terraform
provider "aws" {
  profile = var.profile
  region = var.region-master
  alias = "region-master"
}

provider "aws" {
  profile = var.profile
  region = var.region-master
  alias = "region-worker"
}
```

## Setting up multiple AWS providers in Terraform

We'll first create [variables.tf](../terraform/variables.tf)