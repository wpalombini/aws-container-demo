resource "aws_ecr_repository" "container-demo-ecr" {
  name                 = "container-demo-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
