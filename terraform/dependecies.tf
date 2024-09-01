# Build and push Docker image
resource "null_resource" "docker_push" {
  triggers = {
    ecr_repository_url = aws_ecr_repository.container-demo-ecr.repository_url
    image_tag          = local.image_tag
  }

  provisioner "local-exec" {
    command = <<EOF
      set -e
      echo "Starting Docker build and push process..."

      export AWS_PROFILE=${var.aws_profile}
      
      if ! aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.container-demo-ecr.repository_url}; then
        echo "Failed to log in to ECR" >&2
        exit 1
      fi
      
      if ! docker build -t ${aws_ecr_repository.container-demo-ecr.repository_url}:${local.image_tag} -f ../Dockerfile ..; then
        echo "Docker build failed" >&2
        exit 1
      fi
      
      if ! docker push ${aws_ecr_repository.container-demo-ecr.repository_url}:${local.image_tag}; then
        echo "Docker push failed" >&2
        exit 1
      fi
      
      echo "Docker build and push process completed successfully"
    EOF

    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
  }

  depends_on = [aws_ecr_repository.container-demo-ecr]
}
