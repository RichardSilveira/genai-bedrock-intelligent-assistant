module "networking" {
  source = "./modules/networking-components"

  vpc_config = {
    name                  = "${local.resource_prefix}-vpc"
    cidr_block            = "10.0.0.0/16"
    public_subnet_1_cidr  = "10.0.1.0/24"
    public_subnet_1_az    = "us-east-2a"
    public_subnet_2_cidr  = "10.0.2.0/24"
    public_subnet_2_az    = "us-east-2b"
    public_subnet_3_cidr  = "10.0.3.0/24"
    public_subnet_3_az    = "us-east-2c"
    private_subnet_1_cidr = "10.0.11.0/24"
    private_subnet_1_az   = "us-east-2a"
    private_subnet_2_cidr = "10.0.12.0/24"
    private_subnet_2_az   = "us-east-2b"
    private_subnet_3_cidr = "10.0.13.0/24"
    private_subnet_3_az   = "us-east-2c"
    create_second_nat     = false # it must be true for production envs

    vpc_enable_dns_hostnames = true
  }
}
