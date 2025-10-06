# ### AWS Provider ###
variable "aws_region" { 
    type = string
    }

# ### ECR ###
variable "ecr_repo_name" {
  type = string
}

## ECS Cluster ###
variable "ecs_cluster_name" {
  type = string
}

variable "ecs_cluster_settings" {
  description = "List of ECS cluster settings (e.g., container insights)."
  type = list(object({
    name  = string
    value = string
  }))
}

# ### ECS Task ###
### IAM Role ###
variable "task_iam_rule_name" {
  type = string
}

variable "task_iam_rule_version" {
  type = string
}

variable "task_iam_rule_effect" {
  type = string
}

variable "task_iam_rule_service" {
  type = string
}

variable "task_iam_rule_action" {
  type = string
}

### Security Group ###
variable "task_sg_name" {
  description = "Security group name for ECS tasks"
  type        = string
}

variable "task_ingress_rules" {
  description = "List of ingress rules for ECS task SG"
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
  }))
}

variable "task_egress_rules" {
  description = "List of egress rules for ECS task SG"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = optional(list(string), [])
  }))
}


### Policy Attachment ###
variable "task_policy_attachment_arn" {
  type = string
}

### Application Load Balancer ###
### Security Group ###
variable "alb_sg_name" {
  description = "Security group name for ALB"
  type        = string
}

variable "alb_ingress_rules" {
  description = "List of ingress rules for the ALB security group"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = optional(list(string), [])
  }))
}

variable "alb_egress_rules" {
  description = "List of egress rules for the ALB security group"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = optional(list(string), [])
  }))
}

### ALB ###
variable "alb_name" {
  type = string
}

variable "alb_type" {
  type = string
}

variable "alb_internal_facing" {
  type = bool
}

### Target Group ###
variable "alb_tg_name" {
  type = string
}

variable "alb_tg_port" {
  type = number
}

variable "alb_tg_protocol" {
  type = string
}

variable "alb_tg_type" {
  type = string
}

### Listener ###
variable "alb_listener_port" {
  type = number
}

variable "alb_listener_protocol" {
  type = string
}

variable "alb_listener_default_action_type" {
  type = string
}





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
