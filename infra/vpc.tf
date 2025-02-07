# Create the VPC
resource "aws_vpc" "gloria_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Gloria VPC"
  }
}

# Create Two Public Subnets Using `count`
resource "aws_subnet" "public_subnet" {
  count = 2  # ✅ Creates two subnets dynamically

  vpc_id                  = aws_vpc.gloria_vpc.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)  # Dynamically assigns CIDR
  map_public_ip_on_launch = true
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)  # Distributes across AZs

  tags = {
    Name = "Gloria Public Subnet ${count.index + 1}"
  }
}

# Create a Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.gloria_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Gloria Private Subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gloria_igw" {
  vpc_id = aws_vpc.gloria_vpc.id

  tags = {
    Name = "Gloria Internet Gateway"
  }
}

# Store values in AWS SSM Parameter Store
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/terraform/gloria_vpc_id"
  type  = "String"
  value = aws_vpc.gloria_vpc.id

  lifecycle {
    ignore_changes = [value]
  }
}

# Store Public Subnet IDs in SSM
resource "aws_ssm_parameter" "public_subnet_id_1" {
  name  = "/terraform/gloria_public_subnet_id_1"
  type  = "String"
  value = aws_subnet.public_subnet[0].id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "public_subnet_id_2" {
  name  = "/terraform/gloria_public_subnet_id_2"
  type  = "String"
  value = aws_subnet.public_subnet[1].id

  lifecycle {
    ignore_changes = [value]
  }
}

# Store Private Subnet ID in SSM
resource "aws_ssm_parameter" "private_subnet_id" {
  name  = "/terraform/gloria_private_subnet_id"
  type  = "String"
  value = aws_subnet.private_subnet.id

  lifecycle {
    ignore_changes = [value]
  }
}

# Store Internet Gateway ID in SSM
resource "aws_ssm_parameter" "igw_id" {
  name  = "/terraform/gloria_igw_id"
  type  = "String"
  value = aws_internet_gateway.gloria_igw.id

  lifecycle {
    ignore_changes = [value]
  }
}
