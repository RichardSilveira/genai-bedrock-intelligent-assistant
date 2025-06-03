# --------------------------------------------------
# Lambda Function
# --------------------------------------------------
resource "aws_lambda_function" "this" {
  function_name = "${var.resource_prefix}-${var.function_name}"
  description   = var.description
  role          = aws_iam_role.lambda_execution_role.arn

  filename         = var.source_path
  handler          = var.handler
  source_code_hash = filebase64sha256(var.source_path)

  runtime       = var.runtime
  architectures = var.architectures
  timeout       = var.timeout
  memory_size   = var.memory_size

  environment {
    variables = var.environment_variables
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  ephemeral_storage {
    size = var.ephemeral_storage_size_mb
  }

  layers = var.layers

  /* Recommended: Place a queue in front of the Lambda when it's invoked async for better concurrency control, retry, and to avoid resource exhaustion.
  Use `dead_letter_config` in flavor of simplicity (when you don't want to add an "extra" queue between the source and the Lambda). */
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  reserved_concurrent_executions = var.reserved_concurrent_executions

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${var.function_name}"
  })
}

# --------------------------------------------------
# CloudWatch
# --------------------------------------------------

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.resource_prefix}-${var.function_name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${var.function_name}-logs"
  })
}

# --------------------------------------------------
# IAM Permission
# --------------------------------------------------

resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.resource_prefix}-${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${var.function_name}-role"
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${var.resource_prefix}-${var.function_name}-policy"
  description = "Policy for ${var.function_name} Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/lambda/${var.resource_prefix}-${var.function_name}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = ["*"]
      }
    ], var.additional_policy_statements)
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
