variable "resource_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "name" {
  description = "Name of the S3 bucket (will be combined with prefix)"
  type        = string
}

variable "newer_noncurrent_versions" {
  description = "Number of newer versions to keep before deleting noncurrent versions"
  type        = number
  default     = 3
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "lifecycle_mode" {
  description = "Lifecycle configuration mode: 'standard' (project best practices) or 'cost_optimized' (aggressive cost savings)"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "cost_optimized"], var.lifecycle_mode)
    error_message = "Allowed values for lifecycle_mode are 'standard' or 'cost_optimized'."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
