module "bedrock" {
  source          = "./modules/bedrock-components"
  resource_prefix = local.resource_prefix

  create_default_kb               = true
  create_pinecone_config          = true
  kb_storage_type                 = var.kb_storage_type
  connection_string               = var.pinecone_connection_string
  credentials_secret_arn          = "arn:aws:secretsmanager:us-east-1:103881053461:secret:chatbot/dev/pinecone-api-CByFFV"
  create_agent                    = local.create_agent
  create_ag                       = local.create_agent
  create_s3_data_source           = true
  s3_inclusion_prefixes           = ["documents"]
  kb_embedding_model_arn          = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
  embedding_model_dimensions      = 512
  enable_model_invocation_logging = true

  # Agent/Action Group config
  agent_name         = "AnyTicketAgent"
  agent_alias_name   = "AnyTicketAgent"
  agent_description  = "Agent for AnyTicket customer support, using knowledge base and action group for event lookup."
  create_agent_alias = local.create_agent
  instruction        = <<EOT
  You are a helpful, secure, and friendly customer support agent for AnyTicket, a ticket service for events.
  - Provide clear, accurate, concise, and friendly responses.
  - While asking for events, assume 2025 as the year in case the user does not informs it
  - Prioritize the available actions groups when user ask for event details and use the knowledge base ONLY to answer general questions such as redund policy and payment methods.
  EOT

  foundation_model             = "us.anthropic.claude-3-7-sonnet-20250219-v1:0"
  action_group_name            = "available-events-action-group"
  action_group_description     = "Action group to get details about events"
  action_group_state           = "ENABLED"
  lambda_action_group_executor = module.agent_action_group_lambda.function_arn
  api_schema_payload           = file("${path.module}/modules/bedrock-components/action-group.yaml")

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

  tags             = local.default_tags
  agent_alias_tags = local.default_tags
  kb_tags          = local.default_tags
  guardrail_tags   = local.default_tags_list
}
