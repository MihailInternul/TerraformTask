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
}

module "create_AMI" {
  source = "./modules/create_AMI"
}

module "firewall_configuration" {
  source                 = "./modules/firewall_configuration"
  vpc_id                 = module.network.vpc_id
  allowed_ssh_cidr_blocks = ["188.25.209.83/32"]
}

module "web_servers" {
  source                 = "./modules/web_servers"
  ami_id                 = module.create_AMI.ami_id
  subnet_ids             = module.network.public_subnet_ids
  vpc_security_group_ids = [module.firewall_configuration.instance_sg_id]
  target_group_arns      = [module.load_balancer.target_group_arn]
}

module "load_balancer" {
  source             = "./modules/load_balancer"
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.public_subnet_ids
  security_group_ids = [module.network.load_balancer_sg_id]
  target_group_name  = "web-server-target-group"
}

output "load_balancer_dns_name" {
  value = module.load_balancer.load_balancer_dns_name
}
