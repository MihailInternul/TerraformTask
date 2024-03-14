provider "aws" {
  region = "us-east-1"
}

# Reference the existing AMI from the create_AMI module
data "aws_ami" "web_server_ami" {
  id = module.create_AMI.ami_id
}

resource "aws_launch_template" "web_server" {
  name         = "web-server-template"
  image_id     = data.aws_ami.web_server_ami.id
  instance_type = "t2.micro"

  # User data script to display server number
  user_data = <<EOF
  #!/bin/bash
  echo "Server #$$HOSTNAME" >> /var/www/html/index.html
  EOF
}

resource "aws_autoscaling_group" "web_servers" {
  name = "web-server-group"
  min_size = 3
  max_size = 3
  desired_capacity = 3

  launch_template {
    id = aws_launch_template.web_server.id
    version = "$Latest"
  }

  # Health check configuration for the autoscaling group
  health_check_type = "ELB"

  # Associate the autoscaling group with a security group (not shown here)
  vpc_security_group_ids = module.network.security_group_id
  # vpc_zone_identifier = [<subnet_id>]  # Replace with your subnet ID
  subnet_ids = module.network.subnet_id
}

resource "aws_lb" "web_balancer" {
  name = "web-lb"
  internal = false
  security_groups = module.network.security_group_id  # Replace with your security group ID
  subnets = module.network.subnet_id  # Replace with your subnet ID

  # Health check configuration for the load balancer
  health_check {
    type                 = "http"
    interval             = 30
    path                 = "/"
    timeout              = 5
    healthy_threshold    = 2
    unhealthy_threshold = 5
  }

  # Define a target group for the load balancer
  target_group {
    name = "web-server-target-group"
    port = 80
    protocol = "http"
    vpc_id = aws_subnet.public.vpc_id

    # Associate the target group with the autoscaling group
    targets {
      id = aws_autoscaling_group.web_servers.id
      port = 80
      arn = aws_autoscaling_group.web_servers.arn
    }
  }
}

output "load_balancer_dns_name" {
  value = aws_lb.web_balancer.dns_name
}
