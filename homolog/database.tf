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