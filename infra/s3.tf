terraform {
  backend "s3" {
    bucket         = "gloria2214-terraform-state"   
    key            = "terraform/terraform.tfstate"       
    region         = "us-east-1"
    encrypt        = true
  }
}
