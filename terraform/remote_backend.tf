# Backend Infrastructure

# S3 bucket for Terraform remote state
resource "aws_s3_bucket" "tf_state" {
  bucket = "devops-trial-tf-backend-state"
}

# Enable versioning for Terraform state safety
resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = "devops-trial-tf-backend-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "devops-trial-tf-backend-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-trial-tf-backend-locks"
    encrypt        = true
  }
}

###islamkhaledaws@gmail.com configuration###
###old account - not use as there is a problem creating alb###
###contacted support but it will take time to be resolved###
# # S3 bucket for Terraform state 
# resource "aws_s3_bucket" "tf_state" {
#   bucket = "devops-trial-terraform-state"
# }

# # Enable versioning for recovery
# resource "aws_s3_bucket_versioning" "versioning" {
#   bucket = aws_s3_bucket.tf_state.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# # DynamoDB table for state locking 
# resource "aws_dynamodb_table" "tf_lock" {
#   name         = "devops-trial-terraform-locks"
#   billing_mode = "PAY_PER_REQUEST"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   hash_key = "LockID"
# }


# # terraform {
# #   backend "s3" {
# #     bucket         = "devops-trial-terraform-state"
# #     key            = "ecs/terraform.tfstate"
# #     region         = "us-east-1"
# #     dynamodb_table = "devops-trial-terraform-locks"
# #     encrypt        = true
# #   }
# # }
