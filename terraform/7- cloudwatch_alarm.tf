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
