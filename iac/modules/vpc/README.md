# VPC Module

This module creates a secure and highly available AWS VPC infrastructure with public and private subnets across multiple availability zones. It implements AWS best practices for network security including dedicated network ACLs for public and private subnets with carefully configured rules to allow only necessary traffic (HTTP/HTTPS, ephemeral ports, and internal VPC communication):

- Network ACLs with appropriate ingress/egress rules for both public and private subnets
- Properly configured route tables with internet and NAT gateway routes
- Locked-down default security group
- Support for multi-AZ deployments with optional third AZ
- Configurable NAT gateway redundancy

The module is designed to be flexible while enforcing security best practices and providing a solid foundation for deploying AWS workloads.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.nat_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_nat_gateway.nat_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_network_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl) | resource |
| [aws_network_acl_rule.private_allow_ephemeral_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_allow_ephemeral_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_allow_http_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_allow_https_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.private_allow_vpc_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_allow_ephemeral_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_allow_ephemeral_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_allow_http_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_allow_http_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_allow_https_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_network_acl_rule.public_allow_https_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl_rule) | resource |
| [aws_route.private_1_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_2_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private_3_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | The CIDR block for the VPC. | `string` | n/a | yes |
| <a name="input_create_second_nat"></a> [create\_second\_nat](#input\_create\_second\_nat) | Whether to create a second NAT gateway. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | The name tag for the VPC. | `string` | n/a | yes |
| <a name="input_private_subnet_1_az"></a> [private\_subnet\_1\_az](#input\_private\_subnet\_1\_az) | Availability zone for the first private subnet (e.g., us-east-1a). | `string` | n/a | yes |
| <a name="input_private_subnet_1_cidr"></a> [private\_subnet\_1\_cidr](#input\_private\_subnet\_1\_cidr) | CIDR block for the first private subnet (e.g., 10.0.11.0/24). | `string` | n/a | yes |
| <a name="input_private_subnet_2_az"></a> [private\_subnet\_2\_az](#input\_private\_subnet\_2\_az) | Availability zone for the second private subnet (e.g., us-east-1b). | `string` | n/a | yes |
| <a name="input_private_subnet_2_cidr"></a> [private\_subnet\_2\_cidr](#input\_private\_subnet\_2\_cidr) | CIDR block for the second private subnet (e.g., 10.0.12.0/24). | `string` | n/a | yes |
| <a name="input_private_subnet_3_az"></a> [private\_subnet\_3\_az](#input\_private\_subnet\_3\_az) | Availability zone for the third private subnet (e.g., us-east-1c). | `string` | `null` | no |
| <a name="input_private_subnet_3_cidr"></a> [private\_subnet\_3\_cidr](#input\_private\_subnet\_3\_cidr) | CIDR block for the third private subnet (e.g., 10.0.13.0/24). | `string` | `null` | no |
| <a name="input_public_subnet_1_az"></a> [public\_subnet\_1\_az](#input\_public\_subnet\_1\_az) | Availability zone for the first public subnet (e.g., us-east-1a). | `string` | n/a | yes |
| <a name="input_public_subnet_1_cidr"></a> [public\_subnet\_1\_cidr](#input\_public\_subnet\_1\_cidr) | CIDR block for the first public subnet (e.g., 10.0.1.0/24). | `string` | n/a | yes |
| <a name="input_public_subnet_2_az"></a> [public\_subnet\_2\_az](#input\_public\_subnet\_2\_az) | Availability zone for the second public subnet (e.g., us-east-1b). | `string` | n/a | yes |
| <a name="input_public_subnet_2_cidr"></a> [public\_subnet\_2\_cidr](#input\_public\_subnet\_2\_cidr) | CIDR block for the second public subnet (e.g., 10.0.2.0/24). | `string` | n/a | yes |
| <a name="input_public_subnet_3_az"></a> [public\_subnet\_3\_az](#input\_public\_subnet\_3\_az) | Availability zone for the third public subnet (e.g., us-east-1c). | `string` | `null` | no |
| <a name="input_public_subnet_3_cidr"></a> [public\_subnet\_3\_cidr](#input\_public\_subnet\_3\_cidr) | CIDR block for the third public subnet (e.g., 10.0.3.0/24). | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_enable_dns_hostnames"></a> [vpc\_enable\_dns\_hostnames](#input\_vpc\_enable\_dns\_hostnames) | Enable DNS hostnames in the VPC. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | The ID of the Internet Gateway. |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | The IDs of the NAT Gateways. |
| <a name="output_private_nacl_id"></a> [private\_nacl\_id](#output\_private\_nacl\_id) | The ID of the private Network ACL. |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | The IDs of the private subnets. |
| <a name="output_public_nacl_id"></a> [public\_nacl\_id](#output\_public\_nacl\_id) | The ID of the public Network ACL. |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | The IDs of the public subnets. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC. |
<!-- END_TF_DOCS -->