# ALB Resource
resource "aws_lb" "gloria_alb" {
  name               = "gloria-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.gloria_alb_sg.id]
  subnets = [
    data.aws_ssm_parameter.public_subnet_1_id.value,
    data.aws_ssm_parameter.public_subnet_2_id.value
  ]
  enable_deletion_protection = false

  tags = {
    Name = "Gloria ALB"
  }
}

# Target Group for ALB to Forward Traffic
resource "aws_lb_target_group" "gloria_tg" {
  name        = "gloria-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Gloria Target Group"
  }
}

# Attach EC2 Instance to the Target Group
resource "aws_lb_target_group_attachment" "gloria_tg_attachment" {
  target_group_arn = aws_lb_target_group.gloria_tg.arn
  target_id        = aws_instance.gloria_server.id
  port             = 80
}

# HTTP Listener
resource "aws_lb_listener" "gloria_http_listener" {
  load_balancer_arn = aws_lb.gloria_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "gloria_https_listener" {
  load_balancer_arn = aws_lb.gloria_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy       = "ELBSecurityPolicy-2016-08"
  certificate_arn  = aws_acm_certificate_validation.validated_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gloria_tg.arn
  }
}
