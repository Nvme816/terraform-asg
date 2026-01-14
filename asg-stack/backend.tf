
terraform {
  backend "s3" {
    bucket         = "tf-state-asg-ccfoundational-backend-us-east-1"
    key            = "asg-foundational/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
