variable "resource_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "create_aws_config" {
  description = "Whether to create AWS Config resources"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
