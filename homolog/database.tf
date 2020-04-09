resource "aws_dynamodb_table" "prophet-dynamodb-table" {
  name           = "Prophet"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "login"

  attribute {
    name = "login"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-prophet-table"
    Environment = "homolog"
  }
}

resource "aws_dynamodb_table" "prophecy-dynamodb-table" {
  name           = "Prophecy"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "prophetCode"
  range_key      = "prophecyTimestamp"

  attribute {
    name = "prophetCode"
    type = "S"
  }

  attribute {
    name = "prophecyTimestamp"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-prophecy-table"
    Environment = "homolog"
  }
}

resource "aws_dynamodb_table" "follower-dynamodb-table" {
  name           = "Follower"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "followerCode"
  range_key      = "eventTimestamp"

  attribute {
    name = "followerCode"
    type = "S"
  }

  attribute {
    name = "eventTimestamp"
    type = "S"
  }

  attribute {
    name = "prophetCode"
    type = "S"
  }

  global_secondary_index {
    name               = "ProphetFollowersIndex"
    hash_key           = "prophetCode"
    range_key          = "eventTimestamp"
    write_capacity     = 20
    read_capacity      = 20
    projection_type    = "ALL"
  }

  tags = {
    Name        = "dynamodb-follower-table"
    Environment = "homolog"
  }
}