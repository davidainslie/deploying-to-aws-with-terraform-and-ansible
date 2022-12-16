# Create VPC in us-east-1
resource "aws_vpc" "vpc-master" {
  provider = aws.region-master
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "master-vpc-jenkins"
  }
}

# Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  provider = aws.region-master
  vpc_id = aws_vpc.vpc-master.id

  tags = {
    Name = "master-igw"
  }
}

# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region-master
  state = "available"
}

# Create subnet #1 in us-east-1
resource "aws_subnet" "subnet-1" {
  provider = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id = aws_vpc.vpc-master.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet-1-master"
  }
}

# Create subnet #2 in us-east-1
resource "aws_subnet" "subnet-2" {
  provider = aws.region-master
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id = aws_vpc.vpc-master.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "subnet-2-master"
  }
}

# Create route table in us-east-1
resource "aws_route_table" "internet-route" {
  provider = aws.region-master
  vpc_id = aws_vpc.vpc-master.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.us-east-1-peer-us-west-2.id
  }

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name = "master-region-rt"
  }
}

# Overwrite default route table of VPC (master) with our route table entires
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider = aws.region-master
  vpc_id         = aws_vpc.vpc-master.id
  route_table_id = aws_route_table.internet-route.id
}