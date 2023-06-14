# Create a Launch Configuration -----------------------------------------------
resource "aws_launch_template" "autoscaling_launch_template" {
  name_prefix            = var.terraform_name_prefix
  image_id               = var.amazon_linux_image
  instance_type          = var.ec2_instance_type
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.iam_instance_profile.name
  }
  tags = {
    Name = "autoscaling_launch_template"
  }

  vpc_security_group_ids = [aws_security_group.allow_sec1.id]

  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    systemctl enable nginx --now
    sudo amazon-linux-extras install epel -y
    sudo yum install stress -y
    stress --cpu 50
    EOF
  )
}

# Create a ASG ----------------------------------------------------------------
resource "aws_autoscaling_group" "asg-to" {
  name                = "terraform-asg"
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.terraform_sub3.id, aws_subnet.terraform_sub4.id]
  target_group_arns   = [aws_lb_target_group.alb-target.arn]
  launch_template {
    id      = aws_launch_template.autoscaling_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "ec2-instances"
    propagate_at_launch = true
  }
}

# Cloudwatch config -----------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_usage_alarm" {
  alarm_name          = var.cloudwatch_cpu_alarm_name
  comparison_operator = var.cloudwatch_cpu_comparison_operator
  evaluation_periods  = 1
  metric_name         = var.cloudwatch_cpu_alarm_metric
  namespace           = var.cloudwatch_cpu_alarm_namespace
  period              = 60
  statistic           = var.cloudwatch_cpu_monitoring_statistic
  threshold           = 70
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.autoscaling_policy.arn, aws_sns_topic.cpu_usage_topic.arn]
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.asg-to.name
  }
}

# Attach Policy ---------------------------------------------------------------
resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = aws_autoscaling_group.asg-to.id
  lb_target_group_arn    = aws_lb_target_group.alb-target.arn
}

resource "aws_cloudwatch_metric_alarm" "ram_usage_alarm" {
  alarm_name          = "ram-usage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUsed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm triggered when RAM usage exceeds 70%"
  alarm_actions       = [aws_autoscaling_policy.autoscaling_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg-to.name
  }
}