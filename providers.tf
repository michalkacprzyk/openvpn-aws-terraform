# mk (c) 2019

provider "aws" {
  region     = "${var.region}"
  profile    = "${var.profile}"

  assume_role {
    role_arn     = "${var.role_arn}"
  }
}
