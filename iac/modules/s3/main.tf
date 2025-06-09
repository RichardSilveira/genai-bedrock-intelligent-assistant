resource "aws_s3_bucket" "this" {
  bucket = "${var.resource_prefix}-${var.name}"

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${var.name}"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enforced_encryption" {
  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# Optional bucket versioning - enabled by default
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Standard lifecycle configuration based on project best practices
resource "aws_s3_bucket_lifecycle_configuration" "standard_lifecycle" {
  count  = var.lifecycle_mode == "standard" ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "standard-lifecycle-rule"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days           = 30
      newer_noncurrent_versions = var.newer_noncurrent_versions
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Cost-optimized lifecycle configuration with more aggressive transitions and expirations
resource "aws_s3_bucket_lifecycle_configuration" "cost_optimized_lifecycle" {
  count  = var.lifecycle_mode == "cost_optimized" ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "cost-optimized-lifecycle-rule"
    status = "Enabled"

    # More aggressive expiration for non-current versions
    noncurrent_version_expiration {
      noncurrent_days           = 7
      newer_noncurrent_versions = 1 # Keep only the most recent version
    }

    # Faster transition to cold storage
    noncurrent_version_transition {
      noncurrent_days = 1
      storage_class   = "GLACIER"
    }

    # Faster transition to intelligent tiering
    transition {
      days          = 7
      storage_class = "INTELLIGENT_TIERING"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Optional bucket policy
resource "aws_s3_bucket_policy" "this" {
  count  = var.resource_policy != null ? 1 : 0
  bucket = aws_s3_bucket.this.id
  policy = var.resource_policy
}
