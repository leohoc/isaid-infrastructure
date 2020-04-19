# ISAID-INFRASTRUCTURE

> Development in progress

### Description

Terraform project to provide the infrastructure needed to run the ISAID project in AWS.
Currently it provides the following resources:

  * A Kubernetes cluster using EKS, with Node Groups containing two t2.micro EC2 machines;
  * Networking items: a VPC with two Subnets, with internet gateway, routes and security groups configured;
  * A registry repository using ECR to store the application images;
  * DynamoDB tables for prophets, prophecies and followers;
  * A role with the policies needed to build the aforementioned resources; 

### Building the infrastructure

#### Install requirements

- An AWS account;
- awscli >= 2 with AWS account credentials configured;
- terraform >= 0.12;

#### Run

This will build the infrastructure in the AWS account:

```bash

git clone https://github.com/leohoc/isaid-infrastructure
cd isaid-infrastructure/homolog
terraform apply

```

Terraform will show all the resources it will create. Review the list and type 'yes' when prompted.
Await for the building process to finish (this will take a while).
Be aware that this will generate costs related to the AWS account. 

#### Stop

This will stop running the infrastructure:

```bash

terraform destroy

```
