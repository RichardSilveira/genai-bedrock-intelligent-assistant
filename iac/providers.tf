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

    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.2.0"
    }

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

provider "opensearch" {
  url         = var.kb_storage_type == "OPENSEARCH_SERVERLESS" ? module.bedrock.default_collection.collection_endpoint : "http://localhost:9200"
  healthcheck = false
}
