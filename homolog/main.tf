provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_eks_cluster" "isaidCluster" {
  name     = "isaid-eks-cluster"
  role_arn = aws_iam_role.isaidRole.arn

  vpc_config {
    subnet_ids = ["subnet-00eca6a817e5c6488", "subnet-00f5a57bb9c4eb3ad"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.isaidRole-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.isaidRole-AmazonEKSServicePolicy,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.isaidCluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.isaidCluster.certificate_authority[0].data
}

resource "aws_eks_node_group" "isaidClusterNodeGroup" {
  cluster_name    = aws_eks_cluster.isaidCluster.name
  node_group_name = "isaid-cluster-node-group"
  node_role_arn   = aws_iam_role.isaidRole.arn
  subnet_ids      = ["subnet-00eca6a817e5c6488", "subnet-00f5a57bb9c4eb3ad"]
  instance_types  = ["t2.micro"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.isaidRole-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.isaidRole-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.isaidRole-AmazonEC2ContainerRegistryReadOnly,
  ]
}
