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