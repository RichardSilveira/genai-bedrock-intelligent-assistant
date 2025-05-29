module "observability" {
  source = "./modules/observability-components"

  resource_prefix                         = local.resource_prefix
  create_aws_config                       = true
  enable_bedrock_model_invocation_logging = true
}
