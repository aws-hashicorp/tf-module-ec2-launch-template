output "launch_template_id" { 
  value = aws_launch_template.this.id 
  }
output "instance_ids" { 
  value = [for i in aws_instance.this : i.id] 
  }
output "security_group_id" {
  value = var.existing_sg_id != "" ? var.existing_sg_id : (length(aws_security_group.this) > 0 ? aws_security_group.this[0].id : null)
}
