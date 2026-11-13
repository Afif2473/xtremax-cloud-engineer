locals {
  name_prefix = "${var.project_name}-${var.environment}"
  origin_id   = "${local.name_prefix}-alb-origin"
  use_acm     = var.cf_acm_certificate_arn != ""
}

# Amazon CloudFront Distribution

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name_prefix} WordPress CDN"
  price_class         = var.price_class
  http_version        = "http2and3"
  wait_for_deployment = false

  origin {
    domain_name = var.alb_dns_name
    origin_id   = local.origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin", "Authorization"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = local.use_acm ? false : true
    acm_certificate_arn            = local.use_acm ? var.cf_acm_certificate_arn : null
    ssl_support_method             = local.use_acm ? "sni-only" : null
    minimum_protocol_version       = local.use_acm ? "TLSv1.2_2021" : "TLSv1"
  }

  tags = {
    Name = "${local.name_prefix}-cloudfront"
  }
}
