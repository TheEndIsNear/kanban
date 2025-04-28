terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}

data "aws_vpc" "main" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_subnets" "main_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}
data "aws_ami" "amazon_linux_docker" {
  most_recent = true
  owners      = ["391279077235"]
  filter {
    name   = "name"
    values = ["amazon-linux-docker_*"]
  }
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "swarm-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "aws_instance" "swarm_node" {
  count                       = var.number_of_nodes
  ami                         = data.aws_ami.amazon_linux_docker.id
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.main_profile.name
  subnet_id = data.aws_subnets.main_subnets.ids[
    count.index % length(data.aws_subnets.main_subnets.ids)
  ]
  tags = {
    "Name" = "docker-swarm-manager"
  }
  vpc_security_group_ids = [
    aws_security_group.swarm_pool_ports.id
  ]

  user_data = <<-EOF
    #!/usr/bin/env bash
    docker swarm init
    EOF
}

resource "aws_security_group" "swarm_pool_ports" {
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = null
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = null
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = null
      from_port        = 4000
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 4000
    },
  ]
  name_prefix = null
  tags        = {}
  tags_all    = {}
  vpc_id      = data.aws_vpc.main.id
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

variable "private_key_path" {
  description = "The path to the private key file."
  type        = string
}

resource "local_sensitive_file" "private_key" {
  filename        = var.private_key_path
  content         = tls_private_key.rsa.private_key_pem
  file_permission = "0400"
}
