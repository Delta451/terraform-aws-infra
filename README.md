# terraform-aws-infra

Terraform configuration for AWS infrastructure, starting with a primary VPC definition and related outputs.

## Current Infrastructure

- VPC with DNS support
- Public subnets across two availability zones
- Internet Gateway with public routing
- Private subnets for backend workloads
- NAT Gateway for outbound internet access
