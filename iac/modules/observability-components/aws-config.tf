# --------------------------------------------------
# AWS Config - Security Monitoring
# --------------------------------------------------
# Notes on AWS Config architecture:
# 1. Configuration Recorder: Defines which resources to monitor (e.g., SecurityGroups)
# 2. Config Rules: Defines compliance checks to run against resources
# 3. These components are decoupled by design:
#    - Rules without recorded resources will show as NOT_APPLICABLE
#    - Recording resources without rules still tracks configuration history
#    - This allows for flexible implementation and cost optimization
# 4. The Delivery Channel defines where findings and history are sent (S3, SNS)
# --------------------------------------------------

# S3 bucket for storing AWS Config data
module "config_bucket" {
  count             = var.create_aws_config ? 1 : 0
  source            = "../s3"
  resource_prefix   = var.resource_prefix
  name              = "config-logs"
  enable_versioning = true
  lifecycle_mode    = "cost_optimized"
}

# SNS topic for AWS Config alerts and notifications
resource "aws_sns_topic" "config_alerts" {
  count = var.create_aws_config ? 1 : 0
  name  = "${var.resource_prefix}-config-alerts"
}

# --------------------------------------------------
# Delivery Channel
# --------------------------------------------------

# Defines where AWS Config sends configuration snapshots and history
resource "aws_config_delivery_channel" "this" {
  count          = var.create_aws_config ? 1 : 0
  name           = "${var.resource_prefix}-config-delivery-channel"
  s3_bucket_name = module.config_bucket[0].bucket_id
  sns_topic_arn  = aws_sns_topic.config_alerts[0].arn
}

# --------------------------------------------------
# AWS Config - Security Group Monitoring
# --------------------------------------------------

# Defines which resources AWS Config will monitor
resource "aws_config_configuration_recorder" "this" {
  count    = var.create_aws_config ? 1 : 0
  name     = "${var.resource_prefix}-config-recorder"
  role_arn = aws_iam_role.config_role[0].arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types                = ["AWS::EC2::SecurityGroup"]
  }
}

# Enables the AWS Config recorder
resource "aws_config_configuration_recorder_status" "this" {
  count      = var.create_aws_config ? 1 : 0
  name       = aws_config_configuration_recorder.this[0].name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

# Rule to detect security groups allowing SSH from the internet
resource "aws_config_config_rule" "sg_inbound_rule" {
  count       = var.create_aws_config ? 1 : 0
  name        = "${var.resource_prefix}-sg-inbound-rule"
  description = "Checks if security groups allow unrestricted inbound traffic from the internet"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = [aws_config_configuration_recorder.this]
}

# IAM role that AWS Config assumes to access resources
resource "aws_iam_role" "config_role" {
  count = var.create_aws_config ? 1 : 0
  name  = "${var.resource_prefix}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

# Attaches AWS managed policy for Config service permissions
resource "aws_iam_role_policy_attachment" "config_policy" {
  count      = var.create_aws_config ? 1 : 0
  role       = aws_iam_role.config_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Custom policy allowing Config to write to S3
resource "aws_iam_role_policy" "config_s3_policy" {
  count = var.create_aws_config ? 1 : 0
  name  = "${var.resource_prefix}-config-s3-policy"
  role  = aws_iam_role.config_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          "${module.config_bucket[0].bucket_arn}/*"
        ]
      },
      {
        Action = [
          "s3:GetBucketAcl"
        ]
        Effect = "Allow"
        Resource = [
          module.config_bucket[0].bucket_arn
        ]
      }
    ]
  })
}
