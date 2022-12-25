# Configure the AWS Provider
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAUEPHKAM5B3VTOJMH"
  secret_key = "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"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_security_group" "project-iac-sg" {
  name = "first_try"

  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  //ami = "" // NO ES ELEGANTE!
  instance_type = "t2.micro"
  tags = {
    Name = "web-server"
  }
}


resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.project-iac-sg.id
  network_interface_id = aws_instance.web.primary_network_interface_id
}

resource "aws_key_pair" "keys" {
  key_name="aws-keys"
  public_key=file("./aws-key.pub")
  
}




output "public_ip" {
  value       = aws_instance.web.public_ip
}