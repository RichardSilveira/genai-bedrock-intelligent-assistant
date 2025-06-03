variable "owner" {
  description = "The owner of the resources."
  type        = string
}

variable "cost_center" {
  description = "The cost center associated with the resources."
  type        = string
  default     = null
}

variable "project" {
  description = "The project name for the resources."
  type        = string
}

variable "environment" {
  description = "The environment for the resources (e.g., dev, staging, prod)."
  type        = string
}

variable "created_by" {
  description = "The arn of the IAM user or role that create the resources"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = null
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = null
}

variable "kb_storage_type" {
  description = "The storage type of a knowledge base."
  type        = string
  default     = null
}

variable "pinecone_connection_string" {
  description = "The endpoint URL for your index management page."
  type        = string
  default     = null
}

variable "bedrock_model_arn" {
  description = "ARN of the Bedrock model to use for the chatbot Lambda."
  type        = string
}
