# ### Provider ###
aws_region = "us-east-1"

# ### ECR ###
ecr_repo_name = "devops-trial-fastapi-app"

# ### ECS Cluster ###
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
task_cloudwatch_log_group_name = "/ecs/devops-trial-fastapi"
task_cloudwatch_log_group_retention = 7
task_family = "devops-trial-fastapi-task"

## Application Load Balancer ###
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
