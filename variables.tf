# mk (c) 2019

variable profile {
  default = "auto_admin"
}

variable aws_id {
  default = 123456789012
}

variable role_arn {
  default = "arn:aws:iam::123456789012:role/admin_role_for_auto_admin"
}

variable region {
  default = "eu-central-1"
}

variable azs {
  default = ["eu-central-1a"]
}

variable vpc_name {
  default = "openvpn-vpc-tf"
}

variable vpn_sg_name {
  default = "vpn-sg-tf"
}

variable ssh_sg_name {
  default = "ssh-sg-tf"
}

variable instance_type {
  default = "t2.micro"
}

variable instance_name {
  default = "openvpn-server-tf"
}

# https://github.com/mkusanagi/mini-nat-ami
variable ami_owner {
  default = "123456789012"
}

variable ami_name_filter {
  default = "packer-ami-mini-nat-*"
}

variable ssh_user {
  default = "ec2-user"
}

variable ssh_key_name {
  default = "ssh-key-tf"
}

variable ssh_pub_key_file {
  default = "~/.ssh/id_rsa.pub"
}

variable ssh_key_file {
  default = "~/.ssh/id_rsa"
}

variable ssh_allow_cidr {
  default = "123.45.67.89/32"
}

variable zone_domain_name {
  default = "example.com"
}

variable server_subdomain {
  default = "openvpn"
}

variable s3_bucket_name {
  default = "openvpn-example-com"
}

variable iam_role_name {
  default = "openvpn-server-tf"
}

variable iam_users {
  default = ["mk"]
}

# Separated by space client devices, prefixed by user name and underscore
variable vpn_clients {
  default = "mk_ux305 mk_t530"
}
