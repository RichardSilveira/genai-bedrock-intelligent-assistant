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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | The cost center associated with the resources. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment for the resources (e.g., dev, staging, prod). | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner of the resources. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The project name for the resources. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->