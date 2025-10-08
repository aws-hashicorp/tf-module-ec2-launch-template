output "launch_template_id" {
  description = "ID of the created launch template"
  value       = aws_launch_template.ec2_launch_template.id
}

output "launch_template_name" {
  description = "Name of the launch template"
  value       = aws_launch_template.ec2_launch_template.name
}