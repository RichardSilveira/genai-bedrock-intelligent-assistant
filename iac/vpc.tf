module "networking" {
  source = "./modules/networking-components"

  vpc_config = {
    name                     = "${local.resource_prefix}-vpc"
    cidr_block               = "10.0.0.0/16"
    public_subnet_1_cidr     = "10.0.1.0/24"
    public_subnet_1_az       = "us-east-1a"
    public_subnet_2_cidr     = "10.0.2.0/24"
    public_subnet_2_az       = "us-east-1b"
    private_subnet_1_cidr    = "10.0.11.0/24"
    private_subnet_1_az      = "us-east-1a"
    private_subnet_2_cidr    = "10.0.12.0/24"
    private_subnet_2_az      = "us-east-1b"
    vpc_enable_dns_hostnames = true
  }
}
