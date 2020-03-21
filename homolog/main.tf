provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

# creating the eks cluster
resource "aws_eks_cluster" "isaid-cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.isaid-role.arn

  vpc_config {
    security_group_ids = [aws_security_group.isaid-cluster-security-group.id]
    subnet_ids         = [aws_subnet.isaid-vpc-subnets[0].id, aws_subnet.isaid-vpc-subnets[1].id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.isaid-role-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.isaid-role-AmazonEKSServicePolicy
  ]
}

# creating a node group with two workers in the eks cluster
resource "aws_eks_node_group" "isaidClusterNodeGroup" {
  cluster_name    = aws_eks_cluster.isaid-cluster.name
  node_group_name = "isaid-cluster-node-group"
  node_role_arn   = aws_iam_role.isaid-role.arn
  subnet_ids      = [aws_subnet.isaid-vpc-subnets[0].id, aws_subnet.isaid-vpc-subnets[1].id]
  instance_types  = ["t2.micro"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.isaid-role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.isaid-role-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.isaid-role-AmazonEC2ContainerRegistryReadOnly,
  ]
}