############################################
# AWS Provider
############################################
aws_region = "us-east-1"

############################################
# ECR Repository
############################################
ecr_repo_name = "devops-trial-fastapi-app"

############################################
# ECS Cluster
############################################
ecs_cluster_name = "devops-trial-cluster"
ecs_cluster_settings = [
  {
    name  = "containerInsights"
    value = "enabled"
  }
]

############################################
# ECS Task Definition
############################################

# IAM Role for ECS Task Execution
task_iam_rule_name    = "devops-trial-ecsTaskExecutionRole"
task_iam_rule_version = "2012-10-17"
task_iam_rule_effect  = "Allow"
task_iam_rule_service = "ecs-tasks.amazonaws.com"
task_iam_rule_action  = "sts:AssumeRole"

# Security Group for ECS Task
task_sg_name = "devops-trial-task-sg"
task_ingress_rules = [
  {
    description = "Allow inbound app traffic from ALB"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
  }
]
task_egress_rules = [
  {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
]

# Policy Attachment for ECS Task IAM Role
task_policy_attachment_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

# ECS Task Definition
task_cloudwatch_log_group_name      = "/ecs/devops-trial-fastapi"
task_cloudwatch_log_group_retention = 7
task_family                         = "devops-trial-fastapi-task"
task_launch_type                    = ["FARGATE"]
task_cpu                            = "256"
task_memory                         = "512"
task_network_mode                   = "awsvpc"
task_container_name                 = "fastapi"
task_container_essential            = true
task_container_port                 = 8000
task_host_port                      = 8000

############################################
# ECS Service
############################################
service_name        = "devops-trial-service"
service_launch_type = "FARGATE"

############################################
# Auto Scaling
############################################
autoscaling_max                = 3
autoscaling_min                = 1
autoscaling_service_namespace  = "ecs"
autoscaling_scalable_dimention = "ecs:service:DesiredCount"

# Autoscaling policy based on average CPU
autoscaling_policy_name         = "devops-trial-ecs-scaling-policy"
autoscaling_policy_type         = "TargetTrackingScaling"
autoscaling_policy_target_value = 70
autoscaling_policy_metric_type  = "ECSServiceAverageCPUUtilization"


############################################
# Load Balancer
############################################

# Security Group for Application Load Balancer
alb_sg_name = "devops-trial-alb-sg"
alb_ingress_rules = [
  {
    description      = "Allow HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
]
alb_egress_rules = [
  {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
]

# Application Load Balancer
alb_name            = "devops-trial-alb"
alb_type            = "application"
alb_internal_facing = false

# Target Group for ECS Task
alb_tg_name     = "devops-trial-tg"
alb_tg_port     = 8000
alb_tg_protocol = "HTTP"
alb_tg_type     = "ip"

# Listener (HTTP forward to target group)
alb_listener_port                = 80
alb_listener_protocol            = "HTTP"
alb_listener_default_action_type = "forward"

############################################
# Cloudwatch Alarm
############################################
alarm_name                = "devops-trial-ecs-high-cpu"
alarm_comparison_operator = "GreaterThanOrEqualToThreshold"
alarm_evaluation_periods  = 1
alarm_period              = 60
alarm_threshold           = 70
alarm_statistic           = "Average"
alarm_metric_name         = "CPUUtilization"
alarm_namespace           = "AWS/ECS"
alarm_treat_missing_data  = "notBreaching"