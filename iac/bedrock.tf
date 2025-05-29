module "bedrock" {
  source          = "./modules/bedrock-components"
  resource_prefix = local.resource_prefix

  create_default_kb               = true # opensearch serverless is the default storage option
  create_agent                    = false
  create_s3_data_source           = true
  s3_inclusion_prefixes           = ["documents"]
  kb_embedding_model_arn          = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
  enable_model_invocation_logging = true
  # collection_tags                 = local.default_tags_list
  kb_tags = local.default_tags
}
