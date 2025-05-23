variable "vpc_config" {
  description = "VPC Configuration."
  type = object({
    name                     = string
    cidr_block               = string
    public_subnet_1_cidr     = string
    public_subnet_1_az       = string
    public_subnet_2_cidr     = string
    public_subnet_2_az       = string
    private_subnet_1_cidr    = string
    private_subnet_1_az      = string
    private_subnet_2_cidr    = string
    private_subnet_2_az      = string
    vpc_enable_dns_hostnames = optional(bool, true)
  })
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
