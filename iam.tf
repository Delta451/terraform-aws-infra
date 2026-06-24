# IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name_prefix = "ec2-app-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# IAM policy for CloudWatch logs
resource "aws_iam_role_policy" "cloudwatch_logs" {
  name_prefix = "cloudwatch-logs-"
  role        = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM policy for CloudWatch metrics and monitoring
resource "aws_iam_role_policy" "cloudwatch_metrics" {
  name_prefix = "cloudwatch-metrics-"
  role        = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM policy for SSM Session Manager (optional but recommended)
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile for EC2 instances
resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "ec2-app-profile-"
  role        = aws_iam_role.ec2_role.name

  lifecycle {
    create_before_destroy = true
  }
}

# IAM role for bastion host
resource "aws_iam_role" "bastion_role" {
  name_prefix = "bastion-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-bastion-role"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# IAM policy for bastion CloudWatch logs
resource "aws_iam_role_policy" "bastion_cloudwatch_logs" {
  name_prefix = "bastion-cloudwatch-logs-"
  role        = aws_iam_role.bastion_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM policy for bastion SSM Session Manager
resource "aws_iam_role_policy_attachment" "bastion_ssm_managed_instance_core" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile for bastion
resource "aws_iam_instance_profile" "bastion_profile" {
  name_prefix = "bastion-profile-"
  role        = aws_iam_role.bastion_role.name

  lifecycle {
    create_before_destroy = true
  }
}
