# Create a zip file of the Lambda function code
data "archive_file" "chatbot_lambda" {
  type        = "zip"
  source_file = "${path.module}/../src/chatbot.py"
  output_path = "${path.module}/lambda-packages/chatbot.zip"
}

# Chatbot Lambda function
module "chatbot_lambda" {
  source = "./modules/lambda"

  resource_prefix = local.resource_prefix
  function_name   = "chatbot"
  description     = "Bedrock RAG Chatbot Lambda Function"

  source_path = data.archive_file.chatbot_lambda.output_path

  handler     = "chatbot.lambda_handler"
  runtime     = "python3.11"
  timeout     = 30
  memory_size = 256

  environment_variables = {
    BEDROCK_KB_ID     = module.bedrock.default_kb_identifier
    BEDROCK_MODEL_ARN = var.bedrock_model_arn
  }

  # Deploy Lambda in the private subnets with access to NAT Gateway
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [aws_security_group.lambda_sg.id]

  layers = [
    local.lambda_layer_power_tools
  ]

  # Add permissions to invoke Bedrock
  additional_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "bedrock:InvokeModel",
        "bedrock:Retrieve",
        "bedrock:RetrieveAndGenerate",
        "bedrock:GetInferenceProfile",
        "bedrock-agent-runtime:RetrieveAndGenerate"
      ]
      Resource = [
        "*"
      ]
    }
  ]
}

# Security group for Lambda function
resource "aws_security_group" "lambda_sg" {

  name        = "${local.resource_prefix}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = module.networking.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = { Name = "${local.resource_prefix}-lambda-sg" }
}
