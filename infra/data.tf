# Fetch the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

data "aws_ssm_parameter" "key_name" {
  name = "/terraform/gloria_server"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/terraform/vpc_id"
}

data "aws_ssm_parameter" "public_subnet_1_id" {
  name = "/terraform/public_subnet_1_id"
}

data "aws_ssm_parameter" "public_subnet_2_id" {
  name = "/terraform/public_subnet_2_id"
}

data "aws_ssm_parameter" "private_subnet_id" {
  name = "/terraform/private_subnet_id"
}

data "aws_ssm_parameter" "igw_id" {
  name = "/terraform/igw_id"
}

data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/terraform/acm_certificate_arn"
}

data "aws_ssm_parameter" "acm_cname_name" {
  name = "/terraform/acm_cname_name"
}

data "aws_ssm_parameter" "acm_cname_value" {
  name = "/terraform/acm_cname_value"
}
