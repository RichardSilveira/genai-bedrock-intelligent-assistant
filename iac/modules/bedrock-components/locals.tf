locals {

  # --------------------------------------------------
  # Custom
  # --------------------------------------------------
  combined_tags = merge(
    var.tags,
    {
      Component = "bedrock-rag"
    }
  )

  # --------------------------------------------------
  # KB Storage Configuration (Custom)
  # --------------------------------------------------

  pinecone_configuration = {
    connection_string      = var.connection_string
    credentials_secret_arn = var.credentials_secret_arn
    field_mapping = {
      metadata_field = var.metadata_field
      text_field     = var.text_field
      namespace      = var.namespace
    }
  }

  opensearch_serverless_configuration = {
    collection_arn    = var.kb_storage_type == "OPENSEARCH_SERVERLESS" ? module.oss_knowledgebase[0].opensearch_serverless_collection.arn : null
    vector_index_name = var.kb_storage_type == "OPENSEARCH_SERVERLESS" ? module.oss_knowledgebase[0].vector_index.name : null
    field_mapping = {
      metadata_field = var.metadata_field
      text_field     = var.text_field
      vector_field   = var.vector_field
    }
  }

  mongo_db_atlas_configuration = {
    collection_name        = var.collection_name
    credentials_secret_arn = var.credentials_secret_arn
    database_name          = var.database_name
    endpoint               = var.endpoint
    vector_index_name      = var.vector_index_name
    text_index_name        = var.text_index_name
    field_mapping = {
      metadata_field = var.metadata_field
      text_field     = var.text_field
      vector_field   = var.vector_field
    }
    endpoint_service_name = var.endpoint_service_name
  }

  neptune_analytics_configuration = {
    graph_arn = var.graph_arn
    field_mapping = {
      metadata_field = var.metadata_field
      text_field     = var.text_field
    }
  }

  rds_configuration = {
    credentials_secret_arn = var.credentials_secret_arn
    database_name          = var.database_name
    resource_arn           = var.resource_arn
    table_name             = var.table_name
    field_mapping = {
      metadata_field        = var.metadata_field
      primary_key_field     = var.primary_key_field
      text_field            = var.text_field
      vector_field          = var.vector_field
      custom_metadata_field = var.custom_metadata_field
    }
  }

  # --------------------------------------------------
  # Data Source
  # --------------------------------------------------
  create_cwl      = var.create_default_kb && var.create_kb_log_group
  create_delivery = local.create_cwl || var.kb_monitoring_arn != null
  vector_ingestion_configuration = {
    chunking_configuration = var.chunking_strategy == null ? null : {
      chunking_strategy = var.chunking_strategy
      fixed_size_chunking_configuration = var.chunking_strategy_max_tokens == null ? null : {
        max_tokens         = var.chunking_strategy_max_tokens
        overlap_percentage = var.chunking_strategy_overlap_percentage
      }
      hierarchical_chunking_configuration = var.heirarchical_overlap_tokens == null && var.level_configurations_list == null ? null : {
        level_configurations = var.level_configurations_list
        overlap_tokens       = var.heirarchical_overlap_tokens
      }
      semantic_chunking_configuration = var.breakpoint_percentile_threshold == null && var.semantic_buffer_size == null && var.semantic_max_tokens == null ? null : {
        breakpoint_percentile_threshold = var.breakpoint_percentile_threshold
        buffer_size                     = var.semantic_buffer_size
        max_tokens                      = var.semantic_max_tokens
      }
    }
    custom_transformation_configuration = var.create_custom_tranformation_config == false ? null : {
      intermediate_storage = {
        s3_location = {
          uri = var.s3_location_uri
        }
      }
      transformations = var.transformations_list
    }
    parsing_configuration = var.create_parsing_configuration == false ? null : {
      bedrock_foundation_model_configuration = {
        model_arn = var.parsing_config_model_arn
        parsing_prompt = {
          parsing_prompt_text = var.parsing_prompt_text
        }
      }
      parsing_strategy = var.parsing_strategy
    }
  }

  # --------------------------------------------------
  # Data
  # --------------------------------------------------

  region           = data.aws_region.current.name
  account_id       = data.aws_caller_identity.current.account_id
  partition        = data.aws_partition.current.partition
  create_kb        = var.create_default_kb || var.create_rds_config || var.create_mongo_config || var.create_pinecone_config || var.create_opensearch_config || var.create_kb || var.create_kendra_config
  foundation_model = var.create_agent ? var.foundation_model : (var.create_supervisor ? var.supervisor_model : null)

  # --------------------------------------------------
  # IAM
  # --------------------------------------------------
  create_kb_role     = var.kb_role_arn == null && local.create_kb
  action_group_names = concat(var.action_group_lambda_names_list, [var.lambda_action_group_executor])
  agent_role_name    = var.agent_resource_role_arn != null ? split("/", var.agent_resource_role_arn)[1] : ((var.create_agent || var.create_supervisor) ? aws_iam_role.agent_role[0].name : null)


  # --------------------------------------------------
  # Main
  # --------------------------------------------------
  bedrock_agent_alias = var.create_agent_alias && var.use_aws_provider_alias ? aws_bedrockagent_agent_alias.bedrock_agent_alias : awscc_bedrock_agent_alias.bedrock_agent_alias

  counter_kb        = local.create_kb || var.existing_kb != null ? [1] : []
  knowledge_base_id = local.create_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : null
  knowledge_bases_value = {
    description          = var.kb_description
    knowledge_base_id    = local.create_kb ? local.knowledge_base_id : var.existing_kb
    knowledge_base_state = var.kb_state
  }
  kb_result = [for count in local.counter_kb : local.knowledge_bases_value]


  counter_action_group = var.create_ag ? [1] : []
  action_group_value = {
    action_group_name                    = var.action_group_name
    description                          = var.action_group_description
    action_group_state                   = var.action_group_state
    parent_action_group_signature        = var.parent_action_group_signature
    skip_resource_in_use_check_on_delete = var.skip_resource_in_use
    api_schema = {
      payload = var.api_schema_payload
      s3 = {
        s3_bucket_name = var.api_schema_s3_bucket_name
        s3_object_key  = var.api_schema_s3_object_key
      }
    }
    action_group_executor = {
      custom_control = var.custom_control
      lambda         = var.lambda_action_group_executor
    }
  }
  action_group_result = [for count in local.counter_action_group : local.action_group_value]

  # Create a map with action_group_name as keys for stable sorting
  action_group_map = var.action_group_list != null ? {
    for idx, ag in var.action_group_list :
    # Use action_group_name as key, or index if name is null
    coalesce(try(ag.action_group_name, ""), format("%04d", idx)) => ag
  } : {}

  # Extract values from the sorted map (Terraform maps are sorted by keys)
  sorted_action_groups = [for k, v in local.action_group_map : v]

  # Combine action groups with consistent ordering
  action_group_list = concat(local.action_group_result, local.sorted_action_groups)
}
