# ### Provider ### #
aws_region = "us-east-1"

# ### ECR ### #
ecr_repo_name = "devops-trial-fastapi-app"

# ### ECS Cluster ### #
ecs_cluster_name = "devops-trial-cluster"
ecs_cluster_settings = [
  {
    name  = "containerInsights"
    value = "enabled"
  }
]

# ### ECS Task Definition ###
### IAM ###
task_iam_rule_name    = "devops-trial-ecsTaskExecutionRole"
task_iam_rule_version = "2012-10-17"
task_iam_rule_effect  = "Allow"
task_iam_rule_service = "ecs-tasks.amazonaws.com"
task_iam_rule_action  = "sts:AssumeRole"

### Security Group ###
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

### Policy Attachment ###
task_policy_attachment_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

### Task ###
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

### Service ###
service_name        = "devops-trial-service"
service_launch_type = "FARGATE"

### Service Autoscaling ###
autoscaling_max                = 3
autoscaling_min                = 1
autoscaling_service_namespace  = "ecs"
autoscaling_scalable_dimention = "ecs:service:DesiredCount"

### Service Policy ###
autoscaling_policy_name         = "devops-trial-ecs-scaling-policy"
autoscaling_policy_type         = "TargetTrackingScaling"
autoscaling_policy_target_value = 70
autoscaling_policy_metric_type  = "ECSServiceAverageCPUUtilization"


# ### Application Load Balancer ### #
### Security Group ###
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

### ALB ###
alb_name            = "devops-trial-alb"
alb_type            = "application"
alb_internal_facing = false

### Target Group ###
alb_tg_name     = "devops-trial-tg"
alb_tg_port     = 8000
alb_tg_protocol = "HTTP"
alb_tg_type     = "ip"

### Listener ###
alb_listener_port                = 80
alb_listener_protocol            = "HTTP"
alb_listener_default_action_type = "forward"

# ### Cloudwatch Alarm ### #
alarm_name                = "ECSServiceAverageCPUUtilization"
alarm_comparison_operator = "ECSServiceAverageCPUUtilization"
alarm_evaluation_periods  = 1
alarm_period              = 60
alarm_threshold           = 70
alarm_statistic           = "Average"
alarm_metric_name         = "CPUUtilization"
alarm_namespace           = "AWS/ECS"
alarm_treat_missing_data  = "notBreaching"