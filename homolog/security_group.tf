## #############################################################
## CLUSTER SECURITY GROUP CONFIGURATION
## #############################################################

# creating a security group to control access to the cluster
resource "aws_security_group" "isaid-cluster-security-group" {
  name        = "isaid-cluster-security-group"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.isaid-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "isaid-cluster"
  }
}

# adding a security group rule to allow workstation access to the cluster
resource "aws_security_group_rule" "workstation-cluster-access-rule" {
  cidr_blocks       = ["189.79.108.132/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.isaid-cluster-security-group.id
  to_port           = 443
  type              = "ingress"
}

## #############################################################
## NODES SECURITY GROUP CONFIGURATION
## #############################################################

# creating a security group to control access to the worker nodes
resource "aws_security_group" "isaid-nodes-security-group" {
  name        = "isaid-cluster-nodes-security-group"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.isaid-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "isaid-cluster-nodes"
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}

# creating a security group rule to allow nodes communicate with each other
resource "aws_security_group_rule" "isaid-nodes-security-group-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.isaid-nodes-security-group.id
  source_security_group_id = aws_security_group.isaid-nodes-security-group.id
  to_port                  = 65535
  type                     = "ingress"
}

# creating a security group rule to allow nodes to receive communication from control plane
resource "aws_security_group_rule" "isaid-nodes-security-group-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.isaid-nodes-security-group.id
  source_security_group_id = aws_security_group.isaid-cluster-security-group.id
  to_port                  = 65535
  type                     = "ingress"
}

## #############################################################
## CLUSTER AND NODES COMMUNICATION CONFIGURATION
## #############################################################

# creating a security group rule to allow pods to communicate with cluster
resource "aws_security_group_rule" "isaid-cluster-security-group-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.isaid-cluster-security-group.id
  source_security_group_id = aws_security_group.isaid-nodes-security-group.id
  to_port                  = 443
  type                     = "ingress"
}