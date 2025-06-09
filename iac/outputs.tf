# --------------------------------------------------
# VPC outputs
# --------------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "The IDs of the NAT Gateways"
  value       = module.networking.nat_gateway_ids
}

# --------------------------------------------------
# Observability outputs
# --------------------------------------------------
# output "config_bucket_id" {
#   description = "The ID of the S3 bucket storing AWS Config data"
#   value       = module.observability.config_bucket_id
# }

# output "config_sns_topic_arn" {
#   description = "The ARN of the SNS topic for AWS Config alerts"
#   value       = module.observability.config_sns_topic_arn
# }

output "bedrock_model_invocation_log_group_name" {
  description = "Name of the CloudWatch log group for Bedrock model invocation logs"
  value       = module.observability.bedrock_model_invocation_log_group_name
}

output "bedrock_logging_role_arn" {
  description = "ARN of the IAM role used for Bedrock model invocation logging"
  value       = module.observability.bedrock_logging_role_arn
}

# --------------------------------------------------
# Bedrock RAG outputs
# --------------------------------------------------
# output "rag_s3_documents_bucket_arn" {
#   description = "Name of the S3 bucket storing RAG documents"
#   value       = module.bedrock_rag.kb_documents_bucket_arn
# }

# output "rag_opensearch_collection_arn" {
#   description = "ID of the OpenSearch Serverless collection for RAG"
#   value       = module.bedrock_rag.kb_opensearch_collection_arn
# }

# output "rag_bedrock_role_arn" {
#   description = "ARN of the IAM role for Bedrock RAG"
#   value       = module.bedrock_rag.bedrock_role_arn
# }

# output "rag_knowledge_base_id" {
#   description = "ID of the Bedrock Knowledge Base"
#   value       = module.bedrock_rag.knowledge_base_id
# }

output "bedrock_knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base"
  value       = module.bedrock.default_kb_identifier
}

output "bedrock_knowledge_base_role_name" {
  description = "Name of the IAM role used by the Bedrock Knowledge Base"
  value       = module.bedrock.knowledge_base_role_name
}

output "bedrock_s3_data_source_name" {
  description = "Name of the S3 bucket storing RAG documents"
  value       = module.bedrock.s3_data_source_name
}

output "bedrock_s3_data_source_arn" {
  description = "ARN of the S3 bucket storing RAG documents"
  value       = module.bedrock.s3_data_source_arn
}

output "bedrock_data_source_id" {
  description = "ID of the Bedrock data source"
  value       = module.bedrock.datasource_identifier
}

# --------------------------------------------------
# Lambda outputs
# --------------------------------------------------
output "chatbot_lambda_arn" {
  description = "ARN of the Chatbot Lambda function"
  value       = module.chatbot_lambda.function_arn
}

output "chatbot_lambda_function_name" {
  description = "Name of the Chatbot Lambda function"
  value       = module.chatbot_lambda.function_name
}

# --------------------------------------------------
# API Gateway outputs
# --------------------------------------------------
output "api_endpoint" {
  description = "API Gateway endpoint URL for the default stage"
  value       = aws_apigatewayv2_api.chatbot_api.api_endpoint
}

output "api_execution_arn" {
  description = "API Gateway execution ARN"
  value       = aws_apigatewayv2_api.chatbot_api.execution_arn
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_apigatewayv2_api.chatbot_api.id
}

output "api_key" {
  description = "API Key for accessing the Chatbot API (sensitive)"
  value       = random_password.api_key.result
  sensitive   = true
}

# --------------------------------------------------
# CloudFront outputs
# --------------------------------------------------
output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.api_distribution.id
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.api_distribution.domain_name
}
