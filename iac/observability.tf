module "observability" {
  source = "./modules/observability-components"

  resource_prefix                         = local.resource_prefix
  create_aws_config                       = false
  enable_bedrock_model_invocation_logging = true

  # VPC Flow Logs configuration
  create_vpc_flow_logs = false
  vpc_id               = module.networking.vpc_id
  vpc_name             = module.networking.vpc_name

  tags = {
    Component = "Observability"
  }
}
