output "ip" {
  value = "${aws_instance.openvpn_server.public_ip}"
}
