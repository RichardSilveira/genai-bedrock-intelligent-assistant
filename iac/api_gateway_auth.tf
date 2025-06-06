# --------------------------------------------------
# API Gateway Authentication - API Key
# --------------------------------------------------

# Generate a secure API key
resource "random_password" "api_key" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store API key in SSM Parameter Store (more secure than environment variables)
resource "aws_ssm_parameter" "api_key" {
  name        = "/${local.resource_prefix}/api-key"
  description = "API Key for the Chatbot API"
  type        = "SecureString"
  value       = random_password.api_key.result

  tags = merge(local.default_tags, {
    Name = "${local.resource_prefix}-api-key"
  })
}

# Configure the authorizer for the API Gateway
resource "aws_apigatewayv2_authorizer" "api_key_authorizer" {
  api_id           = aws_apigatewayv2_api.chatbot_api.id
  authorizer_type  = "REQUEST"
  identity_sources = ["$request.header.x-api-key"]
  name             = "api-key-authorizer"

  authorizer_uri                    = module.authorizer_lambda.function_invoke_arn
  authorizer_payload_format_version = "2.0"
  authorizer_result_ttl_in_seconds  = 300
}

# Lambda permission for API Gateway to invoke the authorizer
resource "aws_lambda_permission" "api_gateway_auth_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.authorizer_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.chatbot_api.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.api_key_authorizer.id}"
}
