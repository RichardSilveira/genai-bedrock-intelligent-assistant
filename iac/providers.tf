terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }

    awscc = {
      source  = "hashicorp/awscc"
      version = "= 1.35.0"
    }

    # opensearch = {
    #   source  = "opensearch-project/opensearch"
    #   version = "2.2.0"
    # }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.6"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Owner            = var.owner
      CostCenter       = var.cost_center
      Project          = var.project
      Environment      = var.environment
      "user:CreatedBy" = var.created_by
    }
  }
}

provider "awscc" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Enable it only when working with knowlede base using opensearch serverless as its data source
# provider "opensearch" {
#   url         = module.bedrock.default_collection.collection_endpoint
#   healthcheck = false
# }
