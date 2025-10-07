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