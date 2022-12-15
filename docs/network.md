# Network

## Deploying VPCs, Internet Gateways, and subnets

Looking at the [architecture](images/architecture.jpg) we see that there are two VPCs with internet gateways.
We describe these in [network-master.tf](../terraform/network-master.tf) and [network-worker.tf](../terraform/network-worker.tf).

## Deploying multi-region VPC peering
