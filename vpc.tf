# mk (c) 2019

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "vpc_openvpn"

  cidr = "10.10.0.0/16"

  azs = "${var.azs}"
  public_subnets  = ["10.10.1.0/24"]

  tags = {
    Owner       = "terraform"
    Environment = "${terraform.workspace}"
    Name        = "${var.vpc_name}"
  }
}

resource "aws_security_group" "vpn_sg" {
  name          = "${var.vpn_sg_name}"
  description   = "Allow in TCP on port 443"
  tags          = { Name = "${var.vpn_sg_name}" }
  vpc_id        = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh_sg" {
  name          = "${var.ssh_sg_name}"
  description   = "Allow in TCP on port 22 from fixed IP"
  tags          = { Name = "${var.ssh_sg_name}" }
  vpc_id        = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ssh_allow_cidr}"]
  }
}
