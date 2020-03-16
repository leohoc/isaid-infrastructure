provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

# creation the eks cluster
resource "aws_eks_cluster" "isaid-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.isaid-role.arn

  vpc_config {
    security_group_ids = [aws_security_group.isaid-cluster-security-group.id]
    subnet_ids         = [aws_subnet.isaid-vpc-subnets[0].id, aws_subnet.isaid-vpc-subnets[1].id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.isaid-role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.isaid-role-AmazonEKSServicePolicy,
  ]
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.isaid-cluster.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to properly configure Kubernetes applications
# on the EC2 instance. We implement a Terraform local here to simplify Base64 encoding this information into the
# AutoScaling Launch Configuration. More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  isaid-cluster-nodes-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.isaid-cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.isaid-cluster.certificate_authority[0].data}' '${var.cluster-name}'
USERDATA
}

resource "aws_launch_configuration" "isaid-cluster-launch-configuration" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.isaid-instance-profile.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "m4.large"
  name_prefix                 = "isaid-cluster"
  security_groups  = [aws_security_group.isaid-nodes-security-group.id]
  user_data_base64 = base64encode(local.isaid-cluster-nodes-userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "isaid-cluster-autoscaling-group" {
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.isaid-cluster-launch-configuration.id
  max_size             = 2
  min_size             = 1
  name                 = "isaid-cluster-autoscaling-group"
  vpc_zone_identifier = [aws_subnet.isaid-vpc-subnets[0].id, aws_subnet.isaid-vpc-subnets[1].id]

  tag {
    key                 = "Name"
    value               = "isaid-cluster-autoscaling-group"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
