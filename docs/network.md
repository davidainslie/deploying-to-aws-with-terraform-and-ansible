# Network

## Deploying VPCs, Internet Gateways, subnets, multi-region VPC peering, and security groups

Looking at the [architecture](images/architecture.jpg) we see that there are two VPCs with internet gateways.
We describe these in [network-master.tf](../terraform/network-master.tf) and [network-worker.tf](../terraform/network-worker.tf).

## Using Data source (SSM parameter store) to fetch AMI IDs

Take a look at [instances.tf](../terraform/instances.tf).

## Deploying key pairs for app nodes

The key/pairs will provide us `ssh` access to the application nodes.
EC2 key/pairs need to be created and attached to an EC2 instance before the EC2 instance is launched, because they are baked into the instance at boot time (authorized_keys).

We can manually generate a key/pair:
```shell
ssh-keygen -t rsa
```
but we'll apply this within our terraform, [instances.tf](../terraform/instances.tf).