# 🏗️ Fetch Existing Hosted Zone from AWS SSM Parameter Store
data "aws_ssm_parameter" "hosted_zone_id" {
  name = "/terraform/hosted_zone_id"
}

# ✅ Fetch Stored ACM Certificate ARN from AWS SSM
data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/terraform/acm_certificate_arn"
}

# ✅ Fetch CNAME Record Name for SSL Validation from SSM (Pre-existing in AWS)
data "aws_ssm_parameter" "ssl_cname_name" {
  name = "/terraform/acm_cname_name"
}

# ✅ Fetch CNAME Record Value for SSL Validation from SSM (Pre-existing in AWS)
data "aws_ssm_parameter" "ssl_cname_value" {
  name = "/terraform/acm_cname_value"
}

# 📝 CNAME Record for SSL Validation (NO CREATION – Just Referencing Existing Entry)
resource "aws_route53_record" "cert_validation" {
  count   = length(data.aws_ssm_parameter.ssl_cname_name.value) > 0 ? 1 : 0  # Only create if necessary
  name    = data.aws_ssm_parameter.ssl_cname_name.value
  type    = "CNAME"
  records = [data.aws_ssm_parameter.ssl_cname_value.value]
  ttl     = 300
  zone_id = data.aws_ssm_parameter.hosted_zone_id.value

  lifecycle {
    ignore_changes = all  # 🔥 Prevents Terraform from overwriting existing records
  }
}

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
