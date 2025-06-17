variable "resource_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "source_path" {
  description = "Path to the Lambda deployment package (zip file)."
  type        = string
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
}

variable "runtime" {
  description = "Lambda function runtime"
  type        = string
  default     = "python3.11"
}

variable "architectures" {
  description = "Instruction set architecture for the Lambda function"
  type        = list(string)
  default     = ["x86_64"]
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Lambda function VPC configuration"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for the Lambda function VPC configuration"
  type        = list(string)
  default     = []
}

variable "log_retention_in_days" {
  description = "Number of days to retain Lambda function logs"
  type        = number
  default     = 14
}

variable "additional_policy_statements" {
  description = "Additional IAM policy statements to attach to the Lambda execution role"
  type        = list(any)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "ephemeral_storage_size_mb" {
  description = "Ephemeral storage size in MB for the Lambda function (/tmp). Minimum 512, maximum 10240. Default is 512."
  type        = number
  default     = 512

  validation {
    condition     = var.ephemeral_storage_size_mb >= 512 && var.ephemeral_storage_size_mb <= 10240
    error_message = "ephemeral_storage_size_mb must be between 512 and 10240."
  }
}

variable "dead_letter_target_arn" {
  description = "ARN of the SQS queue or SNS topic for Lambda dead letter queue (DLQ). Recommended: Place a queue (e.g., SQS) in front of the Lambda for better concurrency control, retry, and to avoid resource exhaustion. Leave null to disable."
  type        = string
  default     = null
}

variable "reserved_concurrent_executions" {
  description = "The number of simultaneous executions to reserve for the Lambda function. Set to null for unreserved concurrency."
  type        = number
  default     = null
}

variable "provisioned_concurrent_executions" {
  description = "The amount of provisioned concurrency to allocate for the function. Only applies to published versions and aliases."
  type        = number
  default     = null
}

variable "enable_autoscaling" {
  description = "Whether to enable auto scaling for provisioned concurrency"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum capacity for auto scaling of provisioned concurrency"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum capacity for auto scaling of provisioned concurrency"
  type        = number
  default     = 10
}

variable "autoscaling_target_utilization" {
  description = "Target utilization percentage for auto scaling of provisioned concurrency (10-90). This is a percentage value that will be converted to a decimal (0.1-0.9) for the AWS API."
  type        = number
  default     = 70

  validation {
    condition     = var.autoscaling_target_utilization >= 10 && var.autoscaling_target_utilization <= 90
    error_message = "Target utilization must be between 10 and 90 percent."
  }
}

variable "layers" {
  description = "List of Lambda Layer ARNs to attach to the function."
  type        = list(string)
  default     = []
}
