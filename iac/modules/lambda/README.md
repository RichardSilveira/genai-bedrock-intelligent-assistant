# Lambda Module

This module creates an AWS Lambda function with associated resources including IAM roles, CloudWatch log groups, and supports direct deployment from a local zip or Python file (no S3 required).

## Features

- Deploys Lambda function from a local zip or Python file (no S3 required, supports archive_file for packaging)
- Supports Lambda Layers for shared dependencies (e.g., AWS Lambda Powertools)
- Configures IAM role and policy with least-privilege permissions, including support for additional custom statements
- Manages CloudWatch log group with customizable retention
- Supports VPC configuration for Lambda functions (subnets and security groups)
- Allows customization of runtime, memory, timeout, ephemeral storage, and concurrency
- Supports environment variables, dead letter queue (DLQ), and tagging

> See below for full input/output details and usage examples.

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
| [aws_appautoscaling_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_alias.provisioned](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_provisioned_concurrency_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_provisioned_concurrency_config) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_policy_statements"></a> [additional\_policy\_statements](#input\_additional\_policy\_statements) | Additional IAM policy statements to attach to the Lambda execution role | `list(any)` | `[]` | no |
| <a name="input_architectures"></a> [architectures](#input\_architectures) | Instruction set architecture for the Lambda function | `list(string)` | <pre>[<br/>  "x86_64"<br/>]</pre> | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | Maximum capacity for auto scaling of provisioned concurrency | `number` | `10` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | Minimum capacity for auto scaling of provisioned concurrency | `number` | `1` | no |
| <a name="input_autoscaling_target_utilization"></a> [autoscaling\_target\_utilization](#input\_autoscaling\_target\_utilization) | Target utilization percentage for auto scaling of provisioned concurrency (10-90). This is a percentage value that will be converted to a decimal (0.1-0.9) for the AWS API. | `number` | `70` | no |
| <a name="input_dead_letter_target_arn"></a> [dead\_letter\_target\_arn](#input\_dead\_letter\_target\_arn) | ARN of the SQS queue or SNS topic for Lambda dead letter queue (DLQ). Recommended: Place a queue (e.g., SQS) in front of the Lambda for better concurrency control, retry, and to avoid resource exhaustion. Leave null to disable. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Lambda function | `string` | `""` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Whether to enable auto scaling for provisioned concurrency | `bool` | `false` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the Lambda function | `map(string)` | `{}` | no |
| <a name="input_ephemeral_storage_size_mb"></a> [ephemeral\_storage\_size\_mb](#input\_ephemeral\_storage\_size\_mb) | Ephemeral storage size in MB for the Lambda function (/tmp). Minimum 512, maximum 10240. Default is 512. | `number` | `512` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function | `string` | n/a | yes |
| <a name="input_handler"></a> [handler](#input\_handler) | Lambda function handler | `string` | n/a | yes |
| <a name="input_layers"></a> [layers](#input\_layers) | List of Lambda Layer ARNs to attach to the function. | `list(string)` | `[]` | no |
| <a name="input_log_retention_in_days"></a> [log\_retention\_in\_days](#input\_log\_retention\_in\_days) | Number of days to retain Lambda function logs | `number` | `14` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory size in MB | `number` | `128` | no |
| <a name="input_provisioned_concurrent_executions"></a> [provisioned\_concurrent\_executions](#input\_provisioned\_concurrent\_executions) | The amount of provisioned concurrency to allocate for the function. Only applies to published versions and aliases. | `number` | `null` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | The number of simultaneous executions to reserve for the Lambda function. Set to null for unreserved concurrency. | `number` | `null` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix to use for resource names | `string` | n/a | yes |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Lambda function runtime | `string` | `"python3.11"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs for the Lambda function VPC configuration | `list(string)` | `[]` | no |
| <a name="input_source_path"></a> [source\_path](#input\_source\_path) | Path to the Lambda deployment package (zip file). | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for the Lambda function VPC configuration | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout in seconds | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | ARN of the Lambda execution role |
| <a name="output_execution_role_name"></a> [execution\_role\_name](#output\_execution\_role\_name) | Name of the Lambda execution role |
| <a name="output_function_alias_arn"></a> [function\_alias\_arn](#output\_function\_alias\_arn) | ARN of the Lambda alias for provisioned concurrency |
| <a name="output_function_alias_name"></a> [function\_alias\_name](#output\_function\_alias\_name) | Name of the Lambda alias for provisioned concurrency |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function |
| <a name="output_function_invoke_arn"></a> [function\_invoke\_arn](#output\_function\_invoke\_arn) | Invoke ARN of the Lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function |
| <a name="output_function_version"></a> [function\_version](#output\_function\_version) | Version of the Lambda function |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of the Lambda CloudWatch log group |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the Lambda CloudWatch log group |
<!-- END_TF_DOCS -->
