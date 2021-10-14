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

data "aws_ami" "fedora-cloud" {
  most_recent = true

  filter {
    name   = "name"
#    values = ["Fedora-Cloud-Base-33-1.2.x86_64-hvm-us-west*"]
    values = ["Fedora-Cloud-Base-34-1.2.x86_64-hvm-us-west*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  owners = ["125523088429"] # Fedora
}

data "aws_vpc" "myvpc" {
    id = var.vpc-id 
}

data "aws_security_group" mysg {
    id = var.sg-id
}

resource "aws_instance" "fcwg" {
  ami           = data.aws_ami.fedora-cloud.id
  instance_type = "t2.micro"
  key_name      = var.key-name
  vpc_security_group_ids = [ data.aws_security_group.mysg.id ]

  user_data = file("${path.module}/tfscripts/setup.sh")

  tags = {
    Name = "Wireguard"
  }
}

output "public_ip_address" {
    value = aws_instance.fcwg.public_ip
}

