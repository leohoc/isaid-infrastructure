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
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "isaid-role-AmazonEC2DescribeAccountAttributes" {
  statement {
    effect = "Allow"
    actions = ["ec2:DescribeAccountAttributes"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "isaid-role-policy" {
  name   = "isaid-role-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.isaid-role-AmazonEC2DescribeAccountAttributes.json
}

resource "aws_iam_role_policy_attachment" "isaid-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.isaid-role.name
}

resource "aws_iam_role_policy_attachment" "isaid-role-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.isaid-role.name
}

resource "aws_iam_role_policy_attachment" "isaid-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.isaid-role.name
}

resource "aws_iam_role_policy_attachment" "isaid-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.isaid-role.name
}

resource "aws_iam_role_policy_attachment" "isaid-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.isaid-role.name
}

resource "aws_iam_role_policy_attachment" "isaid-role-policy-attachment" {
  role       = aws_iam_role.isaid-role.name
  policy_arn = aws_iam_policy.isaid-role-policy.arn
}

resource "aws_iam_instance_profile" "isaid-instance-profile" {
  name = "isaid-instance-profile"
  role = aws_iam_role.isaid-role.name
}

###############################################
# Configuring access to DynamoDB Prophet table
###############################################

data "aws_iam_policy_document" "isaid-role-AmazonDynamoDBProphetTableAccess" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    resources = ["arn:aws:dynamodb:${var.region}:${var.account_id}:table/${aws_dynamodb_table.prophet-dynamodb-table.name}"]
  }
}

resource "aws_iam_policy" "isaid-role-dynamodb-prophet-policy" {
  name   = "isaid-role-dynamodb-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.isaid-role-AmazonDynamoDBProphetTableAccess.json
}
resource "aws_iam_role_policy_attachment" "isaid-role-dynamodb-prophet-policy-attachment" {
  role       = aws_iam_role.isaid-role.name
  policy_arn = aws_iam_policy.isaid-role-dynamodb-prophet-policy.arn
}

###############################################
# Configuring access to DynamoDB Prophecy table
###############################################

data "aws_iam_policy_document" "isaid-role-AmazonDynamoDBProphecyTableAccess" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    resources = ["arn:aws:dynamodb:${var.region}:${var.account_id}:table/${aws_dynamodb_table.prophecy-dynamodb-table.name}"]
  }
}

resource "aws_iam_policy" "isaid-role-dynamodb-prophecy-policy" {
  name   = "isaid-role-dynamodb-prophecy-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.isaid-role-AmazonDynamoDBProphecyTableAccess.json
}
resource "aws_iam_role_policy_attachment" "isaid-role-dynamodb-prophecy-policy-attachment" {
  role       = aws_iam_role.isaid-role.name
  policy_arn = aws_iam_policy.isaid-role-dynamodb-prophecy-policy.arn
}

###############################################
# Configuring access to DynamoDB Follower table
###############################################

data "aws_iam_policy_document" "isaid-role-AmazonDynamoDBFollowerTableAccess" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    resources = ["arn:aws:dynamodb:${var.region}:${var.account_id}:table/${aws_dynamodb_table.follower-dynamodb-table.name}"]
  }
}

resource "aws_iam_policy" "isaid-role-dynamodb-follower-policy" {
  name   = "isaid-role-dynamodb-follower-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.isaid-role-AmazonDynamoDBFollowerTableAccess.json
}
resource "aws_iam_role_policy_attachment" "isaid-role-dynamodb-follower-policy-attachment" {
  role       = aws_iam_role.isaid-role.name
  policy_arn = aws_iam_policy.isaid-role-dynamodb-follower-policy.arn
}

##########################################################
# Configuring access to DynamoDB Index
##########################################################

data "aws_iam_policy_document" "isaid-role-AmazonDynamoDBIndexAccess" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Query"
    ]
    resources = ["arn:aws:dynamodb:${var.region}:${var.account_id}:table/${aws_dynamodb_table.follower-dynamodb-table.name}/index/*",
                  "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${aws_dynamodb_table.prophet-dynamodb-table.name}/index/*"]
  }
}

resource "aws_iam_policy" "isaid-role-dynamodb-index-policy" {
  name   = "isaid-role-dynamodb-index-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.isaid-role-AmazonDynamoDBIndexAccess.json
}
resource "aws_iam_role_policy_attachment" "isaid-role-dynamodb-index-policy-attachment" {
  role       = aws_iam_role.isaid-role.name
  policy_arn = aws_iam_policy.isaid-role-dynamodb-index-policy.arn
}

