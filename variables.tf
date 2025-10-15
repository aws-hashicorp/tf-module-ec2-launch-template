variable "name" {
  description = "Base name for resources"
  type        = string
  default = ""
}
variable "ami_id" {
  description = "AMI ID"
  type        = string
  default = ""
}
variable "instance_type" {
  description = "Instance type"
  type        = string
  default     = "t3.micro"
}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default = ""
}
variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}
variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}
variable "existing_sg_id" {
  description = "Existing SG ID to reuse"
  type        = string
  default     = ""
}

variable "ingress_rules" {
  description = "Ingress rules for SG"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

variable "egress_rules" {
  description = "Egress rules for SG"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
  ]
}

# --- IAM Role Variables ---
variable "permissions_name" {
  description = "List name of policies for role"
  type        = list(string)
  default     = []
}

# --- Root volume configuration ---
variable "root_volume_device_name" {
  description = "Root volume device name"
  type        = string
  default     = "/dev/xvda"
}

variable "root_volume_size" {
  description = "Root volume size (GB)"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}
variable "ebs_delete_on_termination" {
  description = "delete_on_termination the EBS volume"
  type        = bool
  default     = true
}
# --- Additional EBS volume configuration ---
variable "create_additional_ebs" {
  description = "Whether to create an extra EBS volume"
  type        = bool
  default     = false
}
variable "additional_ebs_device_name" {
  description = "Extra EBS device name"
  type        = string
  default     = "/dev/sdb"
}
variable "additional_ebs_size" {
  description = "Extra EBS size (GB)"
  type        = number
  default     = 20
}
variable "additional_ebs_type" {
  description = "Extra EBS type"
  type        = string
  default     = "gp3"
}
variable "additional_ebs_delete_on_termination" {
  description = "Whether to delete the EBS volume on instance termination"
  type        = bool
  default     = true
}
variable "ebs_encrypted" {
  description = "Whether to encrypt the EBS volume"
  type        = bool
  default     = true
}
# --- Target Group Variables ---
variable "target_group_port" {
  description = "Target Group port"
  type        = number
  default     = 80
}
variable "target_group_protocol" {
  description = "Target Group protocol"
  type        = string
  default     = "HTTP"
}
variable "health_check_timeout" {
  description = "The timeout for the health check"
  type        = number
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "The unhealthy threshold for the health check"
  type        = number
  default     = 2
}

variable "health_check_healthy_threshold" {
  description = "The healthy threshold for the health check"
  type        = number
  default = 2
}

variable "health_check_interval" {
  description = "The interval for the health check"
  type        = number
  default = 30
}

variable "health_check_protocol" {
  description = "The protocol for the health check"
  type        = string
  default = "HTTP"
}

variable "health_check_matcher" {
  description = "The port for the health check"
  type        = string
  default = "200"
}

variable "health_check_path" {
  description = "The path for the health check"
  type        = string
  default = "/"
}

# Auto Scaling Variables
variable "create_autoscaling_group" {
  description = "Whether to create ASG"
  type        = bool
  default     = false
}
variable "health_check_type" {
  type        = string
  description = "Tipo de health check para el Auto Scaling Group (EC2 o ELB)"
  default     = "EC2"
}

variable "health_check_grace_period" {
  type        = number
  description = "Tiempo de gracia (en segundos) para que las instancias se marquen como saludables en el ASG"
  default     = 300
}

variable "asg_min_size" {
  description = "ASG min size"
  type        = number
  default     = 0
}
variable "asg_max_size" {
  description = "ASG max size"
  type        = number
  default     = 0
}
variable "asg_desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}


variable "user_data" {
  description = "Script de inicialización (en texto plano, no codificado en base64)."
  type        = string
  default     = ""
}