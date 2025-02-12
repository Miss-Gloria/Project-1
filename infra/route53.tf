# 🏗️ Fetch Existing Hosted Zone from AWS
data "aws_route53_zone" "gloria_zone" {
  name         = "theglorialarbi.com"
  private_zone = false
}

# 🔒 SSL Certificate for `theglorialarbi.com`
resource "aws_acm_certificate" "domain_cert" {
  provider = aws.acm  # ✅ Ensures ACM uses `us-east-1`

  domain_name       = "theglorialarbi.com"
  validation_method = "DNS"
  subject_alternative_names = ["*.theglorialarbi.com"]

  tags = {
    Name = "The Gloria Larbi SSL Certificate"
  }
}

# 📝 CNAME Records for SSL Validation (ACM)
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.domain_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.gloria_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# ✅ Validate SSL Certificate (DNS Validation)
resource "aws_acm_certificate_validation" "validated_cert" {
  provider = aws.acm  # ✅ Ensures ACM validation is in `us-east-1`

  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
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
