resource "aws_lb" "opxs" {
  name               = "opxs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.opxs_vpc.id]
  subnets            = [aws_subnet.opxs_public_1a.id, aws_subnet.opxs_public_1c.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "opxs_http" {
  load_balancer_arn = aws_lb.opxs.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "opxs_api_https" {
  load_balancer_arn = aws_lb.opxs.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.opxs_api.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "ok"
    }
  }
}

resource "aws_lb_listener_rule" "opxs_api_https" {
  listener_arn = aws_lb_listener.opxs_api_https.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.opxs_api.arn
  }
  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_target_group" "opxs_api" {
  name                 = "opxs-api-tg"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = aws_vpc.opxs.id
  deregistration_delay = 60
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 86400
    enabled         = true
  }

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 5
    matcher             = "200"
    path                = "/api/v1/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 2
    unhealthy_threshold = 2
  }
}
