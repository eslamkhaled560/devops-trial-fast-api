variable "aws_region" { default = "us-east-1" }

### ECR ###
variable "ecr_repo_name" {
  type = string
}
variable "project" {}
# variable "ecr_repo_name" { default = "fastapi-app" }
variable "ecr_account" {}
variable "image_tag" { default = "latest" }
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "task_cpu" { default = "256" }
variable "task_memory" { default = "512" }
variable "desired_count" { default = 1 }
variable "min_count" { default = 1 }
variable "max_count" { default = 3 }
