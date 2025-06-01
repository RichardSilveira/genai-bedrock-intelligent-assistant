module "bedrock" {
  source          = "./modules/bedrock-components"
  resource_prefix = local.resource_prefix

  # create_default_kb               = true # opensearch serverless is the default storage option
  create_default_kb               = true # pinecone is the default storage option
  create_pinecone_config          = true
  kb_storage_type                 = "PINECONE"
  connection_string               = var.pinecone_connection_string
  credentials_secret_arn          = "arn:aws:secretsmanager:us-east-1:103881053461:secret:chatbot/dev/pinecone-api-CByFFV"
  create_agent                    = false
  create_s3_data_source           = true
  s3_inclusion_prefixes           = ["documents"]
  kb_embedding_model_arn          = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
  embedding_model_dimensions      = 512
  enable_model_invocation_logging = true
  # collection_tags                 = local.default_tags_list
  kb_tags = local.default_tags
}
