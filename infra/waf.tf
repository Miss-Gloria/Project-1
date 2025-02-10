resource "aws_wafv2_web_acl" "gloria_waf" {
  name        = "gloria-waf"
  description = "WAF for Gloria ALB"
  scope       = "REGIONAL" 

  default_action {
    allow {}  
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "gloria-waf"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "rate-limit"
    priority = 1

    action {
      block {} 
    }

    statement {
      rate_based_statement {
        limit              = 50 
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
resource "aws_wafv2_web_acl_association" "gloria_waf_association" {
  resource_arn = aws_lb.gloria_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.gloria_waf.arn

  
}
