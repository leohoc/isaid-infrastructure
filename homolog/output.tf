output "endpoint" {
  value = aws_eks_cluster.isaid-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.isaid-cluster.certificate_authority[0].data
}