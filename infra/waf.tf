resource "aws_wafv2_web_acl" "gloria_waf" {
  name        = "gloria-waf"
  description = "WAF for Gloria ALB"
  scope       = "REGIONAL"  # Use "CLOUDFRONT" for global WAF

  default_action {
    allow {}  # Allow all requests unless blocked by a rule
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "gloria-waf"
    sampled_requests_enabled   = true
  }

  # Rate-based rule to block IPs making 50+ requests per minute
  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {}  # Block IPs that exceed the request limit
    }

    statement {
      rate_based_statement {
        limit              = 50  # Allow only 50 requests per minute per IP
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit"
      sampled_requests_enabled   = true
    }
  }
}

# Attach WAF to the Application Load Balancer (ALB)
resource "aws_wafv2_web_acl_association" "gloria_waf_association" {
  resource_arn = aws_lb.gloria_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.gloria_waf.arn
}
