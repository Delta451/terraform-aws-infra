# Backend configuration for remote state management with S3 and DynamoDB
terraform {
  backend "s3" {
    bucket           = "terraform-aws-infra-state"
    key              = "prod/terraform.tfstate"
    region           = "ap-south-1"
    encrypt          = true
    dynamodb_table   = "terraform-locks"
  }
}
