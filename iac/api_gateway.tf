# --------------------------------------------------
# API Gateway HTTP API
# --------------------------------------------------

resource "aws_apigatewayv2_api" "chatbot_api" {
  name          = "${local.resource_prefix}-chatbot-api"
  protocol_type = "HTTP"
  description   = "HTTP API for Bedrock RAG Chatbot"

  cors_configuration {
    allow_origins = ["*"] # For production, restrict to specific domains
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization", "X-Amz-Date", "X-Api-Key", "X-Origin-Verify", "X-Amz-Security-Token"]
    max_age       = 300
  }

  tags = merge(local.default_tags, {
    Name = "${local.resource_prefix}-chatbot-api"
  })
}

# --------------------------------------------------
# Lambda Integrations
# --------------------------------------------------

resource "aws_apigatewayv2_integration" "chatbot_lambda_integration" {
  api_id           = aws_apigatewayv2_api.chatbot_api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "Lambda integration for Bedrock RAG Chatbot"
  integration_method = "POST"
  integration_uri    = module.chatbot_lambda.function_invoke_arn

  payload_format_version = "2.0" # Using the latest payload format for HTTP APIs
}

resource "aws_apigatewayv2_integration" "agent_entrypoint_lambda_integration" {
  count                  = local.create_agent ? 1 : 0
  api_id                 = aws_apigatewayv2_api.chatbot_api.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  description            = "Lambda integration for Bedrock Agent Entrypoint"
  integration_method     = "POST"
  integration_uri        = module.agent_entrypoint_lambda[0].function_invoke_arn
  payload_format_version = "2.0"
}

# --------------------------------------------------
# API Routes
# --------------------------------------------------

resource "aws_apigatewayv2_route" "chatbot_post_route" {
  api_id             = aws_apigatewayv2_api.chatbot_api.id
  route_key          = "POST /chat"
  target             = "integrations/${aws_apigatewayv2_integration.chatbot_lambda_integration.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.api_key_authorizer.id
}

resource "aws_apigatewayv2_route" "chatbot_options_route" {
  api_id    = aws_apigatewayv2_api.chatbot_api.id
  route_key = "OPTIONS /chat"
  target    = "integrations/${aws_apigatewayv2_integration.chatbot_lambda_integration.id}"
  # OPTIONS requests don't need authorization for CORS preflight
}

resource "aws_apigatewayv2_route" "agent_post_route" {
  count              = local.create_agent ? 1 : 0
  api_id             = aws_apigatewayv2_api.chatbot_api.id
  route_key          = "POST /agent"
  target             = "integrations/${aws_apigatewayv2_integration.agent_entrypoint_lambda_integration[0].id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.api_key_authorizer.id
}

resource "aws_apigatewayv2_route" "agent_options_route" {
  count     = local.create_agent ? 1 : 0
  api_id    = aws_apigatewayv2_api.chatbot_api.id
  route_key = "OPTIONS /agent"
  target    = "integrations/${aws_apigatewayv2_integration.agent_entrypoint_lambda_integration[0].id}"
}

# --------------------------------------------------
# API Stage
# --------------------------------------------------

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.chatbot_api.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      ip                      = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      httpMethod              = "$context.httpMethod"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      protocol                = "$context.protocol"
      responseLength          = "$context.responseLength"
      errorMessage            = "$context.error.message"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  default_route_settings {
    throttling_burst_limit   = 100
    throttling_rate_limit    = 50
    detailed_metrics_enabled = true
  }

  tags = merge(local.default_tags, {
    Name = "${local.resource_prefix}-chatbot-api-default-stage"
  })
}

# --------------------------------------------------
# CloudWatch Logs
# --------------------------------------------------

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${local.resource_prefix}-chatbot-api"
  retention_in_days = 14

  tags = merge(local.default_tags, {
    Name = "${local.resource_prefix}-chatbot-api-logs"
  })
}

# --------------------------------------------------
# Lambda Permissions for API Gateway
# --------------------------------------------------

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.chatbot_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Allow invocation from any route in the API
  source_arn = "${aws_apigatewayv2_api.chatbot_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_agent_lambda" {
  count         = local.create_agent ? 1 : 0
  statement_id  = "AllowExecutionFromAPIGatewayAgent"
  action        = "lambda:InvokeFunction"
  function_name = module.agent_entrypoint_lambda[0].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.chatbot_api.execution_arn}/*/*"
}
