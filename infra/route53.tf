# 🏗️ Fetch Existing Hosted Zone from AWS
data "aws_route53_zone" "gloria_zone" {
  name         = "theglorialarbi.com"
  private_zone = false
}

# 🏗️ Fetch ACM Certificate ARN from SSM Parameter Store
data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/terraform/acm_certificate_arn"
}

# ✅ Validate SSL Certificate (DNS Validation)
resource "aws_acm_certificate_validation" "validated_cert" {
  certificate_arn = data.aws_ssm_parameter.acm_certificate_arn.value

  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}

# 📝 CNAME Record for SSL Validation (Avoid Duplicates)
resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.domain_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.domain_cert.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.domain_cert.domain_validation_options[0].resource_record_value]
  ttl     = 300
  zone_id = data.aws_route53_zone.gloria_zone.zone_id

  lifecycle {
    ignore_changes = all  # Prevent Terraform from modifying existing records
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

resource "aws_lb_listener" "gloria_https_listener" {
  load_balancer_arn = aws_lb.gloria_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_ssm_parameter.acm_certificate_arn.value

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gloria_tg.arn
  }
}
