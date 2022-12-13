# Setup

Apologies on the lack of help for Linux and Windows users - we concentrate on **Mac** - One day I may include Linux and Windows.

## Homebrew

Install [Homebrew](https://brew.sh) for easy package management on Mac:

```shell
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install essentials:

```shell
brew cask install virtualbox
brew cask install docker
brew install kind
brew install awscli
brew install terraform
brew install ansible
brew install httpie
```

A helper to Ansible (though already available in this repository):
```shell
wget https://raw.githubusercontent.com/linuxacademy/content-deploying-to-aws-ansible-terraform/master/aws_la_cloudplayground_version/ansible.cfg
```

Some sanity checks:
```shell
aws --version
terraform version                                 
```

And in the `ansible` directory run:
```shell
ansible --version
ansible [core 2.13.6]
  config file = /Users/davidainslie/workspace/aws/deploying-to-aws-with-terraform-and-ansible/ansible.cfg
  ...
```

## AWS and Terraform

We'll run against AWS using the named profile `acloudguru` (though any name will do), where we have:

`~/.aws/config`:
```shell
[profile acloudguru]
region = us-east-1
output = json
cli_pager =
```

and `~/.aws/credentials`:
```shell
[acloudguru]
aws_access_key_id = *****
aws_secret_access_key = *****
```

Sanity check:
```shell
aws --profile acloudguru ec2 describe-instances 
{
    "Reservations": []
}
```

Terraform will need permissions to create, update, and delete various resources.
You can do either of the following depending on how you're deploying:
- Create a separate IAM user with required permissions.
- Create an EC2 (IAM role) instance profile with required permissions and attach it to EC2.

Within the `terraform` directory (though already available in this repository):
```shell
wget https://raw.githubusercontent.com/linuxacademy/content-deploying-to-aws-ansible-terraform/master/iam_policies/terraform_deployment_iam_policy.json
```

There is another version of the above, which is more relaxed with the rules (and so not recommended) but easier to read/understand:
```shell
wget https://raw.githubusercontent.com/linuxacademy/content-deploying-to-aws-ansible-terraform/master/iam_policies/terraform_deployment_lax_iam_policy.json
```

Using the more strict policy, we can create:
```shell
aws --profile acloudguru iam create-policy --policy-name terraform-user-policy --policy-document file://terraform_deployment_iam_policy.json
```
and note the generated ARN for later.

Create an AWS user:
```shell
aws --profile acloudguru iam create-user --user-name terraform-user
```

Create programmatic Access Keys:
```shell
aws --profile acloudguru iam create-access-key --user-name terraform-user
```
and copy the given access key and secret access key into [secrets.tfvars](../terraform/secrets.tfvars).

Attach IAM policy to a user:
```terraform
aws --profile acloudguru iam attach-user-policy --user-name terraform-user --policy-arn arn:aws:iam::412825246027:policy/terraform-user-policy
```

The alternative is to create a role with a [trust policy](../terraform/ec2-can-assume-role.json):
```shell
aws --profile acloudguru iam create-role --role-name terraform-ec2-role --assume-role-policy-document file://ec2-can-assume-role.json
```
and again attach our policy to this role:
```shell
aws --profile acloudguru iam attach-role-policy --role-name terraform-ec2-role --policy-arn arn:aws:iam::412825246027:policy/terraform-user-policy
```

Now we can attach this role to any running EC2 instance.

> The above is very manual and error prone. We can marginally improve this by instead running [terraform-aws.sh](../terraform/terraform-aws.sh):
> ```shell
> source ./terraform-aws-up.sh
> ```
> where we include `source` to expose created environment variables available to the `teardown` script.
> 
> And to [teardown](../terraform/terraform-aws-down.sh) the resources:
> ```shell
> ./terraform-aws-down.sh
> ```
> 
> But really, even the above should itself be terraformed.