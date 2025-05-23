# --------------------------------------------------
# S3 Bucket for Knowledge Base Documents
# --------------------------------------------------

resource "aws_s3_bucket" "kb_documents" {
  bucket = "${var.prefix}-kb-documents"

  tags = merge(local.combined_tags, {
    Name = "${var.prefix}-kb-documents"
  })

  # checkov:skip=CKV2_AWS_62: "Event notifications are not required for this use case"
  # checkov:skip=CKV_AWS_18: "Access logging is a nice-to-have improvement for production"
  # checkov:skip=CKV_AWS_145: "KMS encryption is a nice-to-have improvement for production"
  # checkov:skip=CKV_AWS_144: "Cross-region replication is a nice-to-have improvement for production"
}

resource "aws_s3_bucket_lifecycle_configuration" "kb_documents" {
  bucket = aws_s3_bucket.kb_documents.id

  rule {
    id     = "transition-to-standard-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

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
}

# --------------------------------------------------
# OpenSearch Serverless Collection and Policies
# --------------------------------------------------

resource "aws_opensearchserverless_collection" "this" {
  name = "${var.prefix}-kb-collection"
  type = "VECTORSEARCH"

  tags = merge(local.combined_tags, {
    Name = "${var.prefix}-kb-collection"
  })
}

resource "aws_opensearchserverless_security_policy" "this" {
  name = "${var.prefix}-kb-security-policy"
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/${aws_opensearchserverless_collection.this.name}"],
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_access_policy" "this" {
  name = "${var.prefix}-kb-access-policy"
  type = "data"
  policy = jsonencode({
    Rules = [
      {
        ResourceType = "collection",
        Resource     = ["collection/${aws_opensearchserverless_collection.this.name}"],
        Permission = [
          "aoss:CreateCollectionItems",
          "aoss:DeleteCollectionItems",
          "aoss:UpdateCollectionItems",
          "aoss:DescribeCollectionItems"
        ]
      }
    ],
    Principal = [aws_iam_role.bedrock.arn]
  })
}

# --------------------------------------------------
# IAM Role and Policy for Bedrock
# --------------------------------------------------

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
      }
    ]
  })
}
