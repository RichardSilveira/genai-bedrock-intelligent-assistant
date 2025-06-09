# S3 Bucket Module

This module enforces organizational best practices for S3 buckets by design, ensuring consistent security and cost optimization across all storage resources. Every bucket created through this module automatically implements server-side encryption with KMS, public access blocking, configurable lifecycle policies (standard or cost-optimized), and optional versioning - eliminating the risk of misconfigured storage while providing flexibility through well-defined parameters that balance security, compliance, and operational needs.

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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.cost_optimized_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.standard_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.enforced_encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable versioning for the S3 bucket | `bool` | `true` | no |
| <a name="input_lifecycle_mode"></a> [lifecycle\_mode](#input\_lifecycle\_mode) | Lifecycle configuration mode: 'standard' (project best practices) or 'cost\_optimized' (aggressive cost savings) | `string` | `"standard"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the S3 bucket (will be combined with prefix) | `string` | n/a | yes |
| <a name="input_newer_noncurrent_versions"></a> [newer\_noncurrent\_versions](#input\_newer\_noncurrent\_versions) | Number of newer versions to keep before deleting noncurrent versions | `number` | `3` | no |
| <a name="input_resource_policy"></a> [resource\_policy](#input\_resource\_policy) | Optional JSON resource policy to attach to the bucket | `string` | `null` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to use for resource names | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the S3 bucket |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | Domain name of the S3 bucket |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | ID (name) of the S3 bucket |
<!-- END_TF_DOCS -->
