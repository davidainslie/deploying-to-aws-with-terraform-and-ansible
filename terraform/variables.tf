variable "profile" {
  type = string
  default = "terraform-user"
}

variable "region-master" {
  type = string
  default = "us-east-1"
}

variable "region-worker" {
  type = string
  default = "us-west-2"
}

variable "external-ip" {
  type = string
  default = "0.0.0.0/0"
}