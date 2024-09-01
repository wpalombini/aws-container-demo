# Build and push Docker image
resource "null_resource" "docker_push" {
  triggers = {
    ecr_repository_url = aws_ecr_repository.container-demo-ecr.repository_url
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.container-demo-ecr.repository_url}
      docker build -t ${aws_ecr_repository.container-demo-ecr.repository_url}:latest .
      docker push ${aws_ecr_repository.container-demo-ecr.repository_url}:latest
    EOF
  }

  depends_on = [aws_ecr_repository.container-demo-ecr]
}
