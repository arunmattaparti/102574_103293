# Backend configuration for remote state management
# Uncomment and configure with your specific values

terraform {
  backend "s3" {
    # bucket         = "your-terraform-state-bucket"
    # key            = "ecs-infrastructure/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true
  }
}

# Instructions:
# 1. Create an S3 bucket for storing state
# 2. Create a DynamoDB table with a primary key named "LockID" for state locking
# 3. Uncomment and fill in the values above
# 4. Run terraform init to initialize the backend