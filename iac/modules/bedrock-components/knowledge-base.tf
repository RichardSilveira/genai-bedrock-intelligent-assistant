# - Knowledge Base Default -
resource "awscc_bedrock_knowledge_base" "knowledge_base_default" {
  count       = var.create_default_kb ? 1 : 0
  name        = "${var.resource_prefix}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  storage_configuration = merge({ type = var.kb_storage_type },
    var.kb_storage_type == "PINECONE" ? { pinecone_configuration = local.pinecone_configuration } : {},
    var.kb_storage_type == "OPENSEARCH_SERVERLESS" ? { opensearch_serverless_configuration = local.opensearch_serverless_configuration } : {},
    var.kb_storage_type == "MONGODB_ATLAS" ? { mongo_db_atlas_configuration = local.mongo_db_atlas_configuration } : {},
    var.kb_storage_type == "NEPTUNE_ANALYTICS" ? { neptune_analytics_configuration = local.neptune_analytics_configuration } : {},
    var.kb_storage_type == "RDS" ? { rds_configuration = local.rds_configuration } : {}
  )

  knowledge_base_configuration = {
    type = var.kb_type
    vector_knowledge_base_configuration = {
      embedding_model_arn = var.kb_embedding_model_arn
      embedding_model_configuration = var.embedding_model_dimensions != null ? {
        bedrock_embedding_model_configuration = {
          dimensions          = var.embedding_model_dimensions
          embedding_data_type = var.embedding_data_type
        }
      } : null
      supplemental_data_storage_configuration = var.create_supplemental_data_storage ? {
        supplemental_data_storage_locations = [
          {
            supplemental_data_storage_location_type = "S3"
            s3_location = {
              uri = var.supplemental_data_s3_uri
            }
          }
        ]
      } : null
    }
  }

  # only enable it when the storage type is opensearch serverless
  # depends_on = [time_sleep.wait_after_index_creation]
}


# – Kendra Knowledge Base –

# resource "awscc_bedrock_knowledge_base" "knowledge_base_kendra" {
#   count       = var.create_kendra_config ? 1 : 0
#   name        = "${var.resource_prefix}-${var.kb_name}"
#   description = var.kb_description
#   role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
#   tags        = var.kb_tags

#   knowledge_base_configuration = {
#     type = "KENDRA"
#     kendra_knowledge_base_configuration = {
#       kendra_index_arn = var.kendra_index_arn != null ? var.kendra_index_arn : awscc_kendra_index.genai_kendra_index[0].arn
#     }
#   }

#   depends_on = [time_sleep.wait_after_kendra_index_creation, time_sleep.wait_after_kendra_s3_data_source_creation]
# }

# – SQL Knowledge Base –

resource "awscc_bedrock_knowledge_base" "knowledge_base_sql" {
  count       = var.create_sql_config ? 1 : 0
  name        = "${var.resource_prefix}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  knowledge_base_configuration = {
    type = "SQL"
    sql_knowledge_base_configuration = {
      type = "REDSHIFT"
      redshift_configuration = {
        query_engine_configuration = {
          serverless_configuration = var.sql_kb_workgroup_arn == null ? null : {
            workgroup_arn      = var.sql_kb_workgroup_arn
            auth_configuration = var.serverless_auth_configuration
          }
          provisioned_configuration = var.provisioned_config_cluster_identifier == null ? null : {
            cluster_identifier = var.provisioned_config_cluster_identifier
            auth_configuration = var.provisioned_auth_configuration
          }
          type = var.redshift_query_engine_type
        }
        query_generation_configuration = var.query_generation_configuration
        storage_configurations         = var.redshift_storage_configuration
      }

    }
  }

}
