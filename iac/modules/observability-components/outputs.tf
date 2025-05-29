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

output "bedrock_logging_role_arn" {
  description = "ARN of the IAM role used for Bedrock model invocation logging"
  value       = var.enable_bedrock_model_invocation_logging ? aws_iam_role.bedrock_logging[0].arn : null
}

output "bedrock_model_invocation_log_group_name" {
  description = "Name of the CloudWatch log group for Bedrock model invocation logs"
  value       = var.enable_bedrock_model_invocation_logging ? aws_cloudwatch_log_group.bedrock_model_invocation[0].name : null
}

output "vpc_flow_log_group_arn" {
  description = "ARN of the CloudWatch log group for VPC flow logs"
  value       = var.create_vpc_flow_logs ? aws_cloudwatch_log_group.flow_log[0].arn : null
}

output "vpc_flow_log_role_arn" {
  description = "ARN of the IAM role used for VPC flow logs"
  value       = var.create_vpc_flow_logs ? aws_iam_role.vpc_flow_log[0].arn : null
}