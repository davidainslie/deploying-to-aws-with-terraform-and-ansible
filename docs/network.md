# Network

## Deploying VPCs, Internet Gateways, subnets, multi-region VPC peering, and security groups

Looking at the [architecture](images/architecture.jpg) we see that there are two VPCs with internet gateways.
We describe these in [network-master.tf](../terraform/network-master.tf) and [network-worker.tf](../terraform/network-worker.tf).
