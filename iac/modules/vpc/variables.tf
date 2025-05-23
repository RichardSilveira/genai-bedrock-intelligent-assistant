variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "name" {
  description = "The name tag for the VPC."
  type        = string
}

variable "vpc_enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "vpc_flowlog_retention_in_days" {
  description = "Number of days to retain CloudWatch logs for VPC flow logs."
  type        = number
  default     = 30
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet (e.g., 10.0.1.0/24)."
  type        = string
}

variable "public_subnet_1_az" {
  description = "Availability zone for the first public subnet (e.g., us-east-1a)."
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet (e.g., 10.0.2.0/24)."
  type        = string
}

variable "public_subnet_2_az" {
  description = "Availability zone for the second public subnet (e.g., us-east-1b)."
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the first private subnet (e.g., 10.0.11.0/24)."
  type        = string
}

variable "private_subnet_1_az" {
  description = "Availability zone for the first private subnet (e.g., us-east-1a)."
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the second private subnet (e.g., 10.0.12.0/24)."
  type        = string
}

variable "private_subnet_2_az" {
  description = "Availability zone for the second private subnet (e.g., us-east-1b)."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
