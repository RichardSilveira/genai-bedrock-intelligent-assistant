module "vpc" {
  source = "../vpc"

  name                          = var.vpc_config.name
  cidr_block                    = var.vpc_config.cidr_block
  public_subnet_1_cidr          = var.vpc_config.public_subnet_1_cidr
  public_subnet_1_az            = var.vpc_config.public_subnet_1_az
  public_subnet_2_cidr          = var.vpc_config.public_subnet_2_cidr
  public_subnet_2_az            = var.vpc_config.public_subnet_2_az
  private_subnet_1_cidr         = var.vpc_config.private_subnet_1_cidr
  private_subnet_1_az           = var.vpc_config.private_subnet_1_az
  private_subnet_2_cidr         = var.vpc_config.private_subnet_2_cidr
  private_subnet_2_az           = var.vpc_config.private_subnet_2_az
  vpc_enable_dns_hostnames      = var.vpc_config.vpc_enable_dns_hostnames
  vpc_flowlog_retention_in_days = var.vpc_config.vpc_flowlog_retention_in_days
  tags                          = local.combined_tags
}
