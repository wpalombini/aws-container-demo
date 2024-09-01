# AWS Container Demo

This project is a demo on how to host an application in AWS ECS containers using Terraform as Infrastructure as Code (IaC).

## What it does:

- Creates a new ECR Registry
- Builds and deploys a docker container to this registry using the git commit id as image tag
- Creates a new VPC
- Creates a new Application Load Balancer
- Creates 2 new security groups, allowing public access to the ALB and ALB access to the containers
- Creates new ECS Service and Task Definition

## Requirements:

- AWS CLI v2.x.x
- Terraform v1.9.x
- docker 27.x.x

## How to run the demo project:

- set your AWS_PROFILE: `export AWS_PROFILE=your-aws-profile`
- login to AWS: `aws sso login`
- cd into the terraform folder: `cd terraform`
- Use your AWS_PROFILE variable in variables.tf or pass it as a param in the terraform plan: `terraform plan -var "aws_profile=$AWS_PROFILE" -out ./.tfplan`
- Apply the terraform plan: `terraform apply ./.tfplan`
