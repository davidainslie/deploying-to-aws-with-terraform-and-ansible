# Configuring Terraform Provisioners for Config Management via Ansible

- Create and destroy time provisioners
  - They can be invoked by a resource at creation or when destroyed.
- If a provisioner fails to run for a resource, it's marked as tainted
  - A tainted resource will be destroyed on next terraform apply and recreated.
- Provisioners can can the command locally or remotely (using SSH or WinRM)
  - Local provisioners run on the same system where Terraform commands are invoked.
  - Remote provisioners are run inside the resource in question and need some sort of connection variables such as public keys; they also use protocols such as SSH (Linux) and WinRM (Windows).

As a [terraform recommendation](https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax) provisioners are a `last resort`.

Sample usage of provisioners inside a terraform resource:
```terraform
resource "aws_instance" "jenkins-worker-oregon" {
  # ...
}

provisioner "remote-exec" {
  when = destroy
  inline = ["echo 'Executing on the remote, provisioned instance'"]
  
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }
}

provisioner "local-exec" {
  command = "echo 'Executing on the local instance from which terraform apply was run'"
}
```

Our first use of provisioners simply show out Ansible playbooks are invoked via terraform. Take a look at the [sample templates](../ansible/templates).

Within the sub-directory, `inventory-aws`, we need:
```shell
# wget -c https://raw.githubusercontent.com/linuxacademy/content-deploying-to-aws-ansible-terraform/master/aws_la_cloudplayground_multiple_workers_version/ansible_templates/inventory_aws/tf_aws_ec2.yml
```

Within [instances.tf](../terraform/instances.tf) for bootstrapping EC2 in `us-east-1` we have the following `provisioner`:
```terraform
provisioner "local-exec" {
  command = <<-EOT
    aws --profile ${var.profile} ec2 wait instance-status-ok --region ${var.region-master} --instance-ids ${self.id}
    ansible-playbook --extra-vars 'hosts=tag_Name_${self.tags.Name}' ../ansible/templates/jenkins-master-sample.yml
  EOT
}
```
and a similar entry for `us-west-2`.