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


# AWS Config: Recording vs. Rule Compliance
# Configuration Recording in AWS Config is about creating an inventory and historical record of your AWS resources' configurations. Think of it as a detailed logbook 📖 that answers "What did this resource look like, and when did it change?" Its primary goal is to provide visibility, track changes over time for operational troubleshooting, security analysis, and asset management. It captures the "as-is" state of your resources.
#
# Rule Compliance, on the other hand, is about evaluating whether those recorded configurations meet your specific desired state, security best practices, or regulatory requirements. Rules act as your auditors 🧐, answering "Is this resource configured correctly according to our policies?" Their goal is to assess adherence to defined standards and flag non-compliant resources, enabling remediation and governance.

# --------------------------------------------------

# S3 bucket for storing AWS Config data
module "config_bucket" {
  source            = "./modules/s3"
  resource_prefix   = local.resource_prefix
  name              = "config-logs"
  enable_versioning = true
  lifecycle_mode    = "standard"
}

# --------------------------------------------------
# Delivery Channel
# --------------------------------------------------

# Defines where AWS Config sends configuration snapshots and history
resource "aws_config_delivery_channel" "this" {
  name           = "${local.resource_prefix}-config-delivery-channel"
  s3_bucket_name = module.config_bucket.bucket_id
  sns_topic_arn  = aws_sns_topic.config_alerts.arn
}

# --------------------------------------------------
# AWS Config - Security Group Monitoring
# --------------------------------------------------

# Defines which resources AWS Config will monitor
resource "aws_config_configuration_recorder" "this" {
  name     = "${local.resource_prefix}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types                = ["AWS::EC2::SecurityGroup"]
  }
}

# Enables the AWS Config recorder
resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

# Rule to detect security groups allowing SSH from the internet
resource "aws_config_config_rule" "sg_inbound_rule" {
  name        = "${local.resource_prefix}-sg-inbound-rule"
  description = "Checks if security groups allow unrestricted inbound traffic from the internet"

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = [aws_config_configuration_recorder.this]
}

# SNS topic for AWS Config alerts and notifications
resource "aws_sns_topic" "config_alerts" {
  name = "${local.resource_prefix}-config-alerts"
}

# IAM role that AWS Config assumes to access resources
resource "aws_iam_role" "config_role" {
  name = "${local.resource_prefix}-config-role"

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
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Custom policy allowing Config to write to S3
resource "aws_iam_role_policy" "config_s3_policy" {
  name = "${local.resource_prefix}-config-s3-policy"
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          "${module.config_bucket.bucket_arn}/*"
        ]
      },
      {
        Action = [
          "s3:GetBucketAcl"
        ]
        Effect = "Allow"
        Resource = [
          module.config_bucket.bucket_arn
        ]
      }
    ]
  })
}
