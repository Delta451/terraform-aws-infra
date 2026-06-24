# Launch Template for ASG
resource "aws_launch_template" "app" {
  name_prefix            = "app-"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.small"
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              yum update -y
              
              # Install web server
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              
              # Create a simple health check page
              cat > /var/www/html/index.html <<'EOFHTML'
              <!DOCTYPE html>
              <html>
              <head>
                <title>Welcome</title>
              </head>
              <body>
                <h1>Application Server</h1>
                <p>Instance ID: $(ec2-metadata --instance-id | cut -d " " -f 2)</p>
                <p>Availability Zone: $(ec2-metadata --availability-zone | cut -d " " -f 2)</p>
              </body>
              </html>
              EOFHTML
              
              # Install CloudWatch agent
              wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
              rpm -U ./amazon-cloudwatch-agent.rpm
              
              # Configure CloudWatch Logs
              cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'EOFCW'
              {
                "logs": {
                  "logs_collected": {
                    "files": {
                      "collect_list": [
                        {
                          "file_path": "/var/log/httpd/access_log",
                          "log_group_name": "/aws/ec2/app",
                          "log_stream_name": "{instance_id}/access"
                        },
                        {
                          "file_path": "/var/log/httpd/error_log",
                          "log_group_name": "/aws/ec2/app",
                          "log_stream_name": "{instance_id}/error"
                        }
                      ]
                    }
                  }
                }
              }
              EOFCW
              
              # Start CloudWatch agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
                -a fetch-config \
                -m ec2 \
                -s \
                -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-app-instance"
      Role = "app"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${var.project_name}-app-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = aws_subnet.private[*].id
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300

  min_size         = 2
  max_size         = 6
  desired_capacity = 2

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.main]
}

# Auto Scaling Policy - Scale Up
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

# Auto Scaling Policy - Scale Down
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}
