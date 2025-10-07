############################################
# AWS Provider
############################################
provider "aws" {
  region = var.aws_region
}

############################################
# ECR Repository
############################################
resource "aws_ecr_repository" "app" {
  name = var.ecr_repo_name
}
