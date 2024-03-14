provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "image_vm" {
    ami           = "ami-0f403e3180720dd7e"
    instance_type = "t2.micro"

    tags = {
        Name = "image_vm"
    }
}

resource "tls_private_key" "my_key" {
    algorithm = "RSA"
    rsa_bits  = 2048
}

resource "null_resource" "install_apache" {
    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install httpd -y",
            "sudo systemctl start httpd",
            "sudo systemctl enable httpd",
            "sudo firewall-cmd --permanent --add-service=http",
            "sudo firewall-cmd --permanent --add-service=https",
            "sudo firewall-cmd --reload",
            "sudo systemctl status httpd",
            "instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)",
            "aws ec2 create-image --instance-id \"$instance_id\" --name \"MyAMI\" --description \"AMI created from instance\" --no-reboot"
        ]

        connection {
            type        = "ssh"
            user        = "ec2-user"
            private_key = tls_private_key.my_key.private_key_pem
            host        = aws_instance.image_vm.public_ip
        }
    }
}

output "image_vm_ip_address" {
    value = aws_instance.image_vm.private_ip
}

output "ami_id" {
    value = aws_instance.image_vm.id
}