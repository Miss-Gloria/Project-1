# 🏗️ Fetch Existing Hosted Zone from AWS
data "aws_route53_zone" "gloria_zone" {
  name         = "theglorialarbi.com"
  private_zone = false
}

# ✅ Fetch Stored ACM Certificate ARN from AWS SSM
data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/terraform/acm_certificate_arn"
}

# 📝 CNAME Record for SSL Validation (Manual Entry Required)
resource "aws_route53_record" "cert_validation" {
  name    = "_ecd117fc15356b9b1c7bb0ecbfb1fd87.theglorialarbi.com"  # 🔹 Manually add this from ACM
  type    = "CNAME"
  records = ["_b4146422409a75ae9cc82469e4097b6.zfylvmchrl.acm-validations.aws."]  # 🔹 Manually add this from ACM
  ttl     = 300
  zone_id = data.aws_route53_zone.gloria_zone.zone_id

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
