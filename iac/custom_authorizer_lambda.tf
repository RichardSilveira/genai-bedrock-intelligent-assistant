# Create a zip file of the Lambda function code
data "archive_file" "authorizer_lambda" {
  type        = "zip"
  source_file = "${path.module}/../src/authorizer.py"
  output_path = "${path.module}/lambda-packages/authorizer.zip"
}

# API Key Authorizer Lambda function
module "authorizer_lambda" {
  source = "./modules/lambda"

  resource_prefix = local.resource_prefix
  function_name   = "api-key-authorizer"
  description     = "Lambda Authorizer for API Key validation"

  source_path = data.archive_file.authorizer_lambda.output_path

  handler     = "authorizer.lambda_handler"
  runtime     = "python3.11"
  timeout     = 10
  memory_size = 128

  environment_variables = {
    API_KEY_PARAM_NAME = "/${local.resource_prefix}/api-key"
  }

  # Deploy Lambda in the private subnets with access to NAT Gateway
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [aws_security_group.lambda_sg.id]

  layers = [
    local.lambda_layer_power_tools
  ]

  # Add permissions to access SSM Parameter Store
  additional_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "ssm:GetParameter",
        "kms:Decrypt"
      ]
      Resource = [
        "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${local.resource_prefix}/api-key"
      ]
    }
  ]
}
