resource "aws_iam_role" "ssm_self_made" {
  name = "ssm-mgmt"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    name = "role"
  }
}


resource "aws_iam_role_policy_attachment" "ssm_mgmt_attachment" {
  role       = aws_iam_role.ssm_self_made.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_cpu_monitoring_attachment" {
  role       = aws_iam_role.ssm_self_made.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}


resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "instance-profile"
  role = aws_iam_role.ssm_self_made.name
  tags = {
    name = "profile"
  }
}

# Create Auto Scale Policy ----------------------------------------------------
resource "aws_autoscaling_policy" "autoscaling_policy" {
  name                   = var.autoscaling_policy_name
  scaling_adjustment     = 1
  adjustment_type        = var.autoscaling_adjustment_type
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.asg-to.name
}


