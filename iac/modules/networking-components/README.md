<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC Configuration. | <pre>object({<br/>    name                          = string<br/>    cidr_block                    = string<br/>    public_subnet_1_cidr          = string<br/>    public_subnet_1_az            = string<br/>    public_subnet_2_cidr          = string<br/>    public_subnet_2_az            = string<br/>    public_subnet_3_cidr          = optional(string)<br/>    public_subnet_3_az            = optional(string)<br/>    private_subnet_1_cidr         = string<br/>    private_subnet_1_az           = string<br/>    private_subnet_2_cidr         = string<br/>    private_subnet_2_az           = string<br/>    private_subnet_3_cidr         = optional(string)<br/>    private_subnet_3_az           = optional(string)<br/>    create_second_nat             = optional(bool, true)<br/>    vpc_enable_dns_hostnames      = optional(bool, true)<br/>    vpc_flowlog_retention_in_days = optional(number, 30)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | The ID of the Internet Gateway |
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | The IDs of the NAT Gateways |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | The IDs of the private subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | The IDs of the public subnets |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->