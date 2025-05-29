# --------------------------------------------------
# Public Route Table
# --------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_3" {
  count          = var.public_subnet_3_cidr != null ? 1 : 0
  subnet_id      = aws_subnet.public_3[0].id
  route_table_id = aws_route_table.public.id
}

# --------------------------------------------------
# Private Route Tables
# --------------------------------------------------

resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private-rt-1"
  }
}

resource "aws_route" "private_1_nat" {
  route_table_id         = aws_route_table.private_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private-rt-2"
  }
}

resource "aws_route" "private_2_nat" {
  route_table_id         = aws_route_table.private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.create_second_nat ? aws_nat_gateway.nat_2[0].id : aws_nat_gateway.nat_1.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}

resource "aws_route_table" "private_3" {
  count  = var.private_subnet_3_cidr != null ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name}-private-rt-3"
  }
}

resource "aws_route" "private_3_nat" {
  count                  = var.private_subnet_3_cidr != null ? 1 : 0
  route_table_id         = aws_route_table.private_3[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1.id
}

resource "aws_route_table_association" "private_3" {
  count          = var.private_subnet_3_cidr != null ? 1 : 0
  subnet_id      = aws_subnet.private_3[0].id
  route_table_id = aws_route_table.private_3[0].id
}