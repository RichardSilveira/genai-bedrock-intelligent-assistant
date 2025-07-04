data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "agent_trust" {
  count = var.create_agent || var.create_supervisor ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [local.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "agent_permissions" {
  count = var.create_agent || var.create_supervisor ? 1 : 0
  statement {
    actions = [
      "bedrock:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "agent_alias_permissions" {
  count = var.create_agent_alias || var.create_supervisor ? 1 : 0
  statement {
    actions = [
      "bedrock:*"
    ]
    resources = [
      "*"
    ]
  }
}


data "aws_iam_policy_document" "knowledge_base_permissions" {
  count = local.create_kb ? 1 : 0

  statement {
    actions   = ["bedrock:Retrieve"]
    resources = ["arn:${local.partition}:bedrock:${local.region}:${local.account_id}:knowledge-base/*"]
  }
}
