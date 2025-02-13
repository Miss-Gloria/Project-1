# ✅ Fetch Stored ACM Certificate ARN from AWS SSM
data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/terraform/acm_certificate_arn"
}

# ✅ Fetch CNAME Record Name for SSL Validation from SSM (Updated to match existing parameter)
data "aws_ssm_parameter" "ssl_cname_name" {
  name = "/terraform/acm_cname_name"
}

# ✅ Fetch CNAME Record Value for SSL Validation from SSM (Updated to match existing parameter)
data "aws_ssm_parameter" "ssl_cname_value" {
  name = "/terraform/acm_cname_value"
}
