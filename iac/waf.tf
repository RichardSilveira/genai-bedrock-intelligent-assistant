# --------------------------------------------------
# AWS WAF Web ACL for CloudFront Distribution
# --------------------------------------------------

resource "aws_wafv2_web_acl" "cloudfront_waf" {
  provider    = aws.us_east_1 # Must use us-east-1 for CloudFront WAF
  name        = "${local.resource_prefix}-cloudfront-waf"
  description = "WAF Web ACL for CloudFront distribution"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # 1. Amazon IP Reputation List - Blocks requests from IP addresses identified as malicious
  # Low WCU (25), high efficiency, blocks malicious IPs at the edge
  rule {
    name     = "AmazonIpReputationList"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"

        # Ensure rules terminate immediately for better performance
        rule_action_override {
          name = "AWSManagedIPReputationList"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "AWSManagedReconnaissanceList"
          action_to_use {
            block {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  # 2. Rate-based rule to prevent DDoS attacks - Limits requests from any single IP
  # Low WCU cost, effective against brute force and DDoS attacks
  rule {
    name     = "RateLimitRule"
    priority = 20

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # 3. Known Bad Inputs - Blocks request patterns known to be invalid and associated with exploitation
  # Medium WCU (200), high efficiency at blocking known attack patterns
  rule {
    name     = "KnownBadInputs"
    priority = 30

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"

        # Ensure rules terminate immediately for better performance
        rule_action_override {
          name = "Host_localhost_HEADER"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "PROPFIND_METHOD"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "ExploitablePaths_URIPATH"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "JavaDeserializationRCE_HEADER"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "JavaDeserializationRCE_BODY"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "JavaDeserializationRCE_URIPATH"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "JavaDeserializationRCE_QUERYSTRING"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "Log4JRCE_HEADER"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "Log4JRCE_QUERYSTRING"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "Log4JRCE_BODY"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "Log4JRCE_URIPATH"
          action_to_use {
            block {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  # 4. Anonymous IP List - Blocks requests from services that permit obfuscation of viewer identity
  # Medium WCU (50), blocks anonymous IPs that might be trying to hide their identity
  rule {
    name     = "AnonymousIpList"
    priority = 40

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"

        # Ensure rules terminate immediately for better performance
        rule_action_override {
          name = "AnonymousIPList"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "HostingProviderIPList"
          action_to_use {
            block {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

  # 5. Core Rule Set - Provides protection against common web exploits
  # Highest WCU (700), comprehensive but more resource-intensive
  rule {
    name     = "CoreRuleSet"
    priority = 50

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        # Ensure high-risk rules terminate immediately
        rule_action_override {
          name = "NoUserAgent_HEADER"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "UserAgent_BadBots_HEADER"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "CrossSiteScripting_COOKIE"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "CrossSiteScripting_QUERYARGUMENTS"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "CrossSiteScripting_BODY"
          action_to_use {
            block {}
          }
        }

        rule_action_override {
          name = "CrossSiteScripting_URIPATH"
          action_to_use {
            block {}
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CoreRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # Global configuration for the Web ACL
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.resource_prefix}-cloudfront-waf-metrics"
    sampled_requests_enabled   = true
  }

  tags = merge(local.default_tags, {
    Name = "${local.resource_prefix}-cloudfront-waf"
  })
}

# --------------------------------------------------
# WAF Web ACL Association with CloudFront Distribution
# --------------------------------------------------

# CloudFront ARN format is different for WAF associations
# Format: arn:aws:cloudfront::account-id:distribution/distribution-id
# resource "aws_wafv2_web_acl_association" "cloudfront_waf_association" {
#   provider     = aws.us_east_1 # Must use us-east-1 for CloudFront WAF
#   resource_arn = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.api_distribution.id}"
#   web_acl_arn  = aws_wafv2_web_acl.cloudfront_waf.arn
# }

# --------------------------------------------------
# CloudWatch Logs for WAF
# --------------------------------------------------

resource "aws_cloudwatch_log_group" "waf_logs" {
  provider          = aws.us_east_1
  name              = "aws-waf-logs-${local.resource_prefix}-cloudfront-waf"
  retention_in_days = 90
  tags = merge(local.default_tags, {
    Name = "${local.resource_prefix}-waf-logs"
  })
}

# --------------------------------------------------
# WAF Logging Configuration
# --------------------------------------------------

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging" {
  provider                = aws.us_east_1 # Must use us-east-1 for CloudFront WAF
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]
  resource_arn            = aws_wafv2_web_acl.cloudfront_waf.arn

  logging_filter {
    default_behavior = "KEEP"
    filter {
      behavior = "KEEP"
      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}
