# --------------------------------------------------
# Public Subnets Network ACLs
# --------------------------------------------------
resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = concat([aws_subnet.public_1.id, aws_subnet.public_2.id], var.public_subnet_3_cidr != null ? [aws_subnet.public_3[0].id] : [])

  tags = merge(var.tags, { Name = "${var.name}-public-nacl" })
}

# Allow HTTP inbound traffic
resource "aws_network_acl_rule" "public_allow_http_ingress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow HTTPS inbound traffic
resource "aws_network_acl_rule" "public_allow_https_ingress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow ephemeral ports for return traffic
resource "aws_network_acl_rule" "public_allow_ephemeral_ingress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Allow HTTP outbound traffic
resource "aws_network_acl_rule" "public_allow_http_egress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow HTTPS outbound traffic
resource "aws_network_acl_rule" "public_allow_https_egress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow ephemeral ports for outbound connections
resource "aws_network_acl_rule" "public_allow_ephemeral_egress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# --------------------------------------------------
# Private Subnets Network ACLs
# --------------------------------------------------
resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.this.id
  subnet_ids = concat([aws_subnet.private_1.id, aws_subnet.private_2.id], var.private_subnet_3_cidr != null ? [aws_subnet.private_3[0].id] : [])

  tags = merge(var.tags, { Name = "${var.name}-private-nacl" })
}

# Allow VPC CIDR traffic to private subnets
resource "aws_network_acl_rule" "private_allow_vpc_ingress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.cidr_block
  from_port      = 0
  to_port        = 0
}

# Allow ephemeral ports for return traffic
resource "aws_network_acl_rule" "private_allow_ephemeral_ingress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# Allow HTTP outbound traffic
resource "aws_network_acl_rule" "private_allow_http_egress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow HTTPS outbound traffic
resource "aws_network_acl_rule" "private_allow_https_egress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

# Allow ephemeral ports for outbound connections
resource "aws_network_acl_rule" "private_allow_ephemeral_egress" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}
