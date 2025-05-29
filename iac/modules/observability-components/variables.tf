variable "resource_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "create_aws_config" {
  description = "Whether to create AWS Config resources"
  type        = bool
  default     = false
}

variable "enable_bedrock_model_invocation_logging" {
  description = "Whether to enable Bedrock model invocation logging"
  type        = bool
  default     = false
}

variable "create_vpc_flow_logs" {
  description = "Whether to create VPC Flow Logs"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC to enable flow logs for (required if create_vpc_flow_logs is true)"
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "Name of the VPC (used for naming flow log resources)"
  type        = string
  default     = null
}

variable "vpc_flowlog_retention_in_days" {
  description = "Number of days to retain VPC flow logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}