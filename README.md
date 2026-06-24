# Terraform AWS Infrastructure

Production-ready AWS infrastructure built with Terraform, featuring a highly available, scalable application deployment with comprehensive monitoring and security best practices.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet (0.0.0.0/0)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                    ┌────────▼────────┐
                    │   Internet      │
                    │   Gateway       │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
   ┌────▼────┐          ┌────▼────┐         ┌────▼────┐
   │ ALB     │          │Bastion  │         │  NAT    │
   │(Public) │          │(Public) │         │(Public) │
   └────┬────┘          └────┬────┘         └────┬────┘
        │                    │                    │
   ┌────▼─────────────────────┴────────────────────▼────┐
   │           VPC (10.0.0.0/16)                        │
   │                                                     │
   │  ┌──────────────┐          ┌──────────────┐       │
   │  │Public Subnet1│          │Public Subnet2│       │
   │  │10.0.1.0/24   │          │10.0.2.0/24   │       │
   │  └──────────────┘          └──────────────┘       │
   │                                                     │
   │  ┌────────────────────┐  ┌────────────────────┐   │
   │  │Private Subnet 1    │  │Private Subnet 2    │   │
   │  │10.0.3.0/24         │  │10.0.4.0/24         │   │
   │  │  ┌──────────────┐  │  │  ┌──────────────┐  │   │
   │  │  │  App Server  │  │  │  │  App Server  │  │   │
   │  │  │  (ASG)       │  │  │  │  (ASG)       │  │   │
   │  │  └──────────────┘  │  │  └──────────────┘  │   │
   │  └────────────────────┘  └────────────────────┘   │
   │                                                     │
   └─────────────────────────────────────────────────────┘
```

## Features

### Networking
- **VPC**: 10.0.0.0/16 CIDR block with DNS support
- **Public Subnets**: 2 subnets (10.0.1.0/24, 10.0.2.0/24) across AZs with auto-assigned public IPs
- **Private Subnets**: 2 subnets (10.0.3.0/24, 10.0.4.0/24) for application servers
- **Internet Gateway**: For internet connectivity
- **NAT Gateway**: Enables private subnet outbound internet access

### Security
- **Security Groups**: Least-privilege ingress rules
  - ALB: HTTP/HTTPS from internet
  - App: HTTP/HTTPS from ALB, SSH from Bastion
  - Bastion: SSH from internet (restrict in production)
  - Database: MySQL from app instances (for future use)
- **IAM Roles**: Fine-grained permissions for EC2 instances
  - CloudWatch Logs and Metrics permissions
  - SSM Session Manager access (secure shell alternative to SSH)

### Compute
- **Bastion Host**: Single EC2 instance in public subnet for secure access to private resources
  - Elastic IP for stable public addressing
  - Encrypted root volume
  - CloudWatch monitoring enabled
  
- **Application Servers**: Managed by Auto Scaling Group
  - Launch template with Apache httpd and CloudWatch agent
  - Deployed in private subnets (high availability)
  - Min 2, Max 6 instances with desired capacity of 2
  - Elastic Load Balancing health checks

### Load Balancing
- **Application Load Balancer**: Distributes traffic across app instances
  - Health checks: 30-second interval, 2-threshold for healthy/unhealthy
  - Session stickiness enabled (24-hour duration)
  - Cross-zone load balancing enabled
  - Support for HTTPS (requires certificate configuration)

### Monitoring & Logging
- **CloudWatch Logs**: Centralized logging
  - /aws/ec2/app: Application server logs (access/error)
  - /aws/ec2/bastion: Bastion host logs
  - /aws/alb/app: ALB access logs
  - 7-day retention on all logs

- **CloudWatch Alarms**: Comprehensive monitoring
  - ALB: unhealthy targets, response time, HTTP 5xx errors, request count
  - ASG: CPU utilization monitoring
  - Bastion: status checks, network traffic
  - All alarms include configurable thresholds and multiple evaluation periods

## File Structure

```
.
├── provider.tf              # AWS provider and version requirements
├── backend.tf               # S3 backend for remote state (requires manual setup)
├── variable.tf              # Input variables with defaults
├── vpc.tf                   # VPC and core networking
├── public_subnet.tf         # Public subnets configuration
├── private_subnet.tf        # Private subnets configuration
├── igw.tf                   # Internet Gateway
├── nat.tf                   # NAT Gateway and EIP
├── public_routes.tf         # Public route tables and associations
├── private_routes.tf        # Private route tables and associations
├── security_groups.tf       # All security groups with rules
├── iam.tf                   # IAM roles and policies
├── bastion.tf               # Bastion host EC2 instance
├── alb.tf                   # Application Load Balancer configuration
├── asg.tf                   # Launch template and Auto Scaling Group
├── monitoring.tf            # CloudWatch log groups and alarms
├── outputs.tf               # Output values for all resources
└── README.md                # This file
```

## Prerequisites

1. AWS Account with appropriate IAM permissions
2. Terraform >= 1.0 installed locally
3. AWS CLI configured with credentials
4. (Optional) S3 bucket and DynamoDB table for remote state

## Setup Instructions

### 1. Initialize Terraform

```bash
terraform init
```

If using S3 backend, create the S3 bucket and DynamoDB table first:

```bash
# Create S3 bucket for state (replace with your bucket name)
aws s3api create-bucket \
  --bucket terraform-aws-infra-state \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket terraform-aws-infra-state \
  --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ap-south-1
```

### 2. Validate Configuration

```bash
terraform validate
```

### 3. Format Code

```bash
terraform fmt -recursive
```

### 4. Plan Deployment

```bash
terraform plan -out=tfplan
```

### 5. Apply Configuration

```bash
terraform apply tfplan
```

### 6. View Outputs

```bash
terraform output -json
```

To get specific outputs:
```bash
terraform output alb_dns_name
terraform output bastion_public_ip
terraform output vpc_id
```

## Customization

### Modify Instance Sizes

Edit `variable.tf` or use `-var` flag:
```bash
terraform apply -var="instance_type=t3.medium"
```

### Change Availability Zones

Edit `variable.tf`:
```hcl
variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}
```

### Scale Application

Modify ASG settings in `asg.tf`:
```hcl
min_size         = 3
max_size         = 10
desired_capacity = 5
```

### Add HTTPS Support

1. Request/import ACM certificate in AWS
2. Add HTTPS listener to ALB in `alb.tf`
3. Configure certificate ARN

## Security Considerations

1. **Bastion SSH Access**: Restrict `0.0.0.0/0` to specific IP ranges in production
2. **State File**: Ensure S3 backend has encryption and versioning enabled
3. **IAM Permissions**: Review and limit IAM policy statements as needed
4. **Secrets Management**: Use AWS Secrets Manager for sensitive data
5. **Logging**: Enable VPC Flow Logs for network traffic analysis

## Monitoring & Troubleshooting

### Check Instance Health
```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names terraform-aws-asg \
  --region ap-south-1
```

### View ALB Targets
```bash
aws elbv2 describe-target-health \
  --target-group-arn <target-group-arn> \
  --region ap-south-1
```

### Access CloudWatch Logs
```bash
aws logs tail /aws/ec2/app --follow
aws logs tail /aws/ec2/bastion --follow
```

### SSH to Bastion and Private Instances
```bash
# SSH to bastion
ssh -i your-key.pem ec2-user@<bastion_public_ip>

# From bastion, SSH to private instance
ssh -i your-key.pem ec2-user@<private_instance_ip>
```

## Cost Optimization Tips

1. **Right-sizing**: Monitor CloudWatch metrics and adjust instance types
2. **Reserved Instances**: Consider for predictable, long-running workloads
3. **Spot Instances**: Modify ASG to use spot instances for cost savings
4. **Log Retention**: Adjust CloudWatch log retention based on needs
5. **NAT Gateway**: NAT Gateway charges per GB processed; optimize outbound traffic

## Cleanup

To destroy all infrastructure:

```bash
terraform destroy
```

This will remove all AWS resources created by Terraform. **Note**: S3 and DynamoDB resources for backend state are NOT destroyed.

## Best Practices Implemented

✅ Infrastructure as Code (IaC) with Terraform  
✅ High Availability across multiple AZs  
✅ Modular file organization by resource type  
✅ Comprehensive outputs for integration  
✅ Security group rules following least privilege  
✅ IAM roles with minimal required permissions  
✅ CloudWatch monitoring and alarms  
✅ Centralized logging  
✅ Auto Scaling with health checks  
✅ Encrypted volumes  
✅ Resource tagging for cost allocation  
✅ State locking to prevent concurrent modifications  
✅ Provider versioning for consistency  

## Future Enhancements

- [ ] RDS database integration
- [ ] ElastiCache for caching layer
- [ ] S3 bucket with CloudFront CDN
- [ ] WAF rules for ALB
- [ ] VPC endpoints for AWS services
- [ ] Multi-environment setup (dev, staging, prod)
- [ ] Terraform modules for reusability
- [ ] CI/CD pipeline integration
- [ ] Backup and disaster recovery setup

## Contributing

When making changes:
1. Follow the existing code style and formatting
2. Add meaningful commit messages grouped by feature
3. Update this README with significant changes
4. Test with `terraform plan` before applying
5. Review security implications of changes

## License

This project is provided as-is for educational and demonstration purposes.

## Support

For issues or questions:
1. Review the Architecture Overview section
2. Check CloudWatch logs for application errors
3. Use `terraform state list` to verify resources
4. Consult AWS documentation for service-specific issues
