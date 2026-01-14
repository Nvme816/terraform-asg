
output "default_vpc_id" {
  value = data.aws_vpc.default.id
}

output "selected_subnet_ids" {
  value = local.selected_subnet_ids
}

output "asg_name" {
  value = aws_autoscaling_group.web_asg.name
}

output "web_security_group_id" {
  value = aws_security_group.web_sg.id
}
