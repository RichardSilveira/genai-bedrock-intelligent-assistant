# - Knowledge Base S3 Data Source –
module "kb_data_source_bucket" {
  source          = "../s3"
  count           = (var.create_s3_data_source || var.create_kendra_s3_data_source) && var.use_existing_s3_data_source == false ? 1 : 0
  resource_prefix = var.resource_prefix
  name            = "${var.kb_name}-data-source"
  lifecycle_mode  = "standard"
  tags            = var.kb_tags != null ? var.kb_tags : { Name = "S3 Data Source" }

  # Add resource policy to allow Bedrock service to access the bucket
  # while denying access to all other principals except the root account and current caller
  resource_policy = var.create_default_kb ? jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyAllOthers"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${var.resource_prefix}-${var.kb_name}-data-source",
          "arn:aws:s3:::${var.resource_prefix}-${var.kb_name}-data-source/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:PrincipalServiceName" : "bedrock.amazonaws.com"
          }
          ArnNotLike = {
            "aws:PrincipalArn" : [
              "arn:aws:iam::${local.account_id}:root",
              data.aws_caller_identity.current.arn,
              var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
            ]
          }
        }
      }
    ]
  }) : null
}

resource "awscc_bedrock_data_source" "knowledge_base_ds" {
  count                = var.create_s3_data_source ? 1 : 0
  knowledge_base_id    = var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : var.existing_kb
  name                 = "${var.resource_prefix}-${var.kb_name}DataSource"
  data_deletion_policy = var.data_deletion_policy
  data_source_configuration = {
    type = "S3"
    s3_configuration = {
      bucket_arn              = var.kb_s3_data_source == null ? module.kb_data_source_bucket[0].bucket_arn : var.kb_s3_data_source
      bucket_owner_account_id = var.bucket_owner_account_id
      inclusion_prefixes      = var.s3_inclusion_prefixes
    }
  }
  vector_ingestion_configuration = var.create_vector_ingestion_configuration == false ? null : local.vector_ingestion_configuration
}

resource "aws_cloudwatch_log_group" "knowledge_base_cwl" {
  #tfsec:ignore:log-group-customer-key
  #checkov:skip=CKV_AWS_158:Encryption not required for log group
  count             = local.create_cwl ? 1 : 0
  name              = "/aws/vendedlogs/bedrock/knowledge-base/APPLICATION_LOGS/${awscc_bedrock_knowledge_base.knowledge_base_default[0].id}"
  retention_in_days = var.kb_log_group_retention_in_days
}

resource "awscc_logs_delivery_source" "knowledge_base_log_source" {
  count        = local.create_delivery ? 1 : 0
  name         = "${var.resource_prefix}-${var.kb_name}-delivery-source"
  log_type     = "APPLICATION_LOGS"
  resource_arn = awscc_bedrock_knowledge_base.knowledge_base_default[0].knowledge_base_arn
}

resource "awscc_logs_delivery_destination" "knowledge_base_log_destination" {
  count                    = local.create_delivery ? 1 : 0
  name                     = "${var.resource_prefix}-${var.kb_name}-delivery-destination"
  output_format            = "json"
  destination_resource_arn = local.create_cwl ? aws_cloudwatch_log_group.knowledge_base_cwl[0].arn : var.kb_monitoring_arn
  tags = var.kb_tags != null ? [for k, v in var.kb_tags : { key = k, value = v }] : [{
    key   = "Name"
    value = "${var.resource_prefix}-${var.kb_name}-delivery-destination"
  }]
}

resource "awscc_logs_delivery" "knowledge_base_log_delivery" {
  count                    = local.create_delivery ? 1 : 0
  delivery_destination_arn = awscc_logs_delivery_destination.knowledge_base_log_destination[0].arn
  delivery_source_name     = awscc_logs_delivery_source.knowledge_base_log_source[0].name
  tags = var.kb_tags != null ? [for k, v in var.kb_tags : { key = k, value = v }] : [{
    key   = "Name"
    value = "${var.resource_prefix}-${var.kb_name}-delivery"
  }]
}

# – Knowledge Base Web Crawler Data Source
resource "awscc_bedrock_data_source" "knowledge_base_web_crawler" {
  count             = var.create_web_crawler ? 1 : 0
  knowledge_base_id = var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : var.existing_kb
  name              = "${var.resource_prefix}-${var.kb_name}DataSourceWebCrawler"
  data_source_configuration = {
    type = "WEB"
    web_configuration = {
      crawler_configuration = {
        crawler_limits = {
          rate_limit = var.rate_limit
        }
        exclusion_filters = var.exclusion_filters
        inclusion_filters = var.inclusion_filters
        scope             = var.crawler_scope
      }
      source_configuration = {
        url_configuration = {
          seed_urls = var.seed_urls
        }
      }
    }
  }
  vector_ingestion_configuration = var.create_vector_ingestion_configuration == false ? null : local.vector_ingestion_configuration
}

# – Knowledge Base Confluence Data Source
resource "awscc_bedrock_data_source" "knowledge_base_confluence" {
  count             = var.create_confluence ? 1 : 0
  knowledge_base_id = var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : var.existing_kb
  name              = "${var.resource_prefix}-${var.kb_name}DataSourceConfluence"
  data_source_configuration = {
    type = "CONFLUENCE"
    confluence_configuration = {
      crawler_configuration = {
        filter_configuration = {
          pattern_object_filter = {
            filters = var.pattern_object_filter_list
          }
          type = var.crawl_filter_type
        }
      }
      source_configuration = {
        auth_type              = var.auth_type
        credentials_secret_arn = var.confluence_credentials_secret_arn
        host_type              = var.host_type
        host_url               = var.host_url
      }
    }
  }
  vector_ingestion_configuration = var.create_vector_ingestion_configuration == false ? null : local.vector_ingestion_configuration
}

# – Knowledge Base Sharepoint Data Source
resource "awscc_bedrock_data_source" "knowledge_base_sharepoint" {
  count             = var.create_sharepoint ? 1 : 0
  knowledge_base_id = var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : var.existing_kb
  name              = "${var.resource_prefix}-${var.kb_name}DataSourceSharepoint"
  data_source_configuration = {
    type = "SHAREPOINT"
    share_point_configuration = {
      crawler_configuration = {
        filter_configuration = {
          pattern_object_filter = {
            filters = var.pattern_object_filter_list
          }
          type = var.crawl_filter_type
        }
      }
      source_configuration = {
        auth_type              = var.auth_type
        credentials_secret_arn = var.share_point_credentials_secret_arn
        domain                 = var.share_point_domain
        host_type              = var.host_type
        site_urls              = var.share_point_site_urls
        tenant_id              = var.tenant_id
      }
    }
  }
  vector_ingestion_configuration = var.create_vector_ingestion_configuration == false ? null : local.vector_ingestion_configuration
}

# – Knowledge Base Salesforce Data Source
resource "awscc_bedrock_data_source" "knowledge_base_salesforce" {
  count             = var.create_salesforce ? 1 : 0
  knowledge_base_id = var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : var.existing_kb
  name              = "${var.resource_prefix}-${var.kb_name}DataSourceSalesforce"
  data_source_configuration = {
    type = "SALESFORCE"
    salesforce_configuration = {
      crawler_configuration = {
        filter_configuration = {
          pattern_object_filter = {
            filters = var.pattern_object_filter_list
          }
          type = var.crawl_filter_type
        }
      }
      source_configuration = {
        auth_type              = var.auth_type
        credentials_secret_arn = var.salesforce_credentials_secret_arn
        host_url               = var.host_url
      }
    }
  }
  vector_ingestion_configuration = var.create_vector_ingestion_configuration == false ? null : local.vector_ingestion_configuration
}
