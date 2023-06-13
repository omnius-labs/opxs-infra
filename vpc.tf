resource "aws_vpc" "opxs" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "opxs_public_1a" {
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.opxs.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "opxs_public_1c" {
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1c"
  vpc_id                  = aws_vpc.opxs.id
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "opxs" {
  vpc_id = aws_vpc.opxs.id
}

resource "aws_route_table" "opxs" {
  vpc_id = aws_vpc.opxs.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.opxs.id
  }
}

resource "aws_route_table_association" "opxs_public_1a" {
  route_table_id = aws_route_table.opxs.id
  subnet_id      = aws_subnet.opxs_public_1a.id
}

resource "aws_route_table_association" "opxs_public_1c" {
  route_table_id = aws_route_table.opxs.id
  subnet_id      = aws_subnet.opxs_public_1c.id
}

resource "aws_security_group" "opxs_vpc" {
  name   = "opxs-vpc-sg"
  vpc_id = aws_vpc.opxs.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "ingress_from_cloudfront_sg_rule" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  security_group_id = aws_security_group.opxs_vpc.id
}

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_lb" "opxs_api" {
  name               = "opxs-api-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.opxs_vpc.id]
  subnets            = [aws_subnet.opxs_public_1a.id, aws_subnet.opxs_public_1c.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "opxs_api_http" {
  load_balancer_arn = aws_lb.opxs_api.arn
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
  load_balancer_arn = aws_lb.opxs_api.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.opxs.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.opxs_api.arn
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
