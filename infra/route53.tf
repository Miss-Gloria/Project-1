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

# 🔒 SSL Certificate for theglorialarbi.com
resource "aws_acm_certificate" "domain_cert" {
  domain_name       = "theglorialarbi.com"
  validation_method = "DNS"

  subject_alternative_names = ["*.theglorialarbi.com"]

  tags = {
    Name = "The Gloria Larbi SSL Certificate"
  }

  lifecycle {
    create_before_destroy = true  # Ensures SSL certificate is always valid
  }
}

# ✅ Fetch Existing CNAME Record Dynamically
data "aws_route53_record" "cert_validation" {
  zone_id = data.aws_ssm_parameter.hosted_zone_id.value
  name    = "_ecd117fc15356b9b1c7bb0ecbfb1fd87.theglorialarbi.com"
  type    = "CNAME"
}

# ✅ Validate SSL Certificate (ACM) Using Existing CNAME
resource "aws_acm_certificate_validation" "validated_cert" {
  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [data.aws_route53_record.cert_validation.name]
}
