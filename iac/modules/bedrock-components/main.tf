# – Bedrock Agent –

# Add a sleep after creating the inference profile to ensure it's fully available
resource "time_sleep" "wait_for_inference_profile" {
  count           = var.create_app_inference_profile ? 1 : 0
  depends_on      = [awscc_bedrock_application_inference_profile.application_inference_profile[0]]
  create_duration = "5s"
}

resource "awscc_bedrock_agent" "bedrock_agent" {
  count                       = var.create_agent ? 1 : 0
  agent_name                  = "${var.resource_prefix}-${var.agent_name}"
  foundation_model            = var.create_app_inference_profile ? awscc_bedrock_application_inference_profile.application_inference_profile[0].inference_profile_arn : var.foundation_model
  instruction                 = var.instruction
  description                 = var.agent_description
  idle_session_ttl_in_seconds = var.idle_session_ttl
  agent_resource_role_arn     = var.agent_resource_role_arn != null ? var.agent_resource_role_arn : aws_iam_role.agent_role[0].arn
  # As `User Input` is not supported yet it needs to be enabled manually in AWS Console

  customer_encryption_key_arn = var.kms_key_arn
  tags                        = var.tags
  prompt_override_configuration = var.prompt_override == false ? null : {
    prompt_configurations = [{
      prompt_type = var.prompt_type
      inference_configuration = {
        temperature    = var.temperature
        top_p          = var.top_p
        top_k          = var.top_k
        stop_sequences = var.stop_sequences
        maximum_length = var.max_length
      }
      base_prompt_template = var.base_prompt_template
      parser_mode          = var.parser_mode
      prompt_creation_mode = var.prompt_creation_mode
      prompt_state         = var.prompt_state

    }]
    override_lambda = var.override_lambda_arn

  }
  # open issue: https://github.com/hashicorp/terraform-provider-awscc/issues/2004
  # auto_prepare needs to be set to true
  auto_prepare    = true
  knowledge_bases = length(local.kb_result) > 0 ? local.kb_result : null
  action_groups   = length(local.action_group_list) > 0 ? local.action_group_list : null
  guardrail_configuration = var.create_guardrail == false ? null : {
    guardrail_identifier = awscc_bedrock_guardrail.guardrail[0].id
    guardrail_version    = awscc_bedrock_guardrail_version.guardrail[0].version
  }
  memory_configuration = var.memory_configuration

  depends_on = [time_sleep.wait_for_inference_profile]
}

# Agent Alias

resource "awscc_bedrock_agent_alias" "bedrock_agent_alias" {
  count            = var.create_agent_alias && var.use_aws_provider_alias == false ? 1 : 0
  agent_alias_name = var.agent_alias_name
  agent_id         = var.create_agent ? awscc_bedrock_agent.bedrock_agent[0].id : var.agent_id
  description      = var.agent_alias_description
  routing_configuration = var.bedrock_agent_version == null ? null : [
    {
      agent_version = var.bedrock_agent_version
    }
  ]
  tags = var.agent_alias_tags
}

resource "aws_bedrockagent_agent_alias" "bedrock_agent_alias" {
  count            = var.create_agent_alias && var.use_aws_provider_alias ? 1 : 0
  agent_alias_name = var.agent_alias_name
  agent_id         = var.create_agent ? awscc_bedrock_agent.bedrock_agent[0].id : var.agent_id
  description      = var.agent_alias_description
  routing_configuration = var.bedrock_agent_version == null ? null : [
    {
      agent_version          = var.bedrock_agent_version
      provisioned_throughput = var.bedrock_agent_alias_provisioned_throughput
    }
  ]
  tags = var.agent_alias_tags
}

# – Guardrail –

resource "awscc_bedrock_guardrail" "guardrail" {
  count                     = var.create_guardrail ? 1 : 0
  name                      = "${var.resource_prefix}-${var.guardrail_name}"
  blocked_input_messaging   = var.blocked_input_messaging
  blocked_outputs_messaging = var.blocked_outputs_messaging
  description               = var.guardrail_description
  content_policy_config = {
    filters_config = var.filters_config
  }
  sensitive_information_policy_config = {
    pii_entities_config = var.pii_entities_config
    regexes_config      = var.regexes_config
  }
  word_policy_config = {
    managed_word_lists_config = var.managed_word_lists_config
    words_config              = var.words_config
  }
  topic_policy_config = var.topics_config == null ? null : {
    topics_config = var.topics_config
  }
  tags        = var.guardrail_tags
  kms_key_arn = var.guardrail_kms_key_arn

  # 🐛 As the awscc provider is not so mature, we need to add this at some point to prevent perpetual in-place updates
  lifecycle {
    ignore_changes = [
      tags,
      content_policy_config.filters_config
    ]
  }
}

resource "awscc_bedrock_guardrail_version" "guardrail" {
  count                = var.create_guardrail ? 1 : 0
  guardrail_identifier = awscc_bedrock_guardrail.guardrail[0].guardrail_id
  description          = "Guardrail version"
}
