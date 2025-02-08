resource "aws_s3_bucket" "terraform_state" {
  bucket = "gloria2214-terraform-state" 

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Production"
  }
}
resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
terraform {
  backend "s3" {
    bucket         = "gloria2214-terraform-state" 
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
