############################################
# AWS Provider
############################################
variable "aws_region" {
  type = string
}

############################################
# ECR Repository
############################################
variable "ecr_repo_name" {
  type = string
}

############################################
# ECS Cluster
############################################
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

############################################
# ECS Task Definition
############################################

# IAM Role for ECS Task Execution
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

# Security Group for ECS Task
variable "task_sg_name" {
  description = "Security group name for ECS tasks"
  type        = string
}

variable "task_ingress_rules" {
  description = "List of ingress rules for ECS task SG"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
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


# Policy Attachment for ECS Task IAM Role
variable "task_policy_attachment_arn" {
  type = string
}

# ECS Task Definition 
variable "task_cloudwatch_log_group_name" {
  type = string
}

variable "task_cloudwatch_log_group_retention" {
  type = number
}

variable "task_family" {
  type = string
}

variable "task_launch_type" {
  description = "Launch types supported by the task definition (e.g. FARGATE, EC2)"
  type        = list(string)
}

variable "task_cpu" {
  type = string
}

variable "task_memory" {
  type = string
}

variable "task_network_mode" {
  type = string
}

variable "task_container_name" {
  type = string
}

# This variable will receive the ECR image URI from GitHub Actions
variable "image_uri" {
  description = "Full URI of the ECR image to deploy"
  type        = string
  default     = "260688678216.dkr.ecr.us-east-1.amazonaws.com/devops-trial-fastapi-app:latest"
}

variable "task_container_essential" {
  type = bool
}

variable "task_container_port" {
  type = number
}

variable "task_host_port" {
  type = number
}

############################################
# ECS Service
############################################
variable "service_name" {
  type = string
}

variable "service_launch_type" {
  type = string
}

############################################
# Auto Scaling
############################################
variable "autoscaling_max" {
  type = number
}

variable "autoscaling_min" {
  type = number
}

variable "autoscaling_service_namespace" {
  type = string
}

variable "autoscaling_scalable_dimention" {
  type = string
}

# Autoscaling policy based on average CPU
variable "autoscaling_policy_name" {
  type = string
}

variable "autoscaling_policy_type" {
  type = string
}

variable "autoscaling_policy_target_value" {
  type = number
}

variable "autoscaling_policy_metric_type" {
  type = string
}



############################################
# Load Balancer
############################################

# Security Group for Application Load Balancer
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

# Application Load Balancer
variable "alb_name" {
  type = string
}

variable "alb_type" {
  type = string
}

variable "alb_internal_facing" {
  type = bool
}

# Target Group for ECS Task
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

# Listener (HTTP forward to target group)
variable "alb_listener_port" {
  type = number
}

variable "alb_listener_protocol" {
  type = string
}

variable "alb_listener_default_action_type" {
  type = string
}

############################################
# Cloudwatch Alarm
############################################
variable "alarm_name" {
  type = string
}

variable "alarm_comparison_operator" {
  type = string
}

variable "alarm_evaluation_periods" {
  type = number
}

variable "alarm_period" {
  type = number
}

variable "alarm_threshold" {
  type = number
}

variable "alarm_statistic" {
  type = string
}

variable "alarm_metric_name" {
  type = string
}

variable "alarm_namespace" {
  type = string
}

variable "alarm_treat_missing_data" {
  type = string
}
