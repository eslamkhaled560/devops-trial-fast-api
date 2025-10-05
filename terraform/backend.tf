terraform {
  backend "s3" {
    bucket         = "devops-trial-terraform-state"
    key            = "ecs/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-trial-terraform-locks"
    encrypt        = true
  }
}
