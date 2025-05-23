module "bedrock_rag" {
  source = "./modules/bedrock-rag"

  name = "${local.resource_prefix}-rag"
  tags = {
    Owner            = var.owner
    CostCenter       = var.cost_center
    Project          = var.project
    Environment      = var.environment
    "user:CreatedBy" = var.created_by
  }
}

module "bedrock_rag" {
  source = "./modules/bedrock-rag"

  name = "${local.resource_prefix}-rag"
  tags = {
    Owner            = var.owner
    CostCenter       = var.cost_center
    Project          = var.project
    Environment      = var.environment
    "user:CreatedBy" = var.created_by
  }
}