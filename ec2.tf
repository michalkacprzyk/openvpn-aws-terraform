# mk (c) 2019

data "aws_ami" "nat_ami" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["${var.ami_name_filter}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${file(var.ssh_pub_key_file)}"
}

resource "null_resource" "prep_provision" {
  provisioner "local-exec" {
    when    = "create"
    command = "tar caf provision.tar.xz provision"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "rm provision.tar.xz"
  }
}

resource "aws_instance" "openvpn_server" {
  depends_on = ["null_resource.prep_provision"]

  tags = {
    Name = "${var.instance_name}"
  }

  availability_zone    = "${var.azs[count.index]}"
  instance_type        = "${var.instance_type}"
  ami                  = "${data.aws_ami.nat_ami.id}"
  key_name             = "${aws_key_pair.ssh_key.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.openvpn_server.id}"

  subnet_id = "${module.vpc.public_subnets[count.index]}"

  vpc_security_group_ids = [
    "${aws_security_group.vpn_sg.id}",
    "${aws_security_group.ssh_sg.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  connection {
    user        = "${var.ssh_user}"
    type        = "ssh"
    private_key = "${file(var.ssh_key_file)}"
  }

  provisioner "file" {
    source      = "./provision.tar.xz"
    destination = "/home/ec2-user/provision.tar.xz"
  }

  provisioner "remote-exec" {
    inline = [
      "tar xf /home/ec2-user/provision.tar.xz -C /home/ec2-user/",
      "source /home/ec2-user/provision/defaults",
      "export DOMAIN=${format("%s.%s", var.server_subdomain, var.zone_domain_name)}",
      "export CLIENTS=\"${var.vpn_clients}\"",
      "export S3_TARGET=s3://${var.s3_bucket_name}/clients",
      "sudo -E /home/ec2-user/provision/setup.sh",
    ]
  }
}
