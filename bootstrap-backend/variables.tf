
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform remote state"
  default = "tf-state-asg-ccfoundational-us-east-1"
}

variable "state_lock_table_name" {
  type        = string
  description = "DynamoDB table name for Terraform state locking"

  default = "terraform-state-locks"
}
