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