output "kb_documents_bucket_name" {
  description = "Name of the S3 bucket storing knowledge base documents"
  value       = aws_s3_bucket.kb_documents.id
}

output "kb_collection_id" {
  description = "ID of the OpenSearch Serverless collection for knowledge base"
  value       = aws_opensearchserverless_collection.this.id
}

output "bedrock_role_arn" {
  description = "ARN of the IAM role for Bedrock"
  value       = aws_iam_role.bedrock.arn
}