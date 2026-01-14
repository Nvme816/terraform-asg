
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "cc-asg-foundational"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 5
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "http_port" {
  type    = number
  default = 80
}

# Optional: allow SSH only from a trusted IP CIDR if needed (leave null to disable SSH)
variable "ssh_cidr" {
  type        = string
  default     = null
  description = "Example: 203.0.113.10/32"
}
