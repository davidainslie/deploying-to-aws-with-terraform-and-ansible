# Initiate peering connection request from us-east-1 (our master)
resource "aws_vpc_peering_connection" "us-east-1-peer-us-west-2" {
  provider = aws.region-master
  vpc_id      = aws_vpc.vpc-master.id
  peer_vpc_id = aws_vpc.vpc-master-oregon.id
  peer_region = var.region-worker

  tags = {
    Name = "us-east-1-peer-us-west-2"
  }
}

# Accept VPC peering request in us-west-2 from us-east-1
resource "aws_vpc_peering_connection_accepter" "accept-peering" {
  provider = aws.region-worker
  vpc_peering_connection_id = aws_vpc_peering_connection.us-east-1-peer-us-west-2.id
  auto_accept = true
}