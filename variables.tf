# --- Global Variables ---
variable "name_prefix" {
  description = "Prefix for the launch template name"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

# --- Security Group Variables ---
variable "existing_sg_id" {
  description = "ID del Security Group existente (si ya hay uno)"
  type        = string
  default     = ""
}
variable "allowed_cidrs" {
  description = "The CIDR blocks to allow"
  type        = list(string)
  default     = []
}

variable "allowed_security_groups" {
  description = "The security groups to allow"
  type        = list(string)
  default     = []
}

variable "allowed_prefix_list_ids" {
  description = "The prefix list IDs to allow"
  type        = list(string)
  default     = []
}

variable "sg_listener_port_from" {
  description = "The starting port for the security group listener"
  type        = number
  default     = 80
}

variable "sg_listener_port_to" {
  description = "The ending port for the security group listener"
  type        = number
  default     = 80
}

variable "sg_listener_protocol" {
  description = "The protocol for the security group listener"
  type        = string
  default     = "tcp"
}

variable "security_groups" {
  description = "List of security groups for the instance"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Subnet IDs where the instance will be launched"
  type        = list(string)
  default     = []
}

variable "count_instances" {
  description = "number of instances"
  type        = number
  default     = 1
}

# --- IAM Role Variables ---
variable "permissions_name" {
  description = "List name of policies for role"
  type        = list(string)
  default     = []
}

# --- Root volume configuration ---
variable "root_volume_device_name" {
  description = "Device name for root volume"
  type        = string
  default     = "/dev/xvda"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

# --- Additional EBS volume configuration ---
variable "additional_ebs_enabled" {
  description = "Whether to create an additional EBS volume"
  type        = bool
  default     = false
}
variable "ebs_encrypted" {
  description = "Whether to encrypt the EBS volume"
  type        = bool
  default     = true
}

variable "additional_ebs_device_name" {
  description = "Device name for additional EBS volume"
  type        = string
  default     = "/dev/sdf"
}

variable "additional_ebs_size" {
  description = "Size of additional EBS volume in GB"
  type        = number
  default     = 100
}

variable "additional_ebs_type" {
  description = "Type of additional EBS volume"
  type        = string
  default     = "gp3"
}

variable "additional_ebs_delete_on_termination" {
  description = "Whether to delete the EBS volume on instance termination"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "update_default_version" {
  description = "Whether update_default_version"
  type        = bool
  default     = true
}
variable "ebs_delete_on_termination" {
  description = "delete_on_termination the EBS volume"
  type        = bool
  default     = true
}