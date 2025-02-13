# 🏗️ Fetch Existing Hosted Zone from AWS
data "aws_route53_zone" "gloria_zone" {
  name         = "theglorialarbi.com"
  private_zone = false
}

# ✅ Fetch Stored ACM Certificate ARN from AWS SSM
data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/terraform/acm_certificate_arn"
}

# ✅ Fetch CNAME Record Name for SSL Validation from SSM
data "aws_ssm_parameter" "ssl_cname_name" {
  name = "/terraform/ssl_cname_name"
}

# ✅ Fetch CNAME Record Value for SSL Validation from SSM
data "aws_ssm_parameter" "ssl_cname_value" {
  name = "/terraform/ssl_cname_value"
}

# 📝 CNAME Record for SSL Validation (Uses Stored Values)
resource "aws_route53_record" "cert_validation" {
  zone_id = data.aws_route53_zone.gloria_zone.zone_id
  name    = data.aws_ssm_parameter.ssl_cname_name.value  # 🔹 Stored CNAME name from SSM
  type    = "CNAME"
  records = [data.aws_ssm_parameter.ssl_cname_value.value]  # 🔹 Stored CNAME value from SSM
  ttl     = 300

  lifecycle {
    ignore_changes = all  # Prevent Terraform from overwriting existing records
  }
}

# 🏗️ Route 53 Record for ALB (app.theglorialarbi.com)
resource "aws_route53_record" "gloria_alb" {
  zone_id = data.aws_route53_zone.gloria_zone.zone_id
  name    = "app"
  type    = "A"

  alias {
    name                   = aws_lb.gloria_alb.dns_name
    zone_id                = aws_lb.gloria_alb.zone_id
    evaluate_target_health = true
  }
}
