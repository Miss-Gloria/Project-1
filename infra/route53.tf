resource "aws_route53_zone" "domain_zone" {
  name = "theglorialarbi.com"
}

resource "aws_route53_record" "gloria_alb" {
  zone_id = aws_route53_zone.domain_zone.zone_id
  name    = "app"
  type    = "A"

  alias {
    name                   = aws_lb.gloria_alb.dns_name
    zone_id                = aws_lb.gloria_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "domain_cert" {
  domain_name       = "theglorialarbi.com"
  validation_method = "DNS"

  subject_alternative_names = ["*.theglorialarbi.com"]

  tags = {
    Name = "The Gloria Larbi SSL Certificate"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.domain_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = aws_route53_zone.domain_zone.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "validated_cert" {
  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
