# Create VPC in us-west-2
resource "aws_vpc" "vpc-master-oregon" {
  provider = aws.region-worker
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "worker-vpc-jenkins"
  }
}

# Create IGW in us-west-2
resource "aws_internet_gateway" "igw-oregon" {
  provider = aws.region-worker
  vpc_id = aws_vpc.vpc-master-oregon.id

  tags = {
    Name = "worker-igw"
  }
}

# Create subnet #1 in us-west-2
resource "aws_subnet" "subnet-1-oregon" {
  provider = aws.region-worker
  vpc_id = aws_vpc.vpc-master-oregon.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "subnet-worker"
  }
}