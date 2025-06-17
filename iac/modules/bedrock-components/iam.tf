resource "aws_iam_role" "agent_role" {
  count                = var.agent_resource_role_arn == null && (var.create_agent || var.create_supervisor) ? 1 : 0
  name                 = "AmazonBedrockExecutionRoleForAgents-${var.resource_prefix}"
  assume_role_policy   = data.aws_iam_policy_document.agent_trust[0].json
  permissions_boundary = var.permissions_boundary_arn
}

resource "aws_iam_role_policy" "agent_policy" {
  count  = var.agent_resource_role_arn == null && (var.create_agent || var.create_supervisor) ? 1 : 0
  policy = data.aws_iam_policy_document.agent_permissions[0].json
  role   = local.agent_role_name
}

resource "aws_iam_role_policy" "agent_alias_policy" {
  count  = var.agent_resource_role_arn == null && (var.create_agent_alias || var.create_supervisor) ? 1 : 0
  policy = data.aws_iam_policy_document.agent_alias_permissions[0].json
  role   = local.agent_role_name
}

# Define the IAM role for Amazon Bedrock Knowledge Base
resource "aws_iam_role" "bedrock_knowledge_base_role" {
  count = var.kb_role_arn != null || (local.create_kb == false && var.create_sql_config == false) ? 0 : 1
  name  = "AmazonBedrockExecutionRoleForKnowledgeBase-${var.resource_prefix}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "bedrock.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  permissions_boundary = var.permissions_boundary_arn
}

# Attach a policy to allow necessary permissions for the Bedrock Knowledge Base
resource "aws_iam_policy" "bedrock_knowledge_base_policy" {
  count = var.kb_role_arn != null || var.create_default_kb == false || var.create_kendra_config == true ? 0 : 1
  name  = "AmazonBedrockKnowledgeBasePolicy-${var.resource_prefix}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : concat(
      var.kb_storage_type == "OPENSEARCH_SERVERLESS" ? [
        {
          "Effect" : "Allow",
          "Action" : [
            "aoss:APIAccessAll"
          ],
          "Resource" : module.oss_knowledgebase[0].opensearch_serverless_collection.arn
        }
      ] : [],
      [
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue"
          ],
          "Resource" : var.credentials_secret_arn
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "bedrock:InvokeModel",
          ],
          "Resource" : var.kb_embedding_model_arn
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "bedrock:ListFoundationModels",
            "bedrock:ListCustomModels"
          ],
          "Resource" : "*"
        },
    ])
  })
}

resource "aws_iam_policy" "bedrock_knowledge_base_policy_s3" {
  count = var.kb_role_arn != null || local.create_kb == false || var.create_s3_data_source == false ? 0 : 1
  name  = "AmazonBedrockKnowledgeBasePolicyS3DataSource-${var.resource_prefix}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
        ],
        "Resource" : var.kb_s3_data_source == null ? module.kb_data_source_bucket[0].bucket_arn : var.kb_s3_data_source
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
        ],
        "Resource" : var.kb_s3_data_source == null ? "${module.kb_data_source_bucket[0].bucket_arn}/*" : "${var.kb_s3_data_source}/*"
      }
    ]
  })
}

resource "aws_iam_policy" "bedrock_kb_s3_decryption_policy" {
  count = local.create_kb_role && var.kb_s3_data_source_kms_arn != null && var.create_s3_data_source ? 1 : 0
  name  = "AmazonBedrockS3KMSPolicyForKnowledgeBase_${var.resource_prefix}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "kms:Decrypt",
        "Resource" : var.kb_s3_data_source_kms_arn
        "Condition" : {
          "StringEquals" : {
            "kms:ViaService" : ["s3.${data.aws_region.current.name}.amazonaws.com"]
          }
        }
      }
    ]
  })
}

# Attach the policies to the role
resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_policy_attachment" {
  count      = var.kb_role_arn != null || local.create_kb == false || var.create_kendra_config == true ? 0 : 1
  role       = aws_iam_role.bedrock_knowledge_base_role[0].name
  policy_arn = aws_iam_policy.bedrock_knowledge_base_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_sql_policy_attachment" {
  count      = var.kb_role_arn != null || var.create_sql_config == false ? 0 : 1
  role       = aws_iam_role.bedrock_knowledge_base_role[0].name
  policy_arn = aws_iam_policy.bedrock_kb_sql[0].arn
}

resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_sql_serverless_policy_attachment" {
  count      = var.kb_role_arn != null || var.create_sql_config == false || var.redshift_query_engine_type != "SERVERLESS" ? 0 : 1
  role       = aws_iam_role.bedrock_knowledge_base_role[0].name
  policy_arn = aws_iam_policy.bedrock_kb_sql_serverless[0].arn
}

resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_sql_provision_policy_attachment" {
  count      = var.kb_role_arn != null || var.create_sql_config == false || var.redshift_query_engine_type != "PROVISIONED" ? 0 : 1
  role       = aws_iam_role.bedrock_knowledge_base_role[0].name
  policy_arn = aws_iam_policy.bedrock_kb_sql_provisioned[0].arn
}

resource "aws_iam_role_policy_attachment" "bedrock_kb_s3_decryption_policy_attachment" {
  count      = local.create_kb_role && var.kb_s3_data_source_kms_arn != null && var.create_s3_data_source ? 1 : 0
  role       = aws_iam_role.bedrock_knowledge_base_role[0].name
  policy_arn = aws_iam_policy.bedrock_kb_s3_decryption_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_policy_s3_attachment" {
  count      = var.kb_role_arn != null || local.create_kb == false || var.create_s3_data_source == false ? 0 : 1
  role       = aws_iam_role.bedrock_knowledge_base_role[0].name
  policy_arn = aws_iam_policy.bedrock_knowledge_base_policy_s3[0].arn
}

resource "aws_iam_role_policy" "bedrock_kb_oss" {
  count = var.kb_role_arn != null || var.create_default_kb == false ? 0 : 1
  name  = "AmazonBedrockOSSPolicyForKnowledgeBase_${var.kb_name}"
  role  = aws_iam_role.bedrock_knowledge_base_role[count.index].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["aoss:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:aoss:${local.region}:${local.account_id}:*/*"]
      }
    ]
  })
}

# Action Group Policies

resource "aws_lambda_permission" "allow_bedrock_agent" {
  count         = var.create_ag ? length(local.action_group_names) : 0
  action        = "lambda:InvokeFunction"
  function_name = local.action_group_names[count.index]
  principal     = "bedrock.amazonaws.com"
  source_arn    = awscc_bedrock_agent.bedrock_agent[0].agent_arn
}

resource "aws_lambda_permission" "allow_bedrock_agent_alias" {
  count         = var.create_ag ? length(local.action_group_names) : 0
  action        = "lambda:InvokeFunction"
  function_name = local.action_group_names[count.index]
  principal     = "bedrock.amazonaws.com"
  source_arn    = "${awscc_bedrock_agent.bedrock_agent[0].agent_arn}/*"
}

resource "aws_iam_role_policy" "action_group_policy" {
  count = var.create_ag ? 1 : 0
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeModel*"]
        Resource = concat([var.lambda_action_group_executor], var.action_group_lambda_arns_list)
      }
    ]
  })
  role = aws_iam_role.agent_role[0].id
}

# Application Inference Profile Policies

# Define the IAM role for Application Inference Profile
resource "aws_iam_role" "application_inference_profile_role" {
  count = var.create_app_inference_profile ? 1 : 0
  name  = "ApplicationInferenceProfile-${var.resource_prefix}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "bedrock.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  permissions_boundary = var.permissions_boundary_arn
}

resource "aws_iam_role_policy" "app_inference_profile_role_policy" {
  count = var.create_app_inference_profile ? 1 : 0
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "bedrock:InvokeModel*",
          "bedrock:CreateInferenceProfile"
        ],
        "Resource" : [
          "arn:aws:bedrock:*::foundation-model/*",
          "arn:aws:bedrock:*:*:inference-profile/*",
          "arn:aws:bedrock:*:*:application-inference-profile/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "bedrock:GetInferenceProfile",
          "bedrock:ListInferenceProfiles",
          "bedrock:DeleteInferenceProfile",
          "bedrock:TagResource",
          "bedrock:UntagResource",
          "bedrock:ListTagsForResource"
        ],
        "Resource" : [
          "arn:aws:bedrock:*:*:inference-profile/*",
          "arn:aws:bedrock:*:*:application-inference-profile/*"
        ]
      }
    ]
  })
  role = aws_iam_role.application_inference_profile_role[0].id
}

# Create IAM role for Kendra Data Source
# resource "awscc_iam_role" "kendra_s3_datasource_role" {
#   count = var.create_kendra_s3_data_source ? 1 : 0
#   assume_role_policy_document = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "kendra.amazonaws.com"
#         }
#       }
#     ]
#   })
#   description = "IAM role for Kendra Data Source"
#   path        = "/"
#   role_name   = "kendra-datasource-role"

#   policies = [
#     {
#       policy_name = "kendra-datasource-policy"
#       policy_document = jsonencode({
#         Version = "2012-10-17"
#         Statement = [
#           {
#             Effect = "Allow"
#             Action = [
#               "s3:GetObject",
#               "s3:ListBucket"
#             ]
#             Resource = [
#               local.kendra_data_source_bucket_arn,
#               "${local.kendra_data_source_bucket_arn}/*"
#             ]
#           },
#           {
#             Effect : "Allow",
#             Action : [
#               "kendra:BatchPutDocument",
#               "kendra:BatchDeleteDocument"
#             ],
#             Resource : "arn:aws:kendra:${local.region}:${local.account_id}:index/${local.kendra_index_id}"
#           }
#         ]
#       })
#     }
#   ]
# }

# SQL Knowledge Base IAM
resource "aws_iam_policy" "bedrock_kb_sql" {
  count = var.kb_role_arn != null || var.create_sql_config == false ? 0 : 1
  name  = "AmazonBedrockKnowledgeBaseRedshiftStatement_${var.kb_name}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "RedshiftDataAPIStatementPermissions",
        "Effect" : "Allow",
        "Action" : [
          "redshift-data:GetStatementResult",
          "redshift-data:DescribeStatement",
          "redshift-data:CancelStatement"
        ],
        "Resource" : [
          "*"
        ],
        "Condition" : {
          "StringEquals" : {
            "redshift-data:statement-owner-iam-userid" : "$${aws:userid}"
          }
        }
      },
      {
        "Sid" : "SqlWorkbenchAccess",
        "Effect" : "Allow",
        "Action" : [
          "sqlworkbench:GetSqlRecommendations",
          "sqlworkbench:PutSqlGenerationContext",
          "sqlworkbench:GetSqlGenerationContext",
          "sqlworkbench:DeleteSqlGenerationContext"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "KbAccess",
        "Effect" : "Allow",
        "Action" : [
          "bedrock:GenerateQuery"
        ],
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_iam_policy" "bedrock_kb_sql_serverless" {
  count = var.kb_role_arn != null || var.create_sql_config == false || var.redshift_query_engine_type != "SERVERLESS" ? 0 : 1
  name  = "AmazonBedrockKnowledgeBaseRedshiftServerlessStatement_${var.kb_name}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [

      {
        "Sid" : "RedshiftDataAPIExecutePermissions",
        "Effect" : "Allow",
        "Action" : [
          "redshift-data:ExecuteStatement"
        ],
        "Resource" : [
          "arn:aws:redshift-serverless:${local.region}:${local.account_id}:workgroup:${split("/", var.sql_kb_workgroup_arn)[1]}"
        ]
      },
      {
        "Sid" : "RedshiftServerlessGetCredentials",
        "Effect" : "Allow",
        "Action" : "redshift-serverless:GetCredentials",
        "Resource" : [
          "arn:aws:redshift-serverless:${local.region}:${local.account_id}:workgroup:${split("/", var.sql_kb_workgroup_arn)[1]}"
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "bedrock_kb_sql_provisioned" {
  count = var.kb_role_arn != null || var.create_sql_config == false || var.redshift_query_engine_type != "PROVISIONED" ? 0 : 1
  name  = "AmazonBedrockKnowledgeBaseRedshiftProvisionedStatement_${var.kb_name}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "RedshiftDataAPIExecutePermissions",
        "Effect" : "Allow",
        "Action" : [
          "redshift-data:ExecuteStatement"
        ],
        "Resource" : [
          "arn:aws:redshift:${local.region}:${local.account_id}:cluster:${var.provisioned_config_cluster_identifier}"
        ]
      },
      {
        "Sid" : "GetCredentialsWithFederatedIAMCredentials",
        "Effect" : "Allow",
        "Action" : "redshift:GetClusterCredentialsWithIAM",
        "Resource" : [
          "arn:aws:redshift:${local.region}:${local.account_id}:dbname:${var.provisioned_config_cluster_identifier}/*"
        ]
      }
    ]
  })
}
