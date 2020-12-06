terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
  access_key = var.access-key
  secret_key = var.secret-key
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "myvpc" {
    id = var.vpc-id 
}

data "aws_security_group" mysg {
    id = var.sg-id
}

resource "aws_instance" "squiddo" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key-name
  vpc_security_group_ids = [ data.aws_security_group.mysg.id ]

  user_data = file("${path.module}/tfscripts/setup.sh")


  tags = {
    Name = "SquidProxy"
  }
}

output "public_ip_address" {
    value = aws_instance.squiddo.public_ip
}

