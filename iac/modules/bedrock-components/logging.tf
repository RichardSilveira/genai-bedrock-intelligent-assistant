# # --------------------------------------------------
# # Bedrock Model invocation logging (cloudwatch)
# # --------------------------------------------------

# # 💰 This is not tied-coupled with the Knowledge Base and it can increase costs in production envs significantly
# resource "aws_cloudwatch_log_group" "bedrock_model_invocation" {
#   count             = var.enable_model_invocation_logging ? 1 : 0
#   name              = "/aws/bedrock/${var.resource_prefix}-model-invocation"
#   retention_in_days = 30

#   tags = merge(local.combined_tags, {
#     Name = "${var.resource_prefix}-bedrock-model-invocation-logs"
#   })
# }

# resource "aws_iam_role" "bedrock_model_invocation" {
#   count = var.enable_model_invocation_logging ? 1 : 0
#   name  = "${var.resource_prefix}-bedrock-logging-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "bedrock.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = merge(local.combined_tags, {
#     Name = "${var.resource_prefix}-bedrock-logging-role"
#   })
# }

# resource "aws_iam_role_policy" "bedrock_model_invocation" {
#   count = var.enable_model_invocation_logging ? 1 : 0
#   name  = "${var.resource_prefix}-bedrock-logging-policy"
#   role  = aws_iam_role.bedrock_model_invocation[0].id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = [
#           "${aws_cloudwatch_log_group.bedrock_model_invocation[0].arn}:*",
#         ]
#       }
#     ]
#   })
# }

# resource "aws_bedrock_model_invocation_logging_configuration" "bedrock_model_invocation" {
#   count = var.enable_model_invocation_logging ? 1 : 0
#   logging_config {
#     cloudwatch_config {
#       log_group_name = aws_cloudwatch_log_group.bedrock_model_invocation[0].name
#       role_arn       = aws_iam_role.bedrock_model_invocation[0].arn
#     }
#     text_data_delivery_enabled      = true
#     embedding_data_delivery_enabled = false
#     image_data_delivery_enabled     = false
#     video_data_delivery_enabled     = false
#   }
# }


# # --------------------------------------------------
# # Bedrock Knowledge Base Logging with CloudWatch
# # --------------------------------------------------

# # resource "aws_cloudwatch_log_group" "bedrock_kb_logs" {
# #   name              = "/aws/bedrock/knowledge-bases/${var.resource_prefix}-kb"
# #   retention_in_days = 30

# #   tags = merge(local.combined_tags, {
# #     Name = "${var.resource_prefix}-bedrock-kb-logs"
# #   })
# # }

# # Note: Knowledge Base logging must be enabled through the AWS Console:
# # 1. Go to the AWS Bedrock console
# # 2. Navigate to Knowledge bases
# # 3. Select your knowledge base
# # 4. Go to the "Logging" tab
# # 5. Enable logging and select this log group and IAM role

