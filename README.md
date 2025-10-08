# EC2 Launch Template Terraform Module

This Terraform module creates and manages AWS EC2 Launch Templates. It is designed to simplify the provisioning and configuration of EC2 instances using reusable templates.

## Features

- Create EC2 Launch Templates with customizable parameters
- Support for user data, block device mappings, network interfaces, and tags
- Easily integrate with Auto Scaling Groups and other AWS resources

## Usage

```hcl
module "ec2_launch_template" {
    source = "./tf-module-ec2-launch-template"

    name_prefix        = "example"
    image_id           = "ami-1234567890abcdef0"
    instance_type      = "t3.micro"
    key_name           = "my-key"
    security_group_ids = ["sg-0123456789abcdef0"]

    # Optional parameters
    user_data          = file("user_data.sh")
    tags = {
        Environment = "dev"
        Project     = "example"
    }
}
```

## Inputs

| Name                | Description                          | Type   | Default | Required |
|---------------------|--------------------------------------|--------|---------|:--------:|
| name_prefix         | Prefix for the launch template name   | string | n/a     |   yes    |
| image_id            | AMI ID for the instance              | string | n/a     |   yes    |
| instance_type       | EC2 instance type                    | string | n/a     |   yes    |
| key_name            | Key pair name                        | string | n/a     |   yes    |
| security_group_ids  | List of security group IDs           | list   | n/a     |   yes    |
| user_data           | User data script                     | string | ""      |    no    |
| tags                | Tags to apply to the template        | map    | {}      |    no    |

## Outputs

| Name                | Description                          |
|---------------------|--------------------------------------|
| launch_template_id  | The ID of the launch template        |
| launch_template_arn | The ARN of the launch template       |

## Requirements

- Terraform >= 0.13
- AWS Provider

## License

MIT License