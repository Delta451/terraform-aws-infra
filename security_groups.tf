# Security group for ALB (Application Load Balancer)
resource "aws_security_group" "alb" {
  name_prefix = "alb-"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All traffic outbound"
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for EC2 instances in ASG
resource "aws_security_group" "app" {
  name_prefix = "app-"
  description = "Security group for application instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "HTTP from ALB"
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "HTTPS from ALB"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
    description     = "SSH from Bastion"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All traffic outbound"
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for Bastion host
resource "aws_security_group" "bastion" {
  name_prefix = "bastion-"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH from internet (restrict in production)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All traffic outbound"
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for RDS (optional future use)
resource "aws_security_group" "database" {
  name_prefix = "database-"
  description = "Security group for database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
    description     = "MySQL from application instances"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All traffic outbound"
  }

  tags = {
    Name = "${var.project_name}-database-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}
