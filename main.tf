# Security Group
resource "aws_security_group" "sg_ec2_service" {
  count = var.existing_sg_id == "" ? 1 : 0  # 👈 solo crea si no hay SG previo
  name   = "${var.name_prefix}-sg"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_cidrs != null && length(var.allowed_cidrs) > 0 ? [1] : []
    content {
      from_port   = var.sg_listener_port_from
      to_port     = var.sg_listener_port_to
      protocol    = var.sg_listener_protocol
      cidr_blocks = var.allowed_cidrs
    }
  }

  dynamic "ingress" {
    for_each = var.allowed_security_groups != null && length(var.allowed_security_groups) > 0 ? [1] : []
    content {
      from_port       = var.sg_listener_port_from
      to_port         = var.sg_listener_port_to
      protocol        = var.sg_listener_protocol
      security_groups = var.allowed_security_groups
      description     = "Allow from security groups"
    }
  }
  
  dynamic "ingress" {
    for_each = var.allowed_prefix_list_ids != null && length(var.allowed_prefix_list_ids) > 0 ? [1] : []
    content {
      from_port       = var.sg_listener_port_from
      to_port         = var.sg_listener_port_to
      protocol        = var.sg_listener_protocol
      prefix_list_ids = var.allowed_prefix_list_ids
      description     = "Allow from prefix lists"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg" })
}

# IAM Role
resource "aws_iam_role" "iam_ec2_role" {
  name               = "ec2-Role-${var.name_prefix}"
  assume_role_policy = file("${path.module}/policies/ec2-trusted_policy.json")

  tags = var.tags
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.name_prefix}-instance-profile"
  role = aws_iam_role.iam_ec2_role.name
}

# Attach Policies
resource "aws_iam_role_policy_attachment" "role_policy_attach" {
  role       = aws_iam_role.iam_ec2_role.name
  count      = length(var.permissions_name)
  policy_arn = element(data.aws_iam_policy.role_permissions_data.*.id, count.index)
}

#launch_template
resource "aws_launch_template" "ec2_launch_template" {
  name_prefix   = "${var.name_prefix}-sg"
  image_id      = var.ami_id
  instance_type = var.instance_type
  update_default_version = var.update_default_version

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  # Volumen raíz
  block_device_mappings {
    device_name = var.root_volume_device_name

    ebs {
      volume_size = var.root_volume_size
      volume_type = var.root_volume_type
      delete_on_termination = var.ebs_delete_on_termination
      encrypted   = var.ebs_encrypted
    }
  }
  # Volumen EBS adicional opcional
  dynamic "block_device_mappings" {
    for_each = var.additional_ebs_enabled ? [1] : []
    content {
      device_name = var.additional_ebs_device_name
      ebs {
        volume_size = var.additional_ebs_size
        volume_type = var.additional_ebs_type
        delete_on_termination = var.additional_ebs_delete_on_termination
        encrypted   = var.ebs_encrypted
      }
    }
  }
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = "${var.name_prefix}-instance"
      },
      var.tags
    )
  }
}

resource "aws_instance" "ec2_instances" {
  count = var.count_instances

  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
  subnet_id  = element(var.subnet_ids, count.index % length(var.subnet_ids))

  vpc_security_group_ids = [var.existing_sg_id != "" ? var.existing_sg_id : aws_security_group.sg_ec2_service[0].id]

  
  tags = {
    Name = "${var.name_prefix}-${count.index + 1}"
  }
}