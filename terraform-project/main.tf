terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-bucket31358117754"
    key    = "path/to/your/terraform/state/file"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
  # Assuming no variables are required to be passed in this example. Adjust as needed.
}

module "create_AMI" {
  source = "./modules/create_AMI"
  # Assuming all necessary configurations are internal to the module. Adjust as needed.
}

module "firewall_configuration" {
  source = "./modules/firewall_configuration"
  vpc_id = module.network.vpc_id  # Example: passing VPC ID to the firewall module
  allowed_ssh_cidr_blocks = ["188.25.209.83/32"]
}

module "web_servers" {
  source                 = "./modules/web_servers"
  ami_id                 = module.create_AMI.ami_id
  subnet_ids             = module.network.public_subnet_ids  # Assuming the network module outputs these IDs
  vpc_security_group_ids = [module.firewall_configuration.instance_sg_id]  # Assuming the firewall module outputs this ID
  target_group_arns      = [module.load_balancer.target_group_arn]  # Pass the target group ARN from the load_balancer module
}

module "load_balancer" {
  source             = "./modules/load_balancer"
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids  # Ensure your network module provides these outputs
  security_group_ids = [module.firewall_configuration.lb_sg_id]  # Ensure this is output from your firewall module
  target_group_name  = "web-server-target-group"  # Example static value; adjust as necessary
}

# Adjust this to reflect how the IP address or other information is actually obtained
output "vm_ip_address" {
  value = "Check your AWS console or specific module output"  # Placeholder
}

output "load_balancer_dns_name" {
  value = module.load_balancer.load_balancer_dns_name
}
