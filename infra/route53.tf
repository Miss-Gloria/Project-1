data "aws_route53_zone" "gloria_zone" {
  name         = "theglorialarbi.com"
  private_zone = false
}

resource "aws_acm_certificate_validation" "validated_cert" {
  certificate_arn = data.aws_ssm_parameter.acm_certificate_arn.value
}

resource "aws_route53_record" "cert_validation" {
  count = length(aws_acm_certificate.domain_cert.domain_validation_options)

  name    = aws_acm_certificate.domain_cert.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.domain_cert.domain_validation_options[count.index].resource_record_type
  records = [aws_acm_certificate.domain_cert.domain_validation_options[count.index].resource_record_value]
  ttl     = 300
  zone_id = data.aws_route53_zone.gloria_zone.zone_id

  lifecycle {
    ignore_changes = all 
  }
}

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
