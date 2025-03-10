# Reference the existing Route 53 hosted zone
# This ensures we use the already created hosted zone instead of creating a new one
data "aws_route53_zone" "laraadeboye" {
  name         = "laraadeboye.com"
  private_zone = false
}

# Create the ACM certificate
resource "aws_acm_certificate" "laraadeboye" {
  domain_name               = "*.laraadeboye.com"
  validation_method         = "DNS"
  subject_alternative_names = ["laraadeboye.com"]

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-certificate"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}


# Create records to validate the certificate
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.laraadeboye.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.laraadeboye.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "laraadeboye" {
  certificate_arn         = aws_acm_certificate.laraadeboye.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

# Create alias record for tooling
resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.laraadeboye.zone_id
  name    = "tooling.laraadeboye.com"
  type    = "A"

  alias {
    name                   = aws_lb.ext_alb.dns_name
    zone_id                = aws_lb.ext_alb.zone_id
    evaluate_target_health = true
  }
}

# Create alias record for wordpress
resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.laraadeboye.zone_id
  name    = "wordpress.laraadeboye.com"
  type    = "A"

  alias {
    name                   = aws_lb.ext_alb.dns_name
    zone_id                = aws_lb.ext_alb.zone_id
    evaluate_target_health = true
  }
}
