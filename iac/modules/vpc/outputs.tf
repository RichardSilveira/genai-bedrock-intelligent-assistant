output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = concat([aws_subnet.public_1.id, aws_subnet.public_2.id], var.public_subnet_3_cidr != null ? [aws_subnet.public_3[0].id] : [])
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = concat([aws_subnet.private_1.id, aws_subnet.private_2.id], var.private_subnet_3_cidr != null ? [aws_subnet.private_3[0].id] : [])
}

output "nat_gateway_ids" {
  description = "The IDs of the NAT Gateways."
  value       = concat([aws_nat_gateway.nat_1.id], var.create_second_nat ? [aws_nat_gateway.nat_2[0].id] : [])
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}