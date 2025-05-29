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

