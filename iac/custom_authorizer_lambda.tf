# --------------------------------------------------
# API Gateway Custom Authorizer Lambda
# --------------------------------------------------

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
  description     = "Lambda Authorizer for API Key validation and CloudFront origin verification"

  source_path = data.archive_file.authorizer_lambda.output_path

  handler     = "authorizer.lambda_handler"
  runtime     = "python3.11"
  timeout     = 10
  memory_size = 128

  environment_variables = {
    API_KEY_PARAM_NAME           = "/${local.resource_prefix}/api-key"
    CLOUDFRONT_SECRET_PARAM_NAME = "/${local.resource_prefix}/cloudfront-secret"
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
        "ssm:GetParameter"
      ]
      Resource = [
        "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${local.resource_prefix}/api-key",
        "arn:aws:ssm:${local.region}:${local.account_id}:parameter/${local.resource_prefix}/cloudfront-secret"
      ]
    },
    {
      Effect = "Allow"
      Action = [
        "kms:Decrypt"
      ]
      Resource = [
        "*" # In production, you should scope this down to the specific KMS key ARN used for SSM encryption
      ]
    }
  ]
}
