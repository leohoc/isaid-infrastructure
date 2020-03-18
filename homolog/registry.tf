resource "aws_ecr_repository" "isaid-registry" {
  name                 = "isaid"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}