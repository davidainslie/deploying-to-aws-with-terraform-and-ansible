#!/bin/bash

ACCESS_KEY=$(aws --profile acloudguru --no-cli-auto-prompt iam list-access-keys --user-name terraform-user --query 'AccessKeyMetadata[0].AccessKeyId' | tr -d \")
aws --profile acloudguru iam delete-access-key --user-name terraform-user --access-key-id $ACCESS_KEY

aws --profile acloudguru iam detach-user-policy --user-name terraform-user --policy-arn $POLICY_ARN

aws --profile acloudguru iam delete-user --user-name terraform-user

aws --profile acloudguru iam detach-role-policy --role-name terraform-ec2-role --policy-arn $POLICY_ARN

aws --profile acloudguru iam delete-role --role-name terraform-ec2-role

aws --profile acloudguru iam delete-policy --policy-arn $POLICY_ARN

aws --profile acloudguru s3 rb s3://terraform-state-backwards-bucket --force