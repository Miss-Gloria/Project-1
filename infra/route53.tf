# 📝 CNAME Record for SSL Validation (Using SSM Parameters)
resource "aws_route53_record" "cert_validation" {
  name    = data.aws_ssm_parameter.acm_cname_name.value
  type    = "CNAME"
  records = [data.aws_ssm_parameter.acm_cname_value.value]
  ttl     = 300
  zone_id = data.aws_route53_zone.gloria_zone.zone_id

  lifecycle {
    ignore_changes = all  # Prevent Terraform from modifying existing records
  }
}

# ✅ Validate SSL Certificate (ACM)
resource "aws_acm_certificate_validation" "validated_cert" {
  certificate_arn = data.aws_ssm_parameter.acm_certificate_arn.value

  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
