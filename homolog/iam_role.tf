resource "aws_iam_role" "isaid-role" {
  name = "isaid-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "isaid-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.isaid-role.name
}

resource "aws_iam_role_policy_attachment" "isaid-role-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.isaid-role.name
}

resource "aws_iam_instance_profile" "isaid-instance-profile" {
  name = "isaid-instance-profile"
  role = aws_iam_role.isaid-role.name
}