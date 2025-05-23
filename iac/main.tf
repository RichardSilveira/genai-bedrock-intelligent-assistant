module "bedrock_rag" {
  source = "./modules/bedrock-rag"

  prefix = local.resource_prefix
}
