resource "aws_route53_zone" "opxs" {
  name = "opxs.omnius-labs.com"
}

resource "aws_route53_record" "opxs" {
  zone_id = aws_route53_zone.opxs.zone_id
  name    = var.domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.opxs.domain_name
    zone_id                = aws_cloudfront_distribution.opxs.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_acm_certificate" "opxs" {
  domain_name               = aws_route53_zone.opxs.name
  subject_alternative_names = ["*.${aws_route53_zone.opxs.name}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "opxs_dns_verify" {
  for_each = {
    for dvo in aws_acm_certificate.opxs.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.opxs.id
}

resource "aws_acm_certificate_validation" "opxs" {
  certificate_arn         = aws_acm_certificate.opxs.arn
  validation_record_fqdns = [for record in aws_route53_record.opxs_dns_verify : record.fqdn]
}
