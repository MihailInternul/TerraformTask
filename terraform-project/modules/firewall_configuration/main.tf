variable "vpc_id" {
  description = "The ID of the VPC where the security groups will be created."
  type        = string
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH into instances."
  type        = list(string)
  default     = ["YOUR_SSH_ALLOWED_IP/32"]
}

variable "load_balancer_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the load balancer. Use ['0.0.0.0/0'] for public access."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for web instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.load_balancer_cidr_blocks
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.load_balancer_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "InstanceSecurityGroup"
  }
}

output "instance_sg_id" {
  value = aws_security_group.instance_sg.id
}
