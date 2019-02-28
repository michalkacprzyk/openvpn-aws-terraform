# openvpn-aws-terraform

## What is?

Automated creation of a simple **OpenVPN** infrastructure on **AWS**.

## What for?

More secure Internet connections from diverse range of devices and access points.

## How to?

### Prepare
  - Install [aws-vault](https://github.com/99designs/aws-vault) to have nice support for **MFA** with **terraform**
  - Install [terraform](https://www.terraform.io/downloads.html)

### Configure AWS
  - Set up a user with access keys (in my case *auto_admin*)
    - Make sure the user can assume admin [[role]](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-role.html)
      - Make sure the role requires MFA device, for example 
    [Google Authenticator](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2)
    - You might find it useful to look at this [Terraform Issue Comment](https://github.com/terraform-providers/terraform-provider-aws/issues/2420#issuecomment-411345124)
  - Prepare a normal user, that will have access to generated **OpenVPN** configs
    - User name should match value from **iam_users** variable set in **terraform** (below)
    - User should have the following **IAM** policy attached
```JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::*"
      ]
    }
  ]
}
```

### Execute the build
  - Clone this repository
  - Create a file with custom settings, for example **example.auto.tfvars** with values overriding defaults from **variables.tf**
```bash
# example.auto.tfvars
profile = "auto_admin"
aws_id  = 210987654321
# ...
```
  - Finally execute
```
terraform init
aws-vault exec auto_admin -- terraform plan
aws-vault exec auto_admin -- terraform apply
```

## What if?
  - The code was created and tested on [Linux Mint](https://linuxmint.com/)
    - aws-vault v4.5.1
    - Terraform v0.11.11
  - The code assumes that it can access and use a preexisting domain configured in **Route53**
  - Here is a diagram depicting the flow:
![diagram](https://raw.githubusercontent.com/mkusanagi/openvpn-aws-terraform/master/diagram.png)
