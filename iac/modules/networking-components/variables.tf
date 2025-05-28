variable "vpc_config" {
  description = "VPC Configuration."
  type = object({
    name                          = string
    cidr_block                    = string
    public_subnet_1_cidr          = string
    public_subnet_1_az            = string
    public_subnet_2_cidr          = string
    public_subnet_2_az            = string
    public_subnet_3_cidr          = optional(string)
    public_subnet_3_az            = optional(string)
    private_subnet_1_cidr         = string
    private_subnet_1_az           = string
    private_subnet_2_cidr         = string
    private_subnet_2_az           = string
    private_subnet_3_cidr         = optional(string)
    private_subnet_3_az           = optional(string)
    create_second_nat             = optional(bool, true)
    vpc_enable_dns_hostnames      = optional(bool, true)
    vpc_flowlog_retention_in_days = optional(number, 30)
  })
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}