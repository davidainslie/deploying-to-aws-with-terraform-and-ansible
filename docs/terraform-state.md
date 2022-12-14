# Terraform State

Terraform backends:
- Determines how the state is stored.
- By default, state is stored on local disk.
- Variables cannot be used as input to `terraform` block declared in a `.tf` file.

## Persisting Terraform state in S3 backend

Example of backend in a terraform block using S3:
```terraform
terraform {
  required_version = ">= 0.12.0"
  
  backend "s3" {
    region = "us-east-1"
    profile = "default"
    key = "<arbitrary-state-file-name>"
    bucket = "<name-of-already-created-bucket>"
  }
}
```

[terraform-aws-up.sh](../aws/terraform-aws-up.sh) script creates a S3 bucket for usage as a backend of state.
And NOTE that [terraform-aws-down.sh](../aws/terraform-aws-down.sh) will delete said bucket (so be careful).

We'll need a [backend.tf](../terraform/backend.tf) file for our S3 backend configuration. And with this we can:
```shell
terraform init
terraform apply -auto-approve
```
and when all done:
```shell
terraform destroy -auto-approve
```