resource "aws_cloudfront_origin_access_identity" "opxs" {
  comment = aws_route53_zone.opxs.name
}

resource "aws_cloudfront_distribution" "opxs" {
  origin {
    domain_name = aws_s3_bucket.opxs_web.bucket_regional_domain_name
    origin_id   = "opxs-s3"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.opxs.cloudfront_access_identity_path
    }
  }
  origin {

    domain_name = var.api_domain_name
    origin_id   = "opxs-api-alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = [aws_route53_zone.opxs.name]
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "opxs-s3"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_normalization.arn
    }
    min_ttl                = 0
    default_ttl            = 10
    max_ttl                = 10
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = "opxs-api-alb"
    forwarded_values {
      query_string = false
      cookies {
        forward = "all"
      }
    }
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP", "US"]
    }
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.opxs.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

resource "aws_cloudfront_function" "url_normalization" {
  name    = "url_normalization"
  runtime = "cloudfront-js-1.0"
  comment = "Appends index.html to request URLs"
  publish = true
  code    = <<EOF
function handler(event) {
    var request = event.request;
    var uri = request.uri;

    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    } else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }

    return request;
}
  EOF
}
