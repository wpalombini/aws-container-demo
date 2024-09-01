# Get the most recent git commit ID
data "external" "git_commit" {
  program = ["sh", "-c", "echo '{\"commit\": \"'$(git rev-parse --short HEAD)'\"}'"]
}

locals {
  image_tag = data.external.git_commit.result.commit
}

# Output the image tag for use in other Terraform files
output "image_tag" {
  value = local.image_tag
}
