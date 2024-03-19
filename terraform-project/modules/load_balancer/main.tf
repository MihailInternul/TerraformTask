variable "vpc_id" {
  description = "The VPC ID where the load balancer and other resources will be created."
}

variable "subnet_ids" {
  description = "A list of subnet IDs to attach to the Load Balancer."
  type        = list(string)
}

variable "security_group_ids" {
  description = "A list of security group IDs to assign to the Load Balancer."
  type        = list(string)
}

variable "target_group_name" {
  description = "The name of the target group."
  type        = string
  default     = "web-server-target-group"
}

resource "aws_lb" "web_balancer" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "web-lb"
  }
}

resource "aws_lb_target_group" "web" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "web-tg"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

output "load_balancer_dns_name" {
  value = aws_lb.web_balancer.dns_name
}

output "load_balancer_arn" {
  value = aws_lb.web_balancer.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}
