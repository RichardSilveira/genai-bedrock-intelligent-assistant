output "config_bucket_arn" {
  description = "ARN of the S3 bucket used for AWS Config logs"
  value       = var.create_aws_config ? module.config_bucket[0].bucket_arn : null
}

output "config_sns_topic_arn" {
  description = "ARN of the SNS topic used for AWS Config notifications"
  value       = var.create_aws_config ? aws_sns_topic.config_alerts[0].arn : null
}

output "config_role_arn" {
  description = "ARN of the IAM role used by AWS Config"
  value       = var.create_aws_config ? aws_iam_role.config_role[0].arn : null
}