# --------------------------------------------------
# VPC
# --------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  enable_dns_support   = true                         # required for basic dns resolution
  enable_dns_hostnames = var.vpc_enable_dns_hostnames # if true enables private dns resolution for vpc interface endpoints

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.name}-igw" })
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  # No ingress rules - deny all inbound traffic by default

  # No egress rules - deny all outbound traffic by default
  # This is more secure but may require explicit security groups for resources

  tags = merge(var.tags, { Name = "${var.name}-default-sg" })
}

# --------------------------------------------------
# Public Subnets
# --------------------------------------------------

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = var.public_subnet_1_az

  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "${var.name}-public-subnet-1" })
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = var.public_subnet_2_az

  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "${var.name}-public-subnet-2" })
}

resource "aws_subnet" "public_3" {
  count             = var.public_subnet_3_cidr != null ? 1 : 0
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_3_cidr
  availability_zone = var.public_subnet_3_az

  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "${var.name}-public-subnet-3" })
}

# --------------------------------------------------
# Private Subnets
# --------------------------------------------------

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.private_subnet_1_az

  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "${var.name}-private-subnet-1" })
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.private_subnet_2_az

  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "${var.name}-private-subnet-2" })
}

resource "aws_subnet" "private_3" {
  count             = var.private_subnet_3_cidr != null ? 1 : 0
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = var.private_subnet_3_az

  map_public_ip_on_launch = false

  tags = merge(var.tags, { Name = "${var.name}-private-subnet-3" })
}

# --------------------------------------------------
# NAT Gateways
# --------------------------------------------------

resource "aws_eip" "nat_1" {
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.name}-nat-eip-1" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_eip" "nat_2" {
  count  = var.create_second_nat ? 1 : 0
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.name}-nat-eip-2" })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1.id

  tags = merge(var.tags, { Name = "${var.name}-nat-gateway-1" })
}

resource "aws_nat_gateway" "nat_2" {
  count         = var.create_second_nat ? 1 : 0
  allocation_id = aws_eip.nat_2[0].id
  subnet_id     = aws_subnet.public_2.id

  tags = merge(var.tags, { Name = "${var.name}-nat-gateway-2" })
}

# --------------------------------------------------
# VPC Flow Logs
# --------------------------------------------------

resource "aws_flow_log" "this" {
  log_destination      = aws_cloudwatch_log_group.flow_log.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
  iam_role_arn         = aws_iam_role.vpc_flow_log.arn

  # Note: Using AWS managed encryption instead of Customer Managed CMK for simplicity.
  # A Customer Managed CMK would provide better auditability and control over the encryption
  # keys but requires additional key management overhead.

  tags = merge(var.tags, { Name = "${var.name}-flow-log" })
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc-flow-log/${var.name}"
  retention_in_days = var.vpc_flowlog_retention_in_days

  tags = merge(var.tags, { Name = "${var.name}-flow-log-group" })

  # checkov:skip=CKV_AWS_338: "Retention set to 30 days as per project requirements"
  # checkov:skip=CKV_AWS_158: "Using default AWS encryption for simplicity"
}

resource "aws_iam_role" "vpc_flow_log" {
  name = "${var.name}-vpc-flow-log-role"

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

  tags = merge(var.tags, { Name = "${var.name}-vpc-flow-log-role" })
}

resource "aws_iam_role_policy" "vpc_flow_log" {
  name = "${var.name}-vpc-flow-log-policy"
  role = aws_iam_role.vpc_flow_log.id

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
          "${aws_cloudwatch_log_group.flow_log.arn}",
          "${aws_cloudwatch_log_group.flow_log.arn}:*"
        ]
      }
    ]
  })
}