# --------------------------------------------------
# Bedrock Model Invocation Logging with CloudWatch
# --------------------------------------------------

# CloudWatch log group for Bedrock model invocation logs
resource "aws_cloudwatch_log_group" "bedrock_model_invocation" {
  count             = var.enable_bedrock_model_invocation_logging ? 1 : 0
  name              = "/aws/bedrock/${var.resource_prefix}-model-invocation"
  retention_in_days = 30

  tags = merge(local.combined_tags, {
    Name = "${var.resource_prefix}-bedrock-model-invocation-logs"
  })
}

# Configure Bedrock model invocation logging
resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  count = var.enable_bedrock_model_invocation_logging ? 1 : 0

  logging_config {
    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock_model_invocation[0].name
      role_arn       = aws_iam_role.bedrock_logging[0].arn
    }
    embedding_data_delivery_enabled = false
    text_data_delivery_enabled      = true
    image_data_delivery_enabled     = false
    video_data_delivery_enabled     = false
  }

  depends_on = [
    aws_iam_role.bedrock_logging,
    aws_iam_role_policy.bedrock_logging
  ]
}

# IAM role for Bedrock logging
resource "aws_iam_role" "bedrock_logging" {
  count = var.enable_bedrock_model_invocation_logging ? 1 : 0
  name  = "${var.resource_prefix}-bedrock-logging-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.combined_tags, {
    Name = "${var.resource_prefix}-bedrock-logging-role"
  })
}

# IAM policy for Bedrock logging
resource "aws_iam_role_policy" "bedrock_logging" {
  count = var.enable_bedrock_model_invocation_logging ? 1 : 0
  name  = "${var.resource_prefix}-bedrock-logging-policy"
  role  = aws_iam_role.bedrock_logging[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.bedrock_model_invocation[0].arn}:*"
        ]
      }
    ]
  })
}
