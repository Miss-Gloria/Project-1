# AWS Region
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

# VPC CIDR Block
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

# Public Subnet CIDR
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

# Private Subnet CIDR
variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}

# Instance Type
variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.medium"
}

# Key Pair Name (Fetched from Parameter Store)
variable "key_pair_name" {
  description = "SSH Key Pair name stored in AWS SSM Parameter Store"
  default     = "/terraform/gloria_server"
}
