# mk (c) 2019

resource "aws_iam_instance_profile" "openvpn_server" {
  name = "${var.iam_role_name}"
  role = "${aws_iam_role.openvpn_server.name}"
}

resource "aws_iam_role" "openvpn_server" {
  name = "${var.iam_role_name}"
  path = "/"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
POLICY
}
