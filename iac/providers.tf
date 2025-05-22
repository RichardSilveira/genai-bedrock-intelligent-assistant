terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Owner            = var.owner
      CostCenter       = var.cost_center
      Project          = var.project
      Environment      = var.environment
      "user:CreatedBy" = data.aws_caller_identity.current.arn
    }
  }
}
