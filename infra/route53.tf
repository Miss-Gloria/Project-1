# 🏗️ Fetch Existing Hosted Zone from Route 53
data "aws_route53_zone" "gloria_zone" {
  name         = "theglorialarbi.com"
  private_zone = false
}

# 🔒 Create SSL Certificate for `theglorialarbi.com`
resource "aws_acm_certificate" "domain_cert" {
  provider = aws.acm  # ✅ Ensures ACM uses the correct region

  domain_name       = "theglorialarbi.com"
  validation_method = "DNS"
  subject_alternative_names = ["*.theglorialarbi.com"]

  tags = {
    Name = "The Gloria Larbi SSL Certificate"
  }
}

# 📝 Create DNS Records for ACM Validation (Route 53)
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
  provider = aws.acm  # ✅ Ensures ACM validation is done in `us-east-1`

  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# 🌍 ALB Listener (Attach SSL Certificate)
resource "aws_lb_listener" "gloria_https_listener" {
  load_balancer_arn = aws_lb.gloria_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy       = "ELBSecurityPolicy-2016-08"
  certificate_arn  = aws_acm_certificate.domain_cert.arn  # ✅ Correct Certificate Reference

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gloria_tg.arn
  }
}
