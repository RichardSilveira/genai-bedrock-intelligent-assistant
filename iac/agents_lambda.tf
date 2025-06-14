# Create a zip file of the Lambda function code
data "archive_file" "agent_entrypoint_lambda" {
  count       = local.create_agent ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/../src/agent.py"
  output_path = "${path.module}/lambda-packages/agent_entrypoint.zip"
}

# Agent Entrypoint Lambda function
module "agent_entrypoint_lambda" {
  count  = local.create_agent ? 1 : 0
  source = "./modules/lambda"

  resource_prefix = local.resource_prefix
  function_name   = "agent-entrypoint"
  description     = "Bedrock Agent Entrypoint Lambda Function"

  source_path = data.archive_file.agent_entrypoint_lambda[0].output_path

  handler     = "agent.lambda_handler"
  runtime     = "python3.11"
  timeout     = 30
  memory_size = 256

  environment_variables = {
    BEDROCK_AGENT_ID       = module.bedrock.bedrock_agent_id
    BEDROCK_AGENT_ALIAS_ID = module.bedrock.bedrock_agent_alias_id
  }

  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [aws_security_group.lambda_sg.id]

  layers = [
    local.lambda_layer_power_tools
  ]

  additional_policy_statements = [
    {
      Effect = "Allow"
      Action = local.base_agent_invoke_actions
      Resource = concat(local.base_fundation_model_resources, [
        "arn:aws:bedrock:${local.region}:${local.account_id}:agent/${module.bedrock.bedrock_agent_id}",
        "arn:aws:bedrock:${local.region}:${local.account_id}:agent-alias/${module.bedrock.bedrock_agent_id}/*",
      ])
    }
  ]
}
