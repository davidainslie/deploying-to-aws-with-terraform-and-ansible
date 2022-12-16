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

# Create route table in us-west-2
resource "aws_route_table" "internet-route-oregon" {
  provider = aws.region-worker
  vpc_id = aws_vpc.vpc-master-oregon.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-oregon.id
  }

  route {
    cidr_block = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.us-east-1-peer-us-west-2.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "worker-region-rt"
  }
}

# Overwrite default route table of VPC (worker) with our route table entires
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider = aws.region-worker
  vpc_id         = aws_vpc.vpc-master-oregon.id
  route_table_id = aws_route_table.internet-route-oregon.id
}