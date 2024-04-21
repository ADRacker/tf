provider "aws" {
	region = "us-east-1"
}

variable "web_port" {
    description = "webserver tcp port"
}

resource "aws_instance" "server-ad-www" {
    ami           = "ami-026c8acd92718196b"
    instance_type = "t3.xlarge"
    tags = {
        Name = "server-ad-www"
    }
    vpc_security_group_ids = [aws_security_group.www-sg.id, aws_security_group.ssh-22.id]
    user_data = <<-EOF
    #!/bin/bash
    echo "Hello Folks!" > index.html
    nohup busybox httpd -f -p "${var.web_port}" &
    EOF
 
}

resource "aws_security_group" "www-sg" {
    name        = "web-ad-${var.web_port}"
    description = "web server accesss rules ${var.web_port}"
    ingress { 
        from_port   = var.web_port
        to_port     = var.web_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ssh-22" {
    name        = "ssh-ad-22"
    description = "web server accesss rules"
    ingress { 
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "dns_name" {
    value = aws_instance.server-ad-www.public_dns
}

output "pub_ip" {
    value = aws_instance.server-ad-www.public_ip
}
