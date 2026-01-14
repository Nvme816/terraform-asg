
data "aws_vpc" "default" {
  default = true
}

# Pull all subnets in the default VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get full details for each subnet so it can be filtered and sorted
data "aws_subnet" "subnet_details" {
  for_each = toset(data.aws_subnets.default_vpc_subnets.ids)
  id       = each.value
}

# Choose up to 2 PUBLIC subnets (map_public_ip_on_launch = true), prefer different AZs
locals {
  public_subnets = [
    for s in data.aws_subnet.subnet_details :
    s if s.map_public_ip_on_launch
  ]

  # Sort for stable selection
  public_subnet_ids_sorted = sort([for s in local.public_subnets : s.id])

  # Take first two public subnet IDs
  selected_subnet_ids = slice(local.public_subnet_ids_sorted, 0, 2)
}

# Security group for the web instances
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Allow HTTP from internet to ASG instances"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from internet"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from internet IPv6"
    from_port        = var.http_port
    to_port          = var.http_port
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  dynamic "ingress" {
    for_each = var.ssh_cidr == null ? [] : [var.ssh_cidr]
    content {
      description = "Optional SSH from trusted CIDR"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-web-sg"
    Project = var.project_name
  }
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.al2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(file("${path.module}/userdata.sh"))

  # Basic hardening defaults
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # Enforce IMDSv2
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project_name}-web"
      Project = var.project_name
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = local.selected_subnet_ids

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
