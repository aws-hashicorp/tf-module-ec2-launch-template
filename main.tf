# Security Group
resource "aws_security_group" "this" {
  count  = var.existing_sg_id == "" ? 1 : 0
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-sg" })
}
# IAM Role
resource "aws_iam_role" "iam_ec2_role" {
  name               = "ec2-Role-${var.name}"
  assume_role_policy = file("${path.module}/policies/ec2-trusted_policy.json")

  tags = var.tags
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.iam_ec2_role.name
}

# Attach Policies
resource "aws_iam_role_policy_attachment" "role_policy_attach" {
  role       = aws_iam_role.iam_ec2_role.name
  count      = length(var.permissions_name)
  policy_arn = element(data.aws_iam_policy.role_permissions_data.*.id, count.index)
}

# Launch Template
resource "aws_launch_template" "this" {
  name_prefix            = var.name
  image_id               = var.ami_id
  instance_type          = var.instance_type
  update_default_version = true

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  # Volumen raíz
  block_device_mappings {
    device_name = var.root_volume_device_name
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = var.ebs_delete_on_termination
      encrypted             = var.ebs_encrypted
    }
  }
  # Volúmenes EBS adicionales (dinámicos)
  dynamic "block_device_mappings" {
    for_each = var.additional_volumes
    content {
      device_name = lookup(block_device_mappings.value, "device_name", null)
      ebs {
        volume_size           = lookup(block_device_mappings.value, "size", 10)
        volume_type           = lookup(block_device_mappings.value, "type", "gp3")
        delete_on_termination = lookup(block_device_mappings.value, "delete_on_termination", true)
        encrypted             = lookup(block_device_mappings.value, "encrypted", true)
      }
    }
  }

  dynamic "network_interfaces" {
    for_each = var.create_autoscaling_group ? [1] : []
    content {
      associate_public_ip_address = false
      subnet_id                   = null
      security_groups             = [var.existing_sg_id != "" ? var.existing_sg_id : aws_security_group.this[0].id]
      delete_on_termination       = true
      private_ip_address          = length(var.private_ips) > 0 ? var.private_ips[0] : null
    }
  }
  user_data = var.user_data != "" ? base64encode(var.user_data) : null

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = "${var.name}"
      },
      var.tags
    )
  }
}

# EC2 Instances
resource "aws_instance" "this" {
  count = var.create_autoscaling_group ? 0 : var.instance_count

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  subnet_id              = element(var.subnet_ids, count.index % length(var.subnet_ids))
  vpc_security_group_ids = [var.existing_sg_id != "" ? var.existing_sg_id : aws_security_group.this[0].id]
  private_ip             = length(var.private_ips) > count.index ? var.private_ips[count.index] : null

  tags = merge(var.tags, { Name = "${var.name}-${count.index + 1}" })
}

# Target Group (optional)
resource "aws_lb_target_group" "this" {
  count = var.create_autoscaling_group || var.create_target_group ? 1 : 0

  name        = "tg-${var.name}"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
    path                = var.health_check_path
  }
}

resource "aws_lb_target_group_attachment" "this" {
  count = (!var.create_autoscaling_group && var.create_target_group) ? length(aws_instance.this) : 0

  target_group_arn = aws_lb_target_group.this[0].arn
  target_id        = aws_instance.this[count.index].id
  port             = var.target_group_port

  depends_on = [aws_lb_target_group.this, aws_instance.this]
}

# Autoscaling Group (optional, inactive by default)
resource "aws_autoscaling_group" "this" {
  count            = var.create_autoscaling_group ? 1 : 0
  name             = "asg-${var.name}"
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size
  min_size         = var.asg_min_size

  vpc_zone_identifier = var.subnet_ids
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  target_group_arns         = var.create_autoscaling_group || var.create_target_group ? aws_lb_target_group.this[*].arn : []
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  depends_on                = [aws_lb_target_group.this]
}

resource "aws_lb_listener_rule" "tg_attachment" {
  count = (
    var.create_listener_rule &&
    (var.create_target_group || var.create_autoscaling_group)
  ) ? 1 : 0

  listener_arn = var.alb_listener_arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  condition {
    path_pattern {
      values = var.listener_rule_path_patterns
    }
  }

  tags = merge(var.tags, {
    Name = "tg-attachment-${var.name}"
  })
}
