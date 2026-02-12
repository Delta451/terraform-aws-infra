resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name      = "${var.project_name}-private-${count.index + 1}"
    Type      = "private"
    ManagedBy = "Terraform"
  }
}

