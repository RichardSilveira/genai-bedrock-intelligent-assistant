module "bedrock" {
  source          = "./modules/bedrock-components"
  resource_prefix = local.resource_prefix

  create_default_kb               = true
  create_pinecone_config          = true
  kb_storage_type                 = var.kb_storage_type
  connection_string               = var.pinecone_connection_string
  credentials_secret_arn          = "arn:aws:secretsmanager:us-east-1:103881053461:secret:chatbot/dev/pinecone-api-CByFFV"
  create_agent                    = false
  create_s3_data_source           = true
  s3_inclusion_prefixes           = ["documents"]
  kb_embedding_model_arn          = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
  embedding_model_dimensions      = 512
  enable_model_invocation_logging = true
  # collection_tags                 = local.default_tags_list

  create_guardrail = true
  filters_config = [
    {
      input_strength  = "MEDIUM"
      output_strength = "MEDIUM"
      type            = "HATE"
    },
    {
      input_strength  = "HIGH"
      output_strength = "HIGH"
      type            = "VIOLENCE"
    }
  ]
  pii_entities_config = [
    {
      action = "BLOCK"
      type   = "NAME"
    },
    {
      action = "BLOCK"
      type   = "EMAIL"
    },
    {
      action = "BLOCK"
      type   = "ADDRESS"
    },
  ]
  regexes_config = [{
    action      = "BLOCK"
    description = "example regex"
    name        = "regex_example"
    pattern     = "^\\d{3}-\\d{2}-\\d{4}$"
  }]
  managed_word_lists_config = [{
    type = "PROFANITY"
  }]
  words_config = [{
    text = "HATE"
  }]

  kb_tags        = local.default_tags
  guardrail_tags = local.default_tags_list
}
