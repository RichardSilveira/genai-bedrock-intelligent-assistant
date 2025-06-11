
locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  resource_prefix = "${var.project}-${var.environment}"

  # required as other providers besides `aws` are used
  default_tags = {
    Owner            = var.owner
    CostCenter       = var.cost_center
    Project          = var.project
    Environment      = var.environment
    "user:CreatedBy" = var.created_by
  }

  # required as other providers besides `aws` are used
  default_tags_list = [
    {
      key   = "Owner"
      value = var.owner
    },
    {
      key   = "CostCenter"
      value = var.cost_center
    },
    {
      key   = "Project"
      value = var.project
    },
    {
      key   = "Environment"
      value = var.environment
    },
    {
      key   = "user:CreatedBy"
      value = var.created_by
    },
  ]

  lambda_layer_power_tools = "arn:aws:lambda:${local.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-python313-x86_64:16"
}
