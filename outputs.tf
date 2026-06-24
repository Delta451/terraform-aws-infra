# Output for VPC
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Outputs for Public Subnets
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

# Outputs for Private Subnets
output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

# Outputs for Internet Gateway
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

# Outputs for NAT Gateway
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "nat_gateway_eip" {
  description = "Elastic IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

# Outputs for Security Groups
output "alb_security_group_id" {
  description = "Security group ID for ALB"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID for application instances"
  value       = aws_security_group.app.id
}

output "bastion_security_group_id" {
  description = "Security group ID for bastion host"
  value       = aws_security_group.bastion.id
}

output "database_security_group_id" {
  description = "Security group ID for database"
  value       = aws_security_group.database.id
}

# Outputs for IAM Roles
output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "bastion_role_arn" {
  description = "ARN of the Bastion IAM role"
  value       = aws_iam_role.bastion_role.arn
}

output "bastion_instance_profile_name" {
  description = "Name of the Bastion instance profile"
  value       = aws_iam_instance_profile.bastion_profile.name
}

# Outputs for Bastion
output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion instance"
  value       = aws_instance.bastion.private_ip
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion instance"
  value       = aws_eip.bastion.public_ip
}

# Outputs for Application Load Balancer
output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

# Outputs for Target Group
output "target_group_id" {
  description = "ID of the ALB target group"
  value       = aws_lb_target_group.app.id
}

output "target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.app.arn
}

# Outputs for Launch Template
output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.app.latest_version_number
}

# Outputs for Auto Scaling Group
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
}

# Outputs for CloudWatch
output "app_log_group_name" {
  description = "Name of the CloudWatch log group for application"
  value       = aws_cloudwatch_log_group.app.name
}

output "bastion_log_group_name" {
  description = "Name of the CloudWatch log group for bastion"
  value       = aws_cloudwatch_log_group.bastion.name
}

output "alb_log_group_name" {
  description = "Name of the CloudWatch log group for ALB"
  value       = aws_cloudwatch_log_group.alb.name
}

# Summary Output
output "summary" {
  description = "Summary of the infrastructure"
  value = {
    environment           = var.environment
    region                = var.region
    vpc_id                = aws_vpc.main.id
    alb_dns               = aws_lb.main.dns_name
    bastion_ip            = aws_eip.bastion.public_ip
    asg_desired_capacity  = aws_autoscaling_group.app.desired_capacity
    asg_min_capacity      = aws_autoscaling_group.app.min_size
    asg_max_capacity      = aws_autoscaling_group.app.max_size
  }
}
