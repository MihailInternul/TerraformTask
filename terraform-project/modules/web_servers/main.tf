variable "ami_id" {
  description = "The AMI ID to use for the web servers."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the autoscaling group."
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs to attach to the autoscaling group."
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to assign to the instances."
  type        = list(string)
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server-template-"
  image_id      = var.ami_id
  instance_type = "t2.micro"

  # User data script to display server number/hostname
  user_data = base64encode(<<EOF
#!/bin/bash
echo "Server #\$(hostname)" > /var/www/html/index.html
EOF
  )

  vpc_security_group_ids = var.vpc_security_group_ids

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web_servers" {
  name_prefix          = "web-server-group-"
  min_size             = 3
  max_size             = 3
  desired_capacity     = 3
  health_check_type    = "ELB"
  vpc_zone_identifier  = var.subnet_ids

  launch_template {
    id      = aws_launch_template.web_server.id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns

  lifecycle {
    create_before_destroy = true
  }
}

output "web_server_group_name" {
  value = aws_autoscaling_group.web_servers.name
}
