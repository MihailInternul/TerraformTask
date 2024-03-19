provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "MainVPC"
    }
}

resource "aws_subnet" "public_a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "PublicSubnetA"
    }
}

resource "aws_subnet" "public_b" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "PublicSubnetB"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "MainInternetGateway"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "PublicRouteTable"
    }
}

resource "aws_route_table_association" "public_rt_a" {
    subnet_id = aws_subnet.public_a.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_b" {
    subnet_id = aws_subnet.public_b.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "allow_web" {
    name = "allow_web_traffic"
    description = "Allow web inbound traffic"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "AllowWebTrafficSG"
    }
}

resource "aws_security_group" "allow_ssh" {
    name = "allow_ssh_traffic"
    description = "Allow SSH inbound traffic"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "AllowSSHTrafficSG"
    }
}

resource "aws_security_group" "lb_sg" {
    name        = "lb-sg"
    description = "Security group for Load Balancer"
    vpc_id      = aws_vpc.main.id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "LoadBalancerSG"
        Project = "YourProjectName"
    }
}

output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_subnet_ids" {
    value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "load_balancer_sg_id" {
    value = aws_security_group.lb_sg.id
}
