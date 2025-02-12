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

# 🔒 Try to Fetch Existing ACM Certificate (Ignore If None Found)
data "aws_acm_certificate" "existing_cert" {
  domain   = "theglorialarbi.com"
  statuses = ["ISSUED"]
  most_recent = true
  provider = aws.us-east-1  # ✅ ACM must be in `us-east-1` for ALB
}

# ✅ Create SSL Certificate If None Exists
resource "aws_acm_certificate" "domain_cert" {
  count = length(try(data.aws_acm_certificate.existing_cert.arn, "")) > 0 ? 0 : 1

  domain_name       = "theglorialarbi.com"
  validation_method = "DNS"

  subject_alternative_names = ["*.theglorialarbi.com"]

  tags = {
    Name = "The Gloria Larbi SSL Certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ✅ Use Existing or New ACM Certificate Validation
resource "aws_acm_certificate_validation" "validated_cert" {
  certificate_arn = length(try(data.aws_acm_certificate.existing_cert.arn, "")) > 0 ? data.aws_acm_certificate.existing_cert.arn : aws_acm_certificate.domain_cert[0].arn
}
