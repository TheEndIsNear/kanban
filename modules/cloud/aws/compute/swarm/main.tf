terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.95.0"
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

resource "aws_instance" "my_swarm" {
  ami                         = "ami-0ce8c2b29fcc8a346"
  associate_public_ip_address = true
  availability_zone           = "eu-west-1b"
  instance_type               = "t2.micro"
  key_name                    = "swarm-key"
  subnet_id                   = data.aws_subnets.main_subnets.ids[1]
  tags = {
    "Name" = "docker-swarm-manager"
  }
  vpc_security_group_ids = [
    aws_security_group.swarm_sg.id
  ]
}

resource "aws_security_group" "swarm_sg" {
  description = "launch-wizard-1 created 2025-04-21T13:37:23.115Z"
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
  name        = "launch-wizard-1"
  name_prefix = null
  tags        = {}
  tags_all    = {}
  vpc_id      = data.aws_vpc.main.id
}

