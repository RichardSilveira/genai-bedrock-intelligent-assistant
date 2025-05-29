# Observability Components Module

This module provides a collection of observability and security monitoring components that can be enabled or disabled individually. It follows a modular approach where each component (Bedrock Logging, AWS Config, etc.) can be toggled independently through variables, allowing for granular control over which observability features are deployed.

The Bedrock Model Invocation Logging component captures all model invocations to CloudWatch Logs for monitoring and auditing purposes. All components follow security best practices and are designed to work together while maintaining independence.

The AWS Config component monitors security groups for unrestricted inbound traffic and SSH access from the internet by default, with the ability to expand monitoring to additional resource types and compliance rules in the future.


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_config_bucket"></a> [config\_bucket](#module\_config\_bucket) | ../s3 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_bedrock_model_invocation_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_model_invocation_logging_configuration) | resource |
| [aws_cloudwatch_log_group.bedrock_model_invocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_config_config_rule.sg_inbound_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_configuration_recorder.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_delivery_channel.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_iam_role.bedrock_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.config_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.bedrock_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.config_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.config_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sns_topic.config_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_aws_config"></a> [create\_aws\_config](#input\_create\_aws\_config) | Whether to create AWS Config resources | `bool` | `false` | no |
| <a name="input_enable_bedrock_model_invocation_logging"></a> [enable\_bedrock\_model\_invocation\_logging](#input\_enable\_bedrock\_model\_invocation\_logging) | Whether to enable Bedrock model invocation logging | `bool` | `false` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to use for resource names | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bedrock_logging_role_arn"></a> [bedrock\_logging\_role\_arn](#output\_bedrock\_logging\_role\_arn) | ARN of the IAM role used for Bedrock model invocation logging |
| <a name="output_bedrock_model_invocation_log_group_name"></a> [bedrock\_model\_invocation\_log\_group\_name](#output\_bedrock\_model\_invocation\_log\_group\_name) | Name of the CloudWatch log group for Bedrock model invocation logs |
| <a name="output_config_bucket_arn"></a> [config\_bucket\_arn](#output\_config\_bucket\_arn) | ARN of the S3 bucket used for AWS Config logs |
| <a name="output_config_role_arn"></a> [config\_role\_arn](#output\_config\_role\_arn) | ARN of the IAM role used by AWS Config |
| <a name="output_config_sns_topic_arn"></a> [config\_sns\_topic\_arn](#output\_config\_sns\_topic\_arn) | ARN of the SNS topic used for AWS Config notifications |
<!-- END_TF_DOCS -->
