output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets."
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "nat_gateway_ids" {
  description = "The IDs of the NAT Gateways."
  value       = [aws_nat_gateway.nat_1.id, aws_nat_gateway.nat_2.id]
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}
