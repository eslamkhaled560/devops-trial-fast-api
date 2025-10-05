# ### Provider ###
# variable "aws_region" { 
#     type = string
#     }

# ### ECR ###
# variable "ecr_repo_name" {
#   type = string
# }

# ### ECS ###
# ## ECS Cluster ###
# variable "ecs_cluster_name" {
#   type = string
# }

# ### ECS Task ###
# variable "ecs_task_policy_arn" {
#   default = string
# }

# This variable will receive the ECR image URI from GitHub Actions
variable "image_uri" {
  description = "Full URI of the ECR image to deploy"
  type        = string
  default     = "897762590603.dkr.ecr.us-east-1.amazonaws.com/devops-trial-fastapi-app:latest"
}


# variable "project" {}
# # variable "ecr_repo_name" { default = "fastapi-app" }
# variable "ecr_account" {}
# variable "image_tag" { default = "latest" }
# variable "vpc_id" {}
# variable "public_subnets" { type = list(string) }
# variable "private_subnets" { type = list(string) }
# variable "task_cpu" { default = "256" }
# variable "task_memory" { default = "512" }
# variable "desired_count" { default = 1 }
# variable "min_count" { default = 1 }
# variable "max_count" { default = 3 }
