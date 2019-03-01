# mk (c) 2019
# User also requires "s3:ListAllMyBuckets" and "s3:GetBucketLocation" IAM permissions

data "template_file" "bucket_policy" {
  template = "${file("templates/bucket_policy.json")}"

  vars = {
    server_role_arn = "${aws_iam_role.openvpn_server.arn}"
    bucket_arn      = "arn:aws:s3:::${var.s3_bucket_name}"
    user_arns       = "${jsonencode(formatlist("arn:aws:iam::%s:user/%s", var.aws_id, var.iam_users))}"
  }
}

resource "aws_s3_bucket" "openvpn" {
  bucket = "${var.s3_bucket_name}"
  acl    = "private"
  policy = "${data.template_file.bucket_policy.rendered}"

  tags = {
    Name = "${var.s3_bucket_name}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        # SSE-S3 - S3 manages encryption for free
        sse_algorithm = "AES256"
      }
    }
  }
}
