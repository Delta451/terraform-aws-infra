# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ec2/app"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-app-logs"
  }
}

resource "aws_cloudwatch_log_group" "bastion" {
  name              = "/aws/ec2/bastion"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-bastion-logs"
  }
}

resource "aws_cloudwatch_log_group" "alb" {
  name              = "/aws/alb/app"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-alb-logs"
  }
}

# CloudWatch Alarms - ALB Target Group Health
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${var.project_name}-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alert when ALB has unhealthy targets"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_healthy_hosts" {
  alarm_name          = "${var.project_name}-alb-healthy-hosts-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alert when healthy host count is critically low"
  treat_missing_data  = "breaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }
}

# CloudWatch Alarms - ALB Request Count
resource "aws_cloudwatch_metric_alarm" "alb_request_count_high" {
  alarm_name          = "${var.project_name}-alb-request-count-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1000"
  alarm_description   = "Alert when request count exceeds threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

# CloudWatch Alarms - ALB Response Time
resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  alarm_name          = "${var.project_name}-alb-target-response-time-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Alert when target response time exceeds 1 second"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

# CloudWatch Alarms - ALB HTTP 5xx Errors
resource "aws_cloudwatch_metric_alarm" "alb_http_5xx" {
  alarm_name          = "${var.project_name}-alb-http-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert when 5xx errors exceed threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

# CloudWatch Alarms - ASG CPU Utilization
resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "${var.project_name}-asg-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "Alert when average CPU utilization exceeds 70%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

# CloudWatch Alarms - Bastion Instance Status
resource "aws_cloudwatch_metric_alarm" "bastion_status_check_failed" {
  alarm_name          = "${var.project_name}-bastion-status-check-failed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Alert when bastion instance status check fails"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.bastion.id
  }
}

# CloudWatch Alarms - Bastion Network Traffic
resource "aws_cloudwatch_metric_alarm" "bastion_network_in" {
  alarm_name          = "${var.project_name}-bastion-network-in-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "NetworkIn"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "10000000"
  alarm_description   = "Alert when bastion inbound network traffic is high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.bastion.id
  }
}
