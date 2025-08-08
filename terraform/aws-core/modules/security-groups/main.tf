resource "aws_security_group" "nomad" {
  name        = "${var.name}-nomad-sg"
  description = "Security group for Nomad and Consul servers"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  ingress {
    description = "Nomad RPC"
    from_port   = 4646
    to_port     = 4648
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  ingress {
    description = "Consul"
    from_port   = 8500
    to_port     = 8600
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-nomad"
  }
}
