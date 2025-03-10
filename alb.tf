# Create External Application Load Balancer
resource "aws_lb" "ext_alb" {
  name               = "${var.environment}-ext-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups = [
    aws_security_group.ext_alb_sg.id
  ]

  subnets = [
    aws_subnet.public[0].id,
    aws_subnet.public[1].id
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-ext-alb"
    }
  )
}

# Create Internal Application Load Balancer
resource "aws_lb" "int_alb" {
  name               = "${var.environment}-int-alb"
  internal           = true
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.int_alb_sg.id
  ]

  subnets = [
    aws_subnet.private[0].id,
    aws_subnet.private[1].id
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-int-alb"
    }
  )

}

# Create Target group for external ALB
resource "aws_lb_target_group" "nginx_tgt" {
  name        = "${var.environment}-nginx-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Create Target group for internal ALB
resource "aws_lb_target_group" "wordpress_tgt" {
  name        = "${var.environment}-wordpress-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "tooling_tgt" {
  name        = "${var.environment}-tooling-tgt"
  port        = 443
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    interval            = 10
    path                = "/healthstatus"
    protocol            = "HTTPS"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Create Listener for external ALB
resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.ext_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.laraadeboye.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tgt.arn
  }
}

# Create Listener for internal ALB - Wordpress
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.int_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.laraadeboye.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_tgt.arn
  }
}

# Create Listener rule for tooling target
# listener was created for the wordpress which is default, rule created to route traffic to tooling when the host header changes
resource "aws_lb_listener_rule" "tooling_listener" {
  listener_arn = aws_lb_listener.web_listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tooling_tgt.arn
  }

  condition {
    host_header {
      values = ["tooling.laraadeboye.com"]
    }
  }
}
