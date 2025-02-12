# 🏗️ Fetch Hosted Zone ID from AWS SSM Parameter Store
data "aws_ssm_parameter" "hosted_zone_id" {
  name = "/terraform/hosted_zone_id"
}

# 🏗️ Route 53 Record for ALB (app.theglorialarbi.com)
resource "aws_route53_record" "gloria_alb" {
  zone_id = data.aws_ssm_parameter.hosted_zone_id.value  # ✅ Uses stored value from SSM
  name    = "app"
  type    = "A"

  alias {
    name                   = aws_lb.gloria_alb.dns_name
    zone_id                = aws_lb.gloria_alb.zone_id
    evaluate_target_health = true
  }
}

# 🔒 Fetch Existing ACM Certificate for theglorialarbi.com
data "aws_acm_certificate" "existing_cert" {
  domain   = "theglorialarbi.com"
  statuses = ["ISSUED"]  # Only get issued certificates
}

# ✅ Use Existing ACM Certificate Validation (No CNAME Changes)
resource "aws_acm_certificate_validation" "validated_cert" {
  certificate_arn = data.aws_acm_certificate.existing_cert.arn
}
