data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical (Ubuntu)
}

data "aws_ssm_parameter" "key_name" {
  name = "/terraform/gloria_server"
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/terraform/gloria_vpc_id"
}

data "aws_ssm_parameter" "public_subnet_id" {
  name = "/terraform/gloria_public_subnet_id"
}

data "aws_ssm_parameter" "private_subnet_id" {
  name = "/terraform/gloria_private_subnet_id"
}

data "aws_ssm_parameter" "public_subnet_id_1" {
  name = "/terraform/gloria_public_subnet_id_1"
}

data "aws_ssm_parameter" "public_subnet_id_2" {
  name = "/terraform/gloria_public_subnet_id_2"
}
data "aws_ssm_parameter" "igw_id" {
  name = "/terraform/gloria_igw_id"
}
