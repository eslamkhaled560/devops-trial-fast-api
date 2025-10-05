############################################
# AWS Provider
############################################
# TODO: Configure AWS provider with region
provider "aws" {
  region = "us-east-1"
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
  
  # Enables ECS metrics & logs in CloudWatch
  setting {
    name  = "containerInsights"
    value = "enabled"  # Enables ECS metrics & logs in CloudWatch
  }
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
      Principal = { 
        Service = "ecs-tasks.amazonaws.com" 
        }
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

# Fetch default VPC
data "aws_vpc" "default" {
  default = true
}

# Fetch default Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for Application Load Balancer
resource "aws_security_group" "alb_sg" {
  name        = "devops-trial-alb-sg"
  description = "Allow inbound HTTP (80) from anywhere"
  vpc_id      = data.aws_vpc.default.id

  # Inbound rule: HTTP from anywhere
  ingress {
    description      = "Allow HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Outbound rule: allow all
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "task_sg" {
  name        = "devops-trial-task-sg"
  description = "Allow inbound 8000 only from ALB SG"
  vpc_id      = data.aws_vpc.default.id

  # Inbound: only from ALB SG
  ingress {
    description     = "Allow inbound app traffic from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Outbound: allow all
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

############################################
# Load Balancer
############################################
# TODO: Create ALB in public subnets
# TODO: Create Target Group + Listener (port 80 → ECS tasks port 8000)
# IMPORTANT: Must be named with "devops-trial-" prefix

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = "devops-trial-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# Target Group for ECS Tasks
resource "aws_lb_target_group" "ecs_tg" {
  name        = "devops-trial-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path = "/"
  }
}

# Listener (HTTP forward to target group)
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}


############################################
# ECS Task Definition
############################################
# TODO: Reference ECR image (candidate must set image URI)
resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/devops-trial-fastapi"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "app" {
  family                   = "devops-trial-fastapi-task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "fastapi"
    image     = "${aws_ecr_repository.app.repository_url}:latest" # TODO: replace with actual ECR image
    essential = true
    portMappings = [{
      containerPort = 8000
      hostPort      = 8000
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_app.name
        awslogs-region        = "us-east-1"
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
resource "aws_ecs_service" "app" {
  name            = "devops-trial-service"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  # Attach load balancer so ALB routes traffic to ECS tasks
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "fastapi"
    container_port   = 8000
  }

  # Define networking for the ECS task (VPC + Subnets + SGs)
  network_configuration {
    assign_public_ip = true
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.task_sg.id]
  }
}

############################################
# Auto Scaling
############################################
# TODO: Add Application Auto Scaling for ECS Service
#  - Target CPU utilization 70%
# IMPORTANT: Resource names must include "devops-trial-"
############################################
# Define scalable target — tells AWS which ECS service to scale
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.app.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
}

# Define scaling policy — how scaling happens (based on average CPU)
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "devops-trial-ecs-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension

  # Target tracking configuration — keep CPU near 70%
  target_tracking_scaling_policy_configuration {
    target_value = 70.0

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}


############################################
# Monitoring
############################################
# TODO: Add CloudWatch alarm for high CPU (>70%)
# IMPORTANT: Alarm name must start with "devops-trial-"
############################################
resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "devops-trial-ecs-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 60
  threshold           = 70
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"

  dimensions = {
    ClusterName = aws_ecs_cluster.app.name
    ServiceName = aws_ecs_service.app.name
  }

  treat_missing_data = "notBreaching"
}
