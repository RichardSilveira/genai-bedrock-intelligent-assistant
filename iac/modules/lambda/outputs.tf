output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.this.invoke_arn
}

output "function_version" {
  description = "Version of the Lambda function"
  value       = aws_lambda_function.this.version
}

output "function_alias_name" {
  description = "Name of the Lambda alias for provisioned concurrency"
  value       = length(aws_lambda_alias.provisioned) > 0 ? aws_lambda_alias.provisioned[0].name : null
}

output "function_alias_arn" {
  description = "ARN of the Lambda alias for provisioned concurrency"
  value       = length(aws_lambda_alias.provisioned) > 0 ? aws_lambda_alias.provisioned[0].arn : null
}

output "execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "execution_role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.name
}

output "log_group_name" {
  description = "Name of the Lambda CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "log_group_arn" {
  description = "ARN of the Lambda CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}
