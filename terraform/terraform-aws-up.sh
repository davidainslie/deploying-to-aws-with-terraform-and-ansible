#!/bin/bash

# Run as: source ./terraform-aws-up.sh

export POLICY_ARN=$(aws --profile acloudguru --no-cli-auto-prompt iam create-policy --policy-name terraform-user-policy --policy-document file://terraform_deployment_iam_policy.json --query 'Policy.Arn' | tr -d \")

aws --profile acloudguru iam create-user --user-name terraform-user

aws --profile acloudguru --no-cli-auto-prompt iam create-access-key --user-name terraform-user --query 'AccessKey.[AccessKeyId, SecretAccessKey]'

aws --profile acloudguru iam attach-user-policy --user-name terraform-user --policy-arn $POLICY_ARN

aws --profile acloudguru iam create-role --role-name terraform-ec2-role --assume-role-policy-document file://ec2-can-assume-role.json

aws --profile acloudguru iam attach-role-policy --role-name terraform-ec2-role --policy-arn $POLICY_ARN