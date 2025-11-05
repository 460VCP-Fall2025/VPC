# How to run VPC

## Step 1: Install Terraform CLI. 
Follow the instructions on the HashiCorp website: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code?in=terraform%2Faws-get-started

## Step 2: Create an IAM user in your AWS account. 
You can do this through the IAM console in your AWS Management Console. Save your user's access key and secret key for the next step.
Useful link: https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html

## Step 3: Install the AWS CLI:
Follow the instructions on the aws.com website: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html


## Step 4: Running the main.tf
In the terraform/ directory, run:
``` bash
terraform init
```
When that is complete, run:

``` bash
terraform apply
```
Type "yes" and Terraform should create the infrastructure in your AWS account, which you can view and access through your AWS Management Console

When done with testing the VPC and you would like to terminate it, run:
``` bash
terraform destroy
```
Type "yes" and Terraform should terminate all resources and instances created.

 
