provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}

module "create_AMI" {
  source = "./modules/create_AMI"
}

module "web_servers" {
  source         = "./modules/web_servers"
  ami_id         = module.create_AMI.ami_id
  instance_count = 3
}

output "vm_ip_address" {
  value = module.create_AMI.image_vm_ip_address
}

output "load_balances_dns_name" {
  value = module.web_servers.load_balances_dns_name
}