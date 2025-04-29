resource "aws_security_group" "swarm_sg" {
  name = "swarm_pool_ports"
  egress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    description = "SSH port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    description = "Elixir Phoenix app"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
  }
  ingress {
    description = "Docker swarm management"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = [
      data.aws_vpc.main.cidr_block
    ]
  }
  ingress {
    description = "Docker container network discovery"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = [
      data.aws_vpc.main.cidr_block
    ]
  }
  ingress {
    description = "Docker overlay network"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = [
      data.aws_vpc.main.cidr_block
    ]
  }
  tags     = {}
  tags_all = {}
  vpc_id   = data.aws_vpc.main.id
}
