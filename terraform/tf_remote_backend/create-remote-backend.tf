# Backend Infrastructure
provider "aws" {
  region = "us-east-1"
}

# S3 bucket for Terraform state 
resource "aws_s3_bucket" "tf_state" {
  bucket = "devops-trial-terraform-state"
}

# Enable versioning for recovery
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB table for state locking 
resource "aws_dynamodb_table" "tf_lock" {
  name         = "devops-trial-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  hash_key = "LockID"
}
