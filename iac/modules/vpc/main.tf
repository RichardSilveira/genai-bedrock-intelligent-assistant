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

  map_public_ip_on_launch = false # todo - update this module's readme to share that public id addresses are not being assigned to the EC2 Instance's ENI's by design

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
