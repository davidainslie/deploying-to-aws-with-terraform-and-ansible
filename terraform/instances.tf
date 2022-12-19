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

# Create and bootstrap EC2 in us-east-1
resource "aws_instance" "jenkins-master" {
  provider = aws.region-master
  ami = data.aws_ssm_parameter.linux-ami.value
  instance_type = var.instance-type
  key_name = aws_key_pair.master-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  subnet_id = aws_subnet.subnet-1.id

  tags = {
    Name = "jenkins-master"
  }

  depends_on = [
    aws_main_route_table_association.set-master-default-rt-assoc
  ]
}

output "jenkins-master-public-ip" {
  value = aws_instance.jenkins-master.public_ip
}

# Create and bootstrap EC2 in us-west-2
resource "aws_instance" "jenkins-worker-oregon" {
  provider = aws.region-worker
  ami = data.aws_ssm_parameter.linux-ami-oregon.value
  instance_type = var.instance-type
  count = var.worker-count
  key_name = aws_key_pair.worker-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.jenkins-sg-oregon.id]
  subnet_id = aws_subnet.subnet-1-oregon.id

  tags = {
    Name = join("-", ["jenkins-worker", count.index + 1])
  }

  depends_on = [
    aws_main_route_table_association.set-worker-default-rt-assoc,
    aws_instance.jenkins-master
  ]
}

output "jenkins-worker-public-ips" {
  # Output a Map of instance ID -> it's IP i.e. {} will produce a Map unlike [] that produces a list.
  value = {
    for instance in aws_instance.jenkins-worker-oregon:
      instance.id => instance.public_ip
  }
}