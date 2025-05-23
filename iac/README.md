# Developer Notes

- You have to request access for the bedrock models used in the project in the region you're intended to deploy it
- The backend configuration (`backend.tf`) is **not committed** to version control. Each developer should create their own `backend.tf` or use CLI flags for backend settings.
- The AWS provider uses variables for `region` and `profile`. You can set these via:
  - CLI:
    `terraform plan -var="aws_profile=your_profile" -var="aws_region=us-east-2"`
  - Environment variables (before running any terraform cli command):
    `export AWS_PROFILE=your_profile`
    `export AWS_REGION=us-east-2`
- If `aws_profile` is not set, Terraform will use your default AWS CLI profile.
- Create a `local.auto.tfvars` and fill it based on the [variables.tf](variables.tf) file.
- Update the [vpc.tf](vpc.tf) file based on the region you're intended to use

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.98.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking-components | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS CLI profile to use | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy resources | `string` | `null` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | The cost center associated with the resources. | `string` | `null` | no |
| <a name="input_created_by"></a> [created\_by](#input\_created\_by) | The arn of the IAM user or role that create the resources | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for the resources (e.g., dev, staging, prod). | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the resources. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project name for the resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nat_gateway_ids"></a> [nat\_gateway\_ids](#output\_nat\_gateway\_ids) | The IDs of the NAT Gateways |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | The IDs of the private subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | The IDs of the public subnets |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->
