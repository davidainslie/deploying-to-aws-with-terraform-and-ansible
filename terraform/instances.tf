# Get Linux AMI using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "linux-ami" {
  provider = aws.region-master
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Get Linux AMI using SSM Parameter endpoint in us-west-2
data "aws_ssm_parameter" "linux-ami-oregon" {
  provider = aws.region-worker
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Create key/pair for logging into EC2 in us-east-1
/*
resource "aws_key_pair" "master-key" {
  provider = aws.region-master
  key_name = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Create key/pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker-key" {
  provider = aws.region-master
  key_name = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}*/


resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_sensitive_file" "pem-file" {
  filename = pathexpand("./jenkins.pem")
  file_permission = "600"
  content = tls_private_key.private-key.private_key_pem
}

# Create key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "master-key" {
  provider = aws.region-master
  key_name = "jenkins"
  public_key = tls_private_key.private-key.public_key_openssh
}

# Create key/pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker-key" {
  provider = aws.region-worker
  key_name = "jenkins"
  public_key = tls_private_key.private-key.public_key_openssh
}