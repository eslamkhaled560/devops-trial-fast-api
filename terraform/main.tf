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

############################################
# ECS Cluster
############################################
resource "aws_ecs_cluster" "app" {
  name = var.ecs_cluster_name

  # Enables ECS metrics & logs in CloudWatch
  dynamic "setting" {
    for_each = var.ecs_cluster_settings
    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }
}

############################################
# IAM Role for ECS Task Execution
############################################
resource "aws_iam_role" "ecs_task_execution" {
  name = var.task_iam_rule_name
  assume_role_policy = jsonencode({
    Version = var.task_iam_rule_version
    Statement = [{
      Effect = var.task_iam_rule_effect
      Principal = {
        Service = var.task_iam_rule_service
      }
      Action = var.task_iam_rule_action
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = var.task_policy_attachment_arn
}

############################################
# Networking & Security Groups
############################################

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
  name        = var.alb_sg_name
  description = "Allow inbound HTTP (80) from anywhere"
  vpc_id      = data.aws_vpc.default.id

  # Inbound rule HTTP from anywhere
  dynamic "ingress" {
    for_each = var.alb_ingress_rules
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
    }
  }

  # Outbound rule allow all
  dynamic "egress" {
    for_each = var.alb_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }
}

# Security Group for ECS Task
resource "aws_security_group" "task_sg" {
  name        = var.task_sg_name
  description = "Allow inbound 8000 only from ALB SG"
  vpc_id      = data.aws_vpc.default.id

  # Inbound only from ALB SG
  dynamic "ingress" {
    for_each = var.task_ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      security_groups = [aws_security_group.alb_sg.id]
    }
  }

  # Outbound allow all
  dynamic "egress" {
    for_each = var.task_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }
}

############################################
# Load Balancer
############################################

# Application Load Balancer
resource "aws_lb" "app_alb" {
  name               = var.alb_name
  load_balancer_type = var.alb_type
  internal           = var.alb_internal_facing
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# Target Group for ECS Task
resource "aws_lb_target_group" "ecs_tg" {
  name        = var.alb_tg_name
  port        = var.alb_tg_port
  protocol    = var.alb_tg_protocol
  target_type = var.alb_tg_type
  vpc_id      = data.aws_vpc.default.id

  health_check {
    path = "/"
  }
}

# Listener (HTTP forward to target group)
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = var.alb_listener_port
  protocol          = var.alb_listener_protocol

  default_action {
    type             = var.alb_listener_default_action_type
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}


############################################
# ECS Task Definition
############################################
resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = var.task_cloudwatch_log_group_name
  retention_in_days = var.task_cloudwatch_log_group_retention
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.task_family
  requires_compatibilities = var.task_launch_type
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = var.task_network_mode
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = var.task_container_name
    image     = var.image_uri
    essential = var.task_container_essential
    portMappings = [{
      containerPort = var.task_container_port
      hostPort      = var.task_host_port
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs_app.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

############################################
# ECS Service
############################################
resource "aws_ecs_service" "app" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = var.service_launch_type
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = var.task_container_name
    container_port   = var.task_container_port
  }

  network_configuration {
    assign_public_ip = true
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.task_sg.id]
  }
}

############################################
# Auto Scaling
############################################

# Define scalable target — tells AWS which ECS service to scale
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.autoscaling_max
  min_capacity       = var.autoscaling_min
  service_namespace  = var.autoscaling_service_namespace
  resource_id        = "service/${aws_ecs_cluster.app.name}/${aws_ecs_service.app.name}"
  scalable_dimension = var.autoscaling_scalable_dimention
}

# Autoscaling policy based on average CPU
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = var.autoscaling_policy_name
  policy_type        = var.autoscaling_policy_type
  service_namespace  = var.autoscaling_service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension

  # Target tracking configuration — keep CPU near 70%
  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling_policy_target_value

    predefined_metric_specification {
      predefined_metric_type = var.autoscaling_policy_metric_type
    }
  }
}


############################################
# Cloudwatch Alarm
############################################

# CloudWatch alarm for high CPU (>=70%)
resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = var.alarm_name
  comparison_operator = var.alarm_comparison_operator
  evaluation_periods  = var.alarm_evaluation_periods
  period              = var.alarm_period
  threshold           = var.alarm_threshold
  statistic           = var.alarm_statistic
  metric_name         = var.alarm_metric_name
  namespace           = var.alarm_namespace

  dimensions = {
    ClusterName = aws_ecs_cluster.app.name
    ServiceName = aws_ecs_service.app.name
  }

  treat_missing_data = var.alarm_treat_missing_data
}
