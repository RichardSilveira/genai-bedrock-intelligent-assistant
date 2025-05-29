# --------------------------------------------------
# VPC Flow Logs
# --------------------------------------------------

resource "aws_flow_log" "this" {
  count                = var.create_vpc_flow_logs ? 1 : 0
  log_destination      = aws_cloudwatch_log_group.flow_log[0].arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = var.vpc_id
  iam_role_arn         = aws_iam_role.vpc_flow_log[0].arn

  tags = merge(local.combined_tags, { Name = "${var.vpc_name}-flow-log" })
}

resource "aws_cloudwatch_log_group" "flow_log" {
  count             = var.create_vpc_flow_logs ? 1 : 0
  name              = "/aws/vpc-flow-log/${var.vpc_name}"
  retention_in_days = var.vpc_flowlog_retention_in_days

  tags = merge(local.combined_tags, { Name = "${var.vpc_name}-flow-log-group" })

  # checkov:skip=CKV_AWS_338: "Retention set to 30 days as per project requirements"
  # checkov:skip=CKV_AWS_158: "Using default AWS encryption for simplicity"
}

resource "aws_iam_role" "vpc_flow_log" {
  count = var.create_vpc_flow_logs ? 1 : 0
  name  = "${var.vpc_name}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.combined_tags, { Name = "${var.vpc_name}-vpc-flow-log-role" })
}

resource "aws_iam_role_policy" "vpc_flow_log" {
  count = var.create_vpc_flow_logs ? 1 : 0
  name  = "${var.vpc_name}-vpc-flow-log-policy"
  role  = aws_iam_role.vpc_flow_log[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_cloudwatch_log_group.flow_log[0].arn}",
          "${aws_cloudwatch_log_group.flow_log[0].arn}:*"
        ]
      }
    ]
  })
}
