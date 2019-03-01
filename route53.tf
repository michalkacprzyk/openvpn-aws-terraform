# mk (c) 2019

data "aws_route53_zone" "selected" {
  name = "${var.zone_domain_name}"
}

resource "aws_route53_record" "openvpn" {
  depends_on = ["aws_instance.openvpn_server"]

  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${format("%s.%s", var.server_subdomain, data.aws_route53_zone.selected.name)}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.openvpn_server.public_ip}"]
}
