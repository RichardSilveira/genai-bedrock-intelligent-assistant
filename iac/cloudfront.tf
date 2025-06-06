# --------------------------------------------------
# CloudFront Distribution for API Gateway
# --------------------------------------------------

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host_header" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "api_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ${local.resource_prefix} API Gateway"
  price_class         = "PriceClass_100" # North America and Europe only
  wait_for_deployment = true

  # Origin configuration for API Gateway
  origin {
    domain_name = replace(aws_apigatewayv2_api.chatbot_api.api_endpoint, "/^https?://([^/]*).*/", "$1")
    origin_id   = "apiGateway"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # Default cache behavior
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "apiGateway"

    # Use the CachingDisabled managed policy since this is a dynamic API
    cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id

    # Use AllViewerExceptHostHeader managed policy to forward all headers except Host
    # Recommended for API Gateway origins
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host_header.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # Required restrictions block - no restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL certificate - using CloudFront default certificate
  viewer_certificate {
    cloudfront_default_certificate = true
  }

}
