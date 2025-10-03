############################################
# AWS Provider
############################################
# TODO: Configure AWS provider with region
provider "aws" {
  region = var.aws_region
}

############################################
# ECR Repository
############################################
# TODO: Create ECR repo for FastAPI app image
# IMPORTANT: Must be named with "devops-trial-" prefix
resource "aws_ecr_repository" "app" {
  name = "devops-trial-fastapi-app"
}

############################################
# ECS Cluster
############################################
# TODO: Create ECS cluster
# IMPORTANT: Must be named with "devops-trial-" prefix
resource "aws_ecs_cluster" "app" {
  name = "devops-trial-cluster"
}

############################################
# IAM Role for ECS Task Execution
############################################
# TODO: Create ECS task execution IAM role with:
#  - AmazonECSTaskExecutionRolePolicy
#  - CloudWatch logs access
# IMPORTANT: Must be named with "devops-trial-" prefix
resource "aws_iam_role" "ecs_task_execution" {
  name = "devops-trial-ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

############################################
# Networking & Security Groups
############################################
# TODO: Define Security Groups
#  - ALB SG: allow inbound HTTP (80) from anywhere
#  - Task SG: allow inbound only from ALB SG on port 8000
# IMPORTANT: Must use "devops-trial-" prefix for names

# HINT: VPC/Subnets can be data-sourced from default VPC

############################################
# Load Balancer
############################################
# TODO: Create ALB in public subnets
# TODO: Create Target Group + Listener (port 80 → ECS tasks port 8000)
# IMPORTANT: Must be named with "devops-trial-" prefix

############################################
# ECS Task Definition
############################################
# TODO: Reference ECR image (candidate must set image URI)
resource "aws_ecs_task_definition" "app" {
  family                   = "devops-trial-fastapi-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "fastapi"
    image     = "<ECR_IMAGE_URI>" # TODO: replace with actual ECR image
    essential = true
    portMappings = [{
      containerPort = 8000
      hostPort      = 8000
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/devops-trial-fastapi"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

############################################
# ECS Service
############################################
# TODO: Create ECS Service using:
#  - Cluster
#  - Task definition
#  - Load balancer target group
#  - Fargate launch type
#  - Assign SG/subnets
# IMPORTANT: Must be named with "devops-trial-" prefix
############################################

############################################
# Auto Scaling
############################################
# TODO: Add Application Auto Scaling for ECS Service
#  - Target CPU utilization 70%
# IMPORTANT: Resource names must include "devops-trial-"
############################################

############################################
# Monitoring
############################################
# TODO: Add CloudWatch alarm for high CPU (>70%)
# IMPORTANT: Alarm name must start with "devops-trial-"
############################################
