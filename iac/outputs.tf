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

# Bedrock RAG outputs
output "rag_s3_bucket_name" {
  description = "Name of the S3 bucket storing RAG documents"
  value       = module.bedrock_rag.s3_bucket_name
}

output "rag_opensearch_collection_id" {
  description = "ID of the OpenSearch Serverless collection for RAG"
  value       = module.bedrock_rag.opensearch_collection_id
}

output "rag_bedrock_role_arn" {
  description = "ARN of the IAM role for Bedrock RAG"
  value       = module.bedrock_rag.bedrock_role_arn
}
# Bedrock RAG outputs
output "rag_s3_bucket_name" {
  description = "Name of the S3 bucket storing RAG documents"
  value       = module.bedrock_rag.s3_bucket_name
}

output "rag_opensearch_collection_id" {
  description = "ID of the OpenSearch Serverless collection for RAG"
  value       = module.bedrock_rag.opensearch_collection_id
}

output "rag_bedrock_role_arn" {
  description = "ARN of the IAM role for Bedrock RAG"
  value       = module.bedrock_rag.bedrock_role_arn
}