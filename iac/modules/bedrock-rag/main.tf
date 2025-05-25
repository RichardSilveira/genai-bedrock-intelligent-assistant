data "aws_region" "current" {}

locals {
  aoss_collection_name = "${var.prefix}-kb-collection"
  vector_index_name    = "bedrock-kb-index"
  embedding_model_arn  = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
}

# --------------------------------------------------
# S3 Bucket for Knowledge Base Documents
# --------------------------------------------------

resource "aws_s3_bucket" "kb_documents" {
  bucket = "${var.prefix}-kb-documents"

  tags = merge(local.combined_tags, {
    Name = "${var.prefix}-kb-documents"
  })

  # checkov:skip=CKV2_AWS_62: "Event notifications - TBD"
  # checkov:skip=CKV_AWS_18: "Access logging - TBD
  # checkov:skip=CKV_AWS_145: "KMS encryption - a must have for compliance and auditing, but not mandatory for security concerns"
  # checkov:skip=CKV_AWS_144: "Cross-region Replication - a must have for fault-tolerant applications"
}

resource "aws_s3_bucket_lifecycle_configuration" "kb_documents" {
  bucket = aws_s3_bucket.kb_documents.id

  # 💰 once a object is synced to kb underlying vector store, it won't be frequently accessed anymore
  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  # 💰 To not to pay for unused resource usage
  rule {
    id     = "abort-incomplete-multipart-upload"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_public_access_block" "kb_documents" {
  bucket = aws_s3_bucket.kb_documents.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "kb_documents" {
  bucket = aws_s3_bucket.kb_documents.id
  versioning_configuration {
    status = "Enabled"
  }
  # todo: transition stale object versions to OneZone-IA storage class
}

# --------------------------------------------------
# OpenSearch Serverless Collection
# --------------------------------------------------

# Security - Encryption policies
resource "aws_opensearchserverless_security_policy" "encryption" {
  name = "${var.prefix}-kb-encryption"
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        ResourceType = "collection"
        Resource     = ["collection/${local.aoss_collection_name}"]
      }
    ],
    AWSOwnedKey = true
  })
}

# Security - Network policies
resource "aws_opensearchserverless_security_policy" "network" {
  name = "${var.prefix}-kb-network"
  type = "network"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection",
          Resource     = ["collection/${local.aoss_collection_name}"]
        }
      ],
      AllowFromPublic = true
    }
  ])
  # todo: use vpc endpoint (AWS private network backbone via Private Link to reduce latency and improve security)
}

# Security - Data Access policies
resource "aws_opensearchserverless_access_policy" "data_access" {
  name = "${var.prefix}-kb-access-policy"
  type = "data"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection",
          Resource     = ["collection/${local.aoss_collection_name}"],
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
        },
        {
          ResourceType = "index",
          Resource     = ["index/${local.aoss_collection_name}/*"],
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
        }
      ],
      Principal = [var.ci_principal_arn, aws_iam_role.bedrock.arn]
    }
  ])

  # 📝  both bedrock service iam role and ci/cd iam user or role must be able to manage opensearch indexes
  #     e.g., create index via terraform and updating them via data pipelines
}

resource "aws_opensearchserverless_collection" "this" {
  name = local.aoss_collection_name
  type = "VECTORSEARCH"

  tags = merge(local.combined_tags, {
    Name = "${var.prefix}-kb-collection"
  })

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network,
    aws_opensearchserverless_access_policy.data_access
  ]
}
resource "null_resource" "create_opensearch_index" {

  # 👉 awscurl must be installed in the ci

  provisioner "local-exec" {
    command = <<EOF
    set -euo pipefail

    LOG_FILE="/tmp/opensearch_index_creation.log"

    echo "🕵 aws identity: $(aws sts get-caller-identity)"

    # Wait for collection to be active
    aws opensearchserverless batch-get-collection --names ${local.aoss_collection_name} --query "collectionDetails[0].status" --region=${data.aws_region.current.name} --output text | grep -q "ACTIVE" || sleep 60

    ENDPOINT=$(aws opensearchserverless batch-get-collection --names ${local.aoss_collection_name} --query "collectionDetails[0].collectionEndpoint" --region=${data.aws_region.current.name} --output text)

    echo "🕵 ENDPOINT: $ENDPOINT"

    # Run awscurl and capture output and exit code
    set -x
    awscurl --service aoss \
      --region ${data.aws_region.current.name} \
      --access_key $AWS_ACCESS_KEY_ID \
      --secret_key $AWS_SECRET_ACCESS_KEY \
      -X PUT "$ENDPOINT/${local.vector_index_name}" \
      -H "Content-Type: application/json" \
      -d @${path.module}/index-mapping.json -v \
      > $LOG_FILE 2>&1 || true
    set +x

    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
      echo "Index creation completed successfully."
    else
      echo "awscurl failed with exit code $EXIT_CODE. See $LOG_FILE for details."
      exit $EXIT_CODE
    fi
EOF
  }

  depends_on = [aws_opensearchserverless_collection.this]
}

# --------------------------------------------------
# Bedrock Knowledge Base
# --------------------------------------------------

# 🎗️ Some settings such as embeddings model dimension must be the same as defined in the vector store data source (see `index-mapping.json`)
resource "aws_bedrockagent_knowledge_base" "this" {
  name        = "${var.prefix}-kb"
  description = "Knowledge base for RAG implementation"

  knowledge_base_configuration {
    type = "VECTOR"
    vector_knowledge_base_configuration {
      embedding_model_arn = local.embedding_model_arn

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions          = 512 # 👉 1024 is the most common one. You need to experiment on your own different settings and compare the results
          embedding_data_type = "FLOAT32"
        }
      }
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.this.arn
      vector_index_name = local.vector_index_name
      field_mapping {
        vector_field   = "vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }

  role_arn = aws_iam_role.bedrock.arn

  tags = merge(local.combined_tags, {
    Name = "${var.prefix}-kb"
  })

  depends_on = [null_resource.create_opensearch_index]
}

resource "aws_iam_role" "bedrock" {
  name = "${var.prefix}-kb-bedrock-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.combined_tags, {
    Name = "${var.prefix}-kb-bedrock-role"
  })
}

resource "aws_iam_role_policy" "bedrock" {
  name = "${var.prefix}-kb-bedrock-policy"
  role = aws_iam_role.bedrock.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.kb_documents.arn,
          "${aws_s3_bucket.kb_documents.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll"
        ]
        Resource = [aws_opensearchserverless_collection.this.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:*" # not ideal
        ]
        Resource = ["*"] # not ideal at all
      }
    ]
  })
}
