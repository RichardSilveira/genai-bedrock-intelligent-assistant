# Observability Components Module

This module provides a collection of observability and security monitoring components that can be enabled or disabled individually. It follows a modular approach where each component (AWS Config, Bedrock Logging, VPC Flow Logs, etc.) can be toggled independently through variables, allowing for granular control over which observability features are deployed.

The AWS Config component monitors security groups for SSH access from the internet by default. The Bedrock Model Invocation Logging component captures all model invocations to CloudWatch Logs. The VPC Flow Logs component records network traffic within your VPC for security analysis and troubleshooting. All components follow security best practices and are designed to work together while maintaining independence.

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
| [aws_cloudwatch_log_group.flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_config_config_rule.sg_inbound_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_configuration_recorder.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_delivery_channel.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.bedrock_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.config_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.bedrock_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.config_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.vpc_flow_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.config_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sns_topic.config_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_aws_config"></a> [create\_aws\_config](#input\_create\_aws\_config) | Whether to create AWS Config resources | `bool` | `false` | no |
| <a name="input_create_vpc_flow_logs"></a> [create\_vpc\_flow\_logs](#input\_create\_vpc\_flow\_logs) | Whether to create VPC Flow Logs | `bool` | `false` | no |
| <a name="input_enable_bedrock_model_invocation_logging"></a> [enable\_bedrock\_model\_invocation\_logging](#input\_enable\_bedrock\_model\_invocation\_logging) | Whether to enable Bedrock model invocation logging | `bool` | `false` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to use for resource names | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_flowlog_retention_in_days"></a> [vpc\_flowlog\_retention\_in\_days](#input\_vpc\_flowlog\_retention\_in\_days) | Number of days to retain VPC flow logs | `number` | `30` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC to enable flow logs for (required if create\_vpc\_flow\_logs is true) | `string` | `null` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC (used for naming flow log resources) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bedrock_logging_role_arn"></a> [bedrock\_logging\_role\_arn](#output\_bedrock\_logging\_role\_arn) | ARN of the IAM role used for Bedrock model invocation logging |
| <a name="output_bedrock_model_invocation_log_group_name"></a> [bedrock\_model\_invocation\_log\_group\_name](#output\_bedrock\_model\_invocation\_log\_group\_name) | Name of the CloudWatch log group for Bedrock model invocation logs |
| <a name="output_config_bucket_arn"></a> [config\_bucket\_arn](#output\_config\_bucket\_arn) | ARN of the S3 bucket used for AWS Config logs |
| <a name="output_config_role_arn"></a> [config\_role\_arn](#output\_config\_role\_arn) | ARN of the IAM role used by AWS Config |
| <a name="output_config_sns_topic_arn"></a> [config\_sns\_topic\_arn](#output\_config\_sns\_topic\_arn) | ARN of the SNS topic used for AWS Config notifications |
| <a name="output_vpc_flow_log_group_arn"></a> [vpc\_flow\_log\_group\_arn](#output\_vpc\_flow\_log\_group\_arn) | ARN of the CloudWatch log group for VPC flow logs |
| <a name="output_vpc_flow_log_role_arn"></a> [vpc\_flow\_log\_role\_arn](#output\_vpc\_flow\_log\_role\_arn) | ARN of the IAM role used for VPC flow logs |
<!-- END_TF_DOCS -->