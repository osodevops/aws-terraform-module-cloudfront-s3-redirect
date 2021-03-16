resource "aws_cloudfront_distribution" "main" {
  provider = aws.cloudfront

  origin {
    origin_id   = "origin-${var.fqdn}"
    domain_name = "${var.bucket_name}.s3.amazonaws.com"
    s3_origin_config {
          origin_access_identity = aws_cloudfront_origin_access_identity.current.cloudfront_access_identity_path
    }
  }

  comment = "Distribution used for ${var.fqdn} redirect"

  enabled = true

  aliases = [var.fqdn]

  price_class = var.priceclass

  default_cache_behavior {
    target_origin_id = "origin-${var.fqdn}"
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.ssl_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
  
  web_acl_id = var.web_acl_id

  tags = var.common_tags

  depends_on = [
    aws_s3_bucket.main
  ]
}

resource "aws_cloudfront_origin_access_identity" "current" {}