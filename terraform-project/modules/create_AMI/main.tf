provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "image_vm" {
    ami           = "ami-0f403e3180720dd7e"
    instance_type = "t2.micro"

    user_data = <<-EOF
        #!/bin/bash
        sudo yum update -y
        sudo yum install -y httpd
        echo 'Hello from Terraform' > /var/www/html/index.html
        sudo systemctl start httpd
        sudo systemctl enable httpd
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=https
        sudo firewall-cmd --reload
    EOF

    tags = {
        Name = "image_vm"
    }
}

resource "tls_private_key" "my_key" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

resource "aws_ami_from_instance" "custom_ami" {
    name               = "MyAMI"
    source_instance_id = aws_instance.image_vm.id
    description        = "AMI created from instance with Apache installed"

    tags = {
        Name = "ApacheServerAMI"
    }
}

output "image_vm_ip_address" {
    value = aws_instance.image_vm.private_ip
}

output "ami_id" {
    value = aws_ami_from_instance.custom_ami.id
}
