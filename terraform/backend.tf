terraform {
  required_version = ">= 1.0.11"

  backend "s3" {
    shared_credentials_file = ".credentials"
    profile = "terraform-user"
    region = "us-east-1"
    key = "state/terraform.tfstate"
    bucket = "terraform-state-backwards-bucket"
  }
}