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