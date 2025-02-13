# 🏗️ Fetch Existing Hosted Zone from AWS SSM Parameter Store
data "aws_ssm_parameter" "hosted_zone_id" {
  name = "/terraform/hosted_zone_id"
}

# ✅ Fetch Stored ACM Certificate ARN from AWS SSM
data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/terraform/acm_certificate_arn"
}

# ✅ Fetch CNAME Record Name for SSL Validation from SSM (Read-only)
data "aws_ssm_parameter" "ssl_cname_name" {
  name = "/terraform/acm_cname_name"
}

# ✅ Fetch CNAME Record Value for SSL Validation from SSM (Read-only)
data "aws_ssm_parameter" "ssl_cname_value" {
  name = "/terraform/acm_cname_value"
}

# 📝 Completely Remove Terraform's Control Over ACM CNAME
# 🔹 Terraform will NOT create or modify the CNAME record at all.
# 🔹 This ensures no conflicts with manually created ACM validation.

# 🏗️ Route 53 Record for ALB (app.theglorialarbi.com)
resource "aws_route53_record" "gloria_alb" {
  zone_id = data.aws_ssm_parameter.hosted_zone_id.value
  name    = "app"
  type    = "A"

  alias {
    name                   = aws_lb.gloria_alb.dns_name
    zone_id                = aws_lb.gloria_alb.zone_id
    evaluate_target_health = true
  }
}
