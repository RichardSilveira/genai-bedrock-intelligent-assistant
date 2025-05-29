# - Knowledge Base S3 Data Source –
resource "awscc_s3_bucket" "s3_data_source" {
  count       = (var.create_s3_data_source || var.create_kendra_s3_data_source) && var.use_existing_s3_data_source == false ? 1 : 0
  bucket_name = "${var.resource_prefix}-${var.kb_name}-default-bucket"


  public_access_block_configuration = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  bucket_encryption = {
    server_side_encryption_configuration = [{
      bucket_key_enabled = true
      server_side_encryption_by_default = {
        sse_algorithm     = var.kb_s3_data_source_kms_arn == null ? "AES256" : "aws:kms" # AES256 => S3-SSE
        kms_master_key_id = var.kb_s3_data_source_kms_arn
      }
    }]
  }

  tags = var.kb_tags != null ? [for k, v in var.kb_tags : { key = k, value = v }] : [{
    key   = "Name"
    value = "S3 Data Source"
  }]

  # checkov:skip=CKV2_AWS_62: "Event notifications - TBD"
  # checkov:skip=CKV_AWS_18: "Access logging - TBD
  # checkov:skip=CKV_AWS_145: "KMS encryption - a must have for compliance and auditing, but not mandatory for security concerns"
  # checkov:skip=CKV_AWS_144: "Cross-region Replication - a must have for fault-tolerant applications"
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_data_source_lifecycle" {
  bucket = awscc_s3_bucket.s3_data_source[0].id

  # 💰 once a object is synced to kb underlying vector store, it won't be frequently accessed anymore
  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  # 💰 To not to pay for unused resource usage
  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "awscc_bedrock_data_source" "knowledge_base_ds" {
  count                = var.create_s3_data_source ? 1 : 0
  knowledge_base_id    = var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : var.existing_kb
  name                 = "${var.resource_prefix}-${var.kb_name}DataSource"
  data_deletion_policy = var.data_deletion_policy
  data_source_configuration = {
    type = "S3"
    s3_configuration = {
      bucket_arn              = var.kb_s3_data_source == null ? awscc_s3_bucket.s3_data_source[0].arn : var.kb_s3_data_source # Create an S3 bucket or reference existing
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

# – Knowledge Base Web Crawler Data Source
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

# – Knowledge Base Confluence Data Source
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

# – Knowledge Base Sharepoint Data Source
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

# – Knowledge Base Salesforce Data Source
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
