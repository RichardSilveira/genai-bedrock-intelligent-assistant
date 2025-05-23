output "kb_documents_bucket_arn" {
  description = "Name of the S3 bucket storing knowledge base documents"
  value       = aws_s3_bucket.kb_documents.arn
}

output "kb_opensearch_collection_arn" {
  description = "ID of the OpenSearch Serverless collection for knowledge base"
  value       = aws_opensearchserverless_collection.this.arn
}

output "bedrock_role_arn" {
  description = "ARN of the IAM role for Bedrock"
  value       = aws_iam_role.bedrock.arn
}
