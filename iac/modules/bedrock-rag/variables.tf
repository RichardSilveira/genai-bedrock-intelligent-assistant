variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ci_principal_arn" {
  description = "ARNs of the CI/CD principal (users or role) that need to create the OpenSearch index"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
