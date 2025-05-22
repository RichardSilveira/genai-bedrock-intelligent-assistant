variable "owner" {
  description = "The owner of the resources."
  type        = string
}

variable "cost_center" {
  description = "The cost center associated with the resources."
  type        = string
}

variable "project" {
  description = "The project name for the resources."
  type        = string
}

variable "environment" {
  description = "The environment for the resources (e.g., dev, staging, prod)."
  type        = string
}
