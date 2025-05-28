# Bedrock Components

This module contains all resources required related to bedrock and its AI capabilities

> This module was built on top of the [terraform-aws-bedrock](https://github.com/aws-ia/terraform-aws-bedrock) with many customizations.

## OpenSearch Index Configuration for Bedrock Knowledge Base

The OpenSearch index configuration is critical for proper functioning of the Bedrock Knowledge Base. Below are key concepts and fields used in the index mapping:

### Key Fields and Their Purpose

| Field | Type | Description |
|-------|------|-------------|
| `vector` or `bedrock-knowledge-base-default-vector` | knn_vector | Stores the vector embeddings for semantic search |
| `AMAZON_BEDROCK_TEXT_CHUNK` | text | Contains the actual text chunks from documents |
| `AMAZON_BEDROCK_METADATA` | text (index: false) | Stores metadata about the document but isn't searchable |
| `AMAZON_BEDROCK_TEXT` | text + keyword | Full text content with keyword subfield for exact matching |
| `id` | text + keyword | Unique identifier for each document/chunk |
| `x-amz-bedrock-kb-data-source-id` | text + keyword | Identifies which data source the document came from |
| `x-amz-bedrock-kb-document-page-number` | long | Tracks which page of a document a chunk came from |
| `x-amz-bedrock-kb-source-uri` | text + keyword | Stores the original location/path of the document |

### Vector Configuration

The vector field uses FAISS for efficient similarity search:

```json
"method": {
    "engine": "faiss",
    "space_type": "l2",
    "name": "hnsw",
    "parameters": {}
}
```

- `engine`: FAISS is optimized for vector search
- `space_type`: L2 (Euclidean distance) measures similarity
- `name`: HNSW (Hierarchical Navigable Small World) algorithm for efficient nearest neighbor search

### Dynamic Templates

The index uses dynamic templates to automatically map new string fields that might be added in the future:

```json
"dynamic_templates": [
    {
        "strings": {
            "match_mapping_type": "string",
            "mapping": {
                "fields": {
                    "keyword": {
                        "ignore_above": 2147483647,
                        "type": "keyword"
                    }
                },
                "type": "text"
            }
        }
    }
]
```

This ensures any new metadata fields added by Bedrock will be properly mapped without requiring index changes.

### OpenSearch Troubleshooting Commands

These commands are useful for troubleshooting and inspecting OpenSearch Serverless collections used with Bedrock Knowledge Bases.

> OpenSearch Serverless has a more limited API compared to standard OpenSearch

First, set up environment variables for your collection endpoint and index name:

```bash

# Set the index name

# Get the collection endpoint URL
COLLECTION_NAME="<collection-name>"
REGION="<region>"
ENDPOINT="https://<your-endpoint>.us-east-2.aoss.amazonaws.com"

# Set the index name
INDEX_NAME="<index-name>"
```

#### List All Indices in a Collection

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/_cat/indices?v"
```

#### Get Index Mapping

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/${INDEX_NAME}/_mapping"
```

#### Query Documents in an Index

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/${INDEX_NAME}/_search" \
  -H "Content-Type: application/json" \
  -d '{"query": {"match_all": {}}, "size": 10}'
```

#### Create an Index

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X PUT "${ENDPOINT}/${INDEX_NAME}" \
  -H "Content-Type: application/json" \
  -d @modules/bedrock-rag/index-mapping.json -v
```

#### Delete an Index

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X DELETE "${ENDPOINT}/${INDEX_NAME}"
```

#### Get Collection Health

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/_health"
```

#### Get Collection Stats

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/${INDEX_NAME}/_stats"
```

### Testing the Knowledge Base

This is the same as testing it via the AWS Console
> It can be integrated in the CI as a Integration Testing strategy

```bash
awscurl --service bedrock \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"input":{"text":"hey"},"retrieveAndGenerateConfiguration":{"knowledgeBaseConfiguration":{"generationConfiguration":{"inferenceConfig":{"textInferenceConfig":{"maxTokens":512,"stopSequences":[],"temperature":0,"topP":0.9}}},"knowledgeBaseId":"<KbId>","modelArn":"arn:aws:bedrock:us-east-2:103881053461:inference-profile/us.amazon.nova-micro-v1:0","orchestrationConfiguration":{"inferenceConfig":{"textInferenceConfig":{"maxTokens":512,"stopSequences":[],"temperature":0,"topP":0.9}}},"retrievalConfiguration":{"vectorSearchConfiguration":{"numberOfResults":5}}},"type":"KNOWLEDGE_BASE"}}' \
  https://bedrock-agent-runtime.us-east-2.amazonaws.com/retrieveAndGenerate
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_oss_knowledgebase"></a> [oss\_knowledgebase](#module\_oss\_knowledgebase) | aws-ia/opensearch-serverless/aws | 0.0.4 |

## Resources

| Name | Type |
|------|------|
| [aws_bedrock_model_invocation_logging_configuration.bedrock_model_invocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_model_invocation_logging_configuration) | resource |
| [aws_cloudwatch_log_group.bedrock_model_invocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.knowledge_base_cwl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.bedrock_kb_s3_decryption_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_kb_sql](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_kb_sql_provisioned](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_kb_sql_serverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_knowledge_base_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_knowledge_base_policy_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.bedrock_knowledge_base_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.bedrock_model_invocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.bedrock_kb_oss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.bedrock_model_invocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.bedrock_kb_s3_decryption_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_policy_s3_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_sql_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_sql_provision_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_sql_serverless_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_opensearchserverless_access_policy.updated_data_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [aws_s3_bucket_lifecycle_configuration.s3_data_source_lifecycle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [awscc_bedrock_data_source.knowledge_base_confluence](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_data_source.knowledge_base_ds](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_data_source.knowledge_base_salesforce](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_data_source.knowledge_base_sharepoint](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_data_source.knowledge_base_web_crawler](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_default](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_mongo](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_neptune_analytics](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_opensearch](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_pinecone](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_rds](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_sql](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_logs_delivery.knowledge_base_log_delivery](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/logs_delivery) | resource |
| [awscc_logs_delivery_destination.knowledge_base_log_destination](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/logs_delivery_destination) | resource |
| [awscc_logs_delivery_source.knowledge_base_log_source](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/logs_delivery_source) | resource |
| [awscc_s3_bucket.s3_data_source](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/s3_bucket) | resource |
| [time_sleep.wait_after_index_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.knowledge_base_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_description"></a> [action\_group\_description](#input\_action\_group\_description) | Description of the action group. | `string` | `null` | no |
| <a name="input_action_group_lambda_arns_list"></a> [action\_group\_lambda\_arns\_list](#input\_action\_group\_lambda\_arns\_list) | List of Lambda ARNs for action groups. | `list(string)` | `[]` | no |
| <a name="input_action_group_lambda_names_list"></a> [action\_group\_lambda\_names\_list](#input\_action\_group\_lambda\_names\_list) | List of Lambda names for action groups. | `list(string)` | `[]` | no |
| <a name="input_action_group_list"></a> [action\_group\_list](#input\_action\_group\_list) | List of configurations for available action groups. | <pre>list(object({<br/>    action_group_name                    = optional(string)<br/>    description                          = optional(string)<br/>    action_group_state                   = optional(string)<br/>    parent_action_group_signature        = optional(string)<br/>    skip_resource_in_use_check_on_delete = optional(bool)<br/>    action_group_executor = optional(object({<br/>      custom_control = optional(string)<br/>      lambda         = optional(string)<br/>    }))<br/>    api_schema = optional(object({<br/>      payload = optional(string)<br/>      s3 = optional(object({<br/>        s3_bucket_name = optional(string)<br/>        s3_object_key  = optional(string)<br/>      }))<br/>    }))<br/>    function_schema = optional(object({<br/>      functions = optional(list(object({<br/>        description = optional(string)<br/>        name        = optional(string)<br/>        parameters = optional(map(object({<br/>          description = optional(string)<br/>          required    = optional(bool)<br/>          type        = optional(string)<br/>        })))<br/>        require_confirmation = optional(string)<br/>      })))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_action_group_name"></a> [action\_group\_name](#input\_action\_group\_name) | Name of the action group. | `string` | `null` | no |
| <a name="input_action_group_state"></a> [action\_group\_state](#input\_action\_group\_state) | State of the action group. | `string` | `null` | no |
| <a name="input_agent_alias_description"></a> [agent\_alias\_description](#input\_agent\_alias\_description) | Description of the agent alias. | `string` | `null` | no |
| <a name="input_agent_alias_name"></a> [agent\_alias\_name](#input\_agent\_alias\_name) | The name of the agent alias. | `string` | `"TerraformBedrockAgentAlias"` | no |
| <a name="input_agent_alias_tags"></a> [agent\_alias\_tags](#input\_agent\_alias\_tags) | Tag bedrock agent alias resource. | `map(string)` | `null` | no |
| <a name="input_agent_collaboration"></a> [agent\_collaboration](#input\_agent\_collaboration) | Agents collaboration role. | `string` | `"SUPERVISOR"` | no |
| <a name="input_agent_description"></a> [agent\_description](#input\_agent\_description) | A description of agent. | `string` | `null` | no |
| <a name="input_agent_id"></a> [agent\_id](#input\_agent\_id) | Agent identifier. | `string` | `null` | no |
| <a name="input_agent_name"></a> [agent\_name](#input\_agent\_name) | The name of your agent. | `string` | `"TerraformBedrockAgents"` | no |
| <a name="input_agent_resource_role_arn"></a> [agent\_resource\_role\_arn](#input\_agent\_resource\_role\_arn) | Optional external IAM role ARN for the Bedrock agent resource role. If empty, the module will create one internally. | `string` | `null` | no |
| <a name="input_allow_opensearch_public_access"></a> [allow\_opensearch\_public\_access](#input\_allow\_opensearch\_public\_access) | Whether or not to allow public access to the OpenSearch collection endpoint and the Dashboards endpoint. | `bool` | `true` | no |
| <a name="input_api_schema_payload"></a> [api\_schema\_payload](#input\_api\_schema\_payload) | String OpenAPI Payload. | `string` | `null` | no |
| <a name="input_api_schema_s3_bucket_name"></a> [api\_schema\_s3\_bucket\_name](#input\_api\_schema\_s3\_bucket\_name) | A bucket in S3. | `string` | `null` | no |
| <a name="input_api_schema_s3_object_key"></a> [api\_schema\_s3\_object\_key](#input\_api\_schema\_s3\_object\_key) | An object key in S3. | `string` | `null` | no |
| <a name="input_app_inference_profile_description"></a> [app\_inference\_profile\_description](#input\_app\_inference\_profile\_description) | A description of application inference profile. | `string` | `null` | no |
| <a name="input_app_inference_profile_model_source"></a> [app\_inference\_profile\_model\_source](#input\_app\_inference\_profile\_model\_source) | Source arns for a custom inference profile to copy its regional load balancing config from. This can either be a foundation model or predefined inference profile ARN. | `string` | `null` | no |
| <a name="input_app_inference_profile_name"></a> [app\_inference\_profile\_name](#input\_app\_inference\_profile\_name) | The name of your application inference profile. | `string` | `"AppInferenceProfile"` | no |
| <a name="input_app_inference_profile_tags"></a> [app\_inference\_profile\_tags](#input\_app\_inference\_profile\_tags) | A map of tag keys and values for application inference profile. | `list(map(string))` | `null` | no |
| <a name="input_auth_type"></a> [auth\_type](#input\_auth\_type) | The supported authentication type. | `string` | `null` | no |
| <a name="input_base_prompt_template"></a> [base\_prompt\_template](#input\_base\_prompt\_template) | Defines the prompt template with which to replace the default prompt template. | `string` | `null` | no |
| <a name="input_bda_custom_output_config"></a> [bda\_custom\_output\_config](#input\_bda\_custom\_output\_config) | A list of the BDA custom output configuartion blueprint(s). | <pre>list(object({<br/>    blueprint_arn     = optional(string)<br/>    blueprint_stage   = optional(string)<br/>    blueprint_version = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_bda_kms_encryption_context"></a> [bda\_kms\_encryption\_context](#input\_bda\_kms\_encryption\_context) | The KMS encryption context for the Bedrock data automation project. | `map(string)` | `null` | no |
| <a name="input_bda_kms_key_id"></a> [bda\_kms\_key\_id](#input\_bda\_kms\_key\_id) | The KMS key ID for the Bedrock data automation project. | `string` | `null` | no |
| <a name="input_bda_override_config_state"></a> [bda\_override\_config\_state](#input\_bda\_override\_config\_state) | Configuration state for the BDA override. | `string` | `null` | no |
| <a name="input_bda_project_description"></a> [bda\_project\_description](#input\_bda\_project\_description) | The description of the Bedrock data automation project. | `string` | `null` | no |
| <a name="input_bda_project_name"></a> [bda\_project\_name](#input\_bda\_project\_name) | The name of the Bedrock data automation project. | `string` | `"bda-project"` | no |
| <a name="input_bda_standard_output_configuration"></a> [bda\_standard\_output\_configuration](#input\_bda\_standard\_output\_configuration) | Standard output is pre-defined extraction managed by Bedrock. It can extract information from documents, images, videos, and audio. | <pre>object({<br/>    audio = optional(object({<br/>      extraction = optional(object({<br/>        category = optional(object({<br/>          state = optional(string)<br/>          types = optional(list(string))<br/>        }))<br/>      }))<br/>      generative_field = optional(object({<br/>        state = optional(string)<br/>        types = optional(list(string))<br/>      }))<br/>    }))<br/>    document = optional(object({<br/>      extraction = optional(object({<br/>        bounding_box = optional(object({<br/>          state = optional(string)<br/>        }))<br/>        granularity = optional(object({<br/>          types = optional(list(string))<br/>        }))<br/>      }))<br/>      generative_field = optional(object({<br/>        state = optional(string)<br/>      }))<br/>      output_format = optional(object({<br/>        additional_file_format = optional(object({<br/>          state = optional(string)<br/>        }))<br/>        text_format = optional(object({<br/>          types = optional(list(string))<br/>        }))<br/>      }))<br/>    }))<br/>    image = optional(object({<br/>      extraction = optional(object({<br/>        category = optional(object({<br/>          state = optional(string)<br/>          types = optional(list(string))<br/>        }))<br/>        bounding_box = optional(object({<br/>          state = optional(string)<br/>        }))<br/>      }))<br/>      generative_field = optional(object({<br/>        state = optional(string)<br/>        types = optional(list(string))<br/>      }))<br/>    }))<br/>    video = optional(object({<br/>      extraction = optional(object({<br/>        category = optional(object({<br/>          state = optional(string)<br/>          types = optional(list(string))<br/>        }))<br/>        bounding_box = optional(object({<br/>          state = optional(string)<br/>        }))<br/>      }))<br/>      generative_field = optional(object({<br/>        state = optional(string)<br/>        types = optional(list(string))<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_bda_tags"></a> [bda\_tags](#input\_bda\_tags) | A list of tag keys and values for the Bedrock data automation project. | <pre>list(object({<br/>    key   = string<br/>    value = string<br/>  }))</pre> | `null` | no |
| <a name="input_bedrock_agent_alias_provisioned_throughput"></a> [bedrock\_agent\_alias\_provisioned\_throughput](#input\_bedrock\_agent\_alias\_provisioned\_throughput) | ARN of the Provisioned Throughput assigned to the agent alias. | `string` | `null` | no |
| <a name="input_bedrock_agent_version"></a> [bedrock\_agent\_version](#input\_bedrock\_agent\_version) | Agent version. | `string` | `null` | no |
| <a name="input_blocked_input_messaging"></a> [blocked\_input\_messaging](#input\_blocked\_input\_messaging) | Messaging for when violations are detected in text. | `string` | `"Blocked input"` | no |
| <a name="input_blocked_outputs_messaging"></a> [blocked\_outputs\_messaging](#input\_blocked\_outputs\_messaging) | Messaging for when violations are detected in text. | `string` | `"Blocked output"` | no |
| <a name="input_blueprint_kms_encryption_context"></a> [blueprint\_kms\_encryption\_context](#input\_blueprint\_kms\_encryption\_context) | The KMS encryption context for the blueprint. | `map(string)` | `null` | no |
| <a name="input_blueprint_kms_key_id"></a> [blueprint\_kms\_key\_id](#input\_blueprint\_kms\_key\_id) | The KMS key ID for the blueprint. | `string` | `null` | no |
| <a name="input_blueprint_name"></a> [blueprint\_name](#input\_blueprint\_name) | The name of the BDA blueprint. | `string` | `"bda-blueprint"` | no |
| <a name="input_blueprint_schema"></a> [blueprint\_schema](#input\_blueprint\_schema) | The schema for the blueprint. | `string` | `null` | no |
| <a name="input_blueprint_tags"></a> [blueprint\_tags](#input\_blueprint\_tags) | A list of tag keys and values for the blueprint. | <pre>list(object({<br/>    key   = string<br/>    value = string<br/>  }))</pre> | `null` | no |
| <a name="input_blueprint_type"></a> [blueprint\_type](#input\_blueprint\_type) | The modality type of the blueprint. | `string` | `"DOCUMENT"` | no |
| <a name="input_breakpoint_percentile_threshold"></a> [breakpoint\_percentile\_threshold](#input\_breakpoint\_percentile\_threshold) | The dissimilarity threshold for splitting chunks. | `number` | `null` | no |
| <a name="input_bucket_owner_account_id"></a> [bucket\_owner\_account\_id](#input\_bucket\_owner\_account\_id) | Bucket account owner ID for the S3 bucket. | `string` | `null` | no |
| <a name="input_chunking_strategy"></a> [chunking\_strategy](#input\_chunking\_strategy) | Knowledge base can split your source data into chunks. A chunk refers to an excerpt from a data source that is returned when the knowledge base that it belongs to is queried. You have the following options for chunking your data. If you opt for NONE, then you may want to pre-process your files by splitting them up such that each file corresponds to a chunk. | `string` | `null` | no |
| <a name="input_chunking_strategy_max_tokens"></a> [chunking\_strategy\_max\_tokens](#input\_chunking\_strategy\_max\_tokens) | The maximum number of tokens to include in a chunk. | `number` | `null` | no |
| <a name="input_chunking_strategy_overlap_percentage"></a> [chunking\_strategy\_overlap\_percentage](#input\_chunking\_strategy\_overlap\_percentage) | The percentage of overlap between adjacent chunks of a data source. | `number` | `null` | no |
| <a name="input_collaboration_instruction"></a> [collaboration\_instruction](#input\_collaboration\_instruction) | Instruction to give the collaborator. | `string` | `null` | no |
| <a name="input_collaborator_name"></a> [collaborator\_name](#input\_collaborator\_name) | The name of the collaborator. | `string` | `"TerraformBedrockAgentCollaborator"` | no |
| <a name="input_collection_arn"></a> [collection\_arn](#input\_collection\_arn) | The ARN of the collection. | `string` | `null` | no |
| <a name="input_collection_name"></a> [collection\_name](#input\_collection\_name) | The name of the collection. | `string` | `null` | no |
| <a name="input_collection_tags"></a> [collection\_tags](#input\_collection\_tags) | Tags to apply to the OpenSearch collection. | <pre>list(object({<br/>    key   = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_confluence_credentials_secret_arn"></a> [confluence\_credentials\_secret\_arn](#input\_confluence\_credentials\_secret\_arn) | The ARN of an AWS Secrets Manager secret that stores your authentication credentials for your Confluence instance URL. | `string` | `null` | no |
| <a name="input_connection_string"></a> [connection\_string](#input\_connection\_string) | The endpoint URL for your index management page. | `string` | `null` | no |
| <a name="input_crawl_filter_type"></a> [crawl\_filter\_type](#input\_crawl\_filter\_type) | The crawl filter type. | `string` | `null` | no |
| <a name="input_crawler_scope"></a> [crawler\_scope](#input\_crawler\_scope) | The scope that a web crawl job will be restricted to. | `string` | `null` | no |
| <a name="input_create_ag"></a> [create\_ag](#input\_create\_ag) | Whether or not to create an action group. | `bool` | `false` | no |
| <a name="input_create_agent"></a> [create\_agent](#input\_create\_agent) | Whether or not to deploy an agent. | `bool` | `true` | no |
| <a name="input_create_agent_alias"></a> [create\_agent\_alias](#input\_create\_agent\_alias) | Whether or not to create an agent alias. | `bool` | `false` | no |
| <a name="input_create_app_inference_profile"></a> [create\_app\_inference\_profile](#input\_create\_app\_inference\_profile) | Whether or not to create an application inference profile. | `bool` | `false` | no |
| <a name="input_create_bda"></a> [create\_bda](#input\_create\_bda) | Whether or not to create a Bedrock data automatio project. | `bool` | `false` | no |
| <a name="input_create_blueprint"></a> [create\_blueprint](#input\_create\_blueprint) | Whether or not to create a BDA blueprint. | `bool` | `false` | no |
| <a name="input_create_collaborator"></a> [create\_collaborator](#input\_create\_collaborator) | Whether or not to create an agent collaborator. | `bool` | `false` | no |
| <a name="input_create_confluence"></a> [create\_confluence](#input\_create\_confluence) | Whether or not create a Confluence data source. | `bool` | `false` | no |
| <a name="input_create_custom_model"></a> [create\_custom\_model](#input\_create\_custom\_model) | Whether or not to create a custom model. | `bool` | `false` | no |
| <a name="input_create_custom_tranformation_config"></a> [create\_custom\_tranformation\_config](#input\_create\_custom\_tranformation\_config) | Whether or not to create a custom transformation configuration. | `bool` | `false` | no |
| <a name="input_create_default_kb"></a> [create\_default\_kb](#input\_create\_default\_kb) | Whether or not to create the default knowledge base. | `bool` | `false` | no |
| <a name="input_create_flow_alias"></a> [create\_flow\_alias](#input\_create\_flow\_alias) | Whether or not to create a flow alias resource. | `bool` | `false` | no |
| <a name="input_create_guardrail"></a> [create\_guardrail](#input\_create\_guardrail) | Whether or not to create a guardrail. | `bool` | `false` | no |
| <a name="input_create_kb"></a> [create\_kb](#input\_create\_kb) | Whether or not to attach a knowledge base. | `bool` | `false` | no |
| <a name="input_create_kb_log_group"></a> [create\_kb\_log\_group](#input\_create\_kb\_log\_group) | Whether or not to create a log group for the knowledge base. | `bool` | `false` | no |
| <a name="input_create_kendra_config"></a> [create\_kendra\_config](#input\_create\_kendra\_config) | Whether or not to create a Kendra GenAI knowledge base. | `bool` | `false` | no |
| <a name="input_create_kendra_s3_data_source"></a> [create\_kendra\_s3\_data\_source](#input\_create\_kendra\_s3\_data\_source) | Whether or not to create a Kendra S3 data source. | `bool` | `false` | no |
| <a name="input_create_mongo_config"></a> [create\_mongo\_config](#input\_create\_mongo\_config) | Whether or not to use MongoDB Atlas configuration | `bool` | `false` | no |
| <a name="input_create_neptune_analytics_config"></a> [create\_neptune\_analytics\_config](#input\_create\_neptune\_analytics\_config) | Whether or not to use Neptune Analytics configuration | `bool` | `false` | no |
| <a name="input_create_opensearch_config"></a> [create\_opensearch\_config](#input\_create\_opensearch\_config) | Whether or not to use Opensearch Serverless configuration | `bool` | `false` | no |
| <a name="input_create_parsing_configuration"></a> [create\_parsing\_configuration](#input\_create\_parsing\_configuration) | Whether or not to create a parsing configuration. | `bool` | `false` | no |
| <a name="input_create_pinecone_config"></a> [create\_pinecone\_config](#input\_create\_pinecone\_config) | Whether or not to use Pinecone configuration | `bool` | `false` | no |
| <a name="input_create_prompt"></a> [create\_prompt](#input\_create\_prompt) | Whether or not to create a prompt resource. | `bool` | `false` | no |
| <a name="input_create_prompt_version"></a> [create\_prompt\_version](#input\_create\_prompt\_version) | Whether or not to create a prompt version. | `bool` | `false` | no |
| <a name="input_create_rds_config"></a> [create\_rds\_config](#input\_create\_rds\_config) | Whether or not to use RDS configuration | `bool` | `false` | no |
| <a name="input_create_s3_data_source"></a> [create\_s3\_data\_source](#input\_create\_s3\_data\_source) | Whether or not to create the S3 data source. | `bool` | `false` | no |
| <a name="input_create_salesforce"></a> [create\_salesforce](#input\_create\_salesforce) | Whether or not create a Salesforce data source. | `bool` | `false` | no |
| <a name="input_create_sharepoint"></a> [create\_sharepoint](#input\_create\_sharepoint) | Whether or not create a Share Point data source. | `bool` | `false` | no |
| <a name="input_create_sql_config"></a> [create\_sql\_config](#input\_create\_sql\_config) | Whether or not to create a SQL knowledge base. | `bool` | `false` | no |
| <a name="input_create_supervisor"></a> [create\_supervisor](#input\_create\_supervisor) | Whether or not to create an agent supervisor. | `bool` | `false` | no |
| <a name="input_create_supervisor_guardrail"></a> [create\_supervisor\_guardrail](#input\_create\_supervisor\_guardrail) | Whether or not to create a guardrail for the supervisor agent. | `bool` | `false` | no |
| <a name="input_create_supplemental_data_storage"></a> [create\_supplemental\_data\_storage](#input\_create\_supplemental\_data\_storage) | Whether or not to create supplemental data storage configuration. | `bool` | `false` | no |
| <a name="input_create_vector_ingestion_configuration"></a> [create\_vector\_ingestion\_configuration](#input\_create\_vector\_ingestion\_configuration) | Whether or not to create a vector ingestion configuration. | `bool` | `false` | no |
| <a name="input_create_web_crawler"></a> [create\_web\_crawler](#input\_create\_web\_crawler) | Whether or not create a web crawler data source. | `bool` | `false` | no |
| <a name="input_credentials_secret_arn"></a> [credentials\_secret\_arn](#input\_credentials\_secret\_arn) | The ARN of the secret in Secrets Manager that is linked to your database | `string` | `null` | no |
| <a name="input_custom_control"></a> [custom\_control](#input\_custom\_control) | Custom control of action execution. | `string` | `null` | no |
| <a name="input_custom_metadata_field"></a> [custom\_metadata\_field](#input\_custom\_metadata\_field) | The name of the field in which Amazon Bedrock stores custom metadata about the vector store. | `string` | `null` | no |
| <a name="input_custom_model_hyperparameters"></a> [custom\_model\_hyperparameters](#input\_custom\_model\_hyperparameters) | Parameters related to tuning the custom model. | `map(string)` | <pre>{<br/>  "batchSize": "1",<br/>  "epochCount": "2",<br/>  "learningRate": "0.00001",<br/>  "learningRateWarmupSteps": "10"<br/>}</pre> | no |
| <a name="input_custom_model_id"></a> [custom\_model\_id](#input\_custom\_model\_id) | The base model id for a custom model. | `string` | `"amazon.titan-text-express-v1"` | no |
| <a name="input_custom_model_job_name"></a> [custom\_model\_job\_name](#input\_custom\_model\_job\_name) | A name for the model customization job. | `string` | `"custom-model-job"` | no |
| <a name="input_custom_model_kms_key_id"></a> [custom\_model\_kms\_key\_id](#input\_custom\_model\_kms\_key\_id) | The custom model is encrypted at rest using this key. Specify the key ARN. | `string` | `null` | no |
| <a name="input_custom_model_name"></a> [custom\_model\_name](#input\_custom\_model\_name) | Name for the custom model. | `string` | `"custom-model"` | no |
| <a name="input_custom_model_output_uri"></a> [custom\_model\_output\_uri](#input\_custom\_model\_output\_uri) | The S3 URI where the output data is stored for custom model. | `string` | `null` | no |
| <a name="input_custom_model_tags"></a> [custom\_model\_tags](#input\_custom\_model\_tags) | A map of tag keys and values for the custom model. | `map(string)` | `null` | no |
| <a name="input_custom_model_training_uri"></a> [custom\_model\_training\_uri](#input\_custom\_model\_training\_uri) | The S3 URI where the training data is stored for custom model. | `string` | `null` | no |
| <a name="input_customer_encryption_key_arn"></a> [customer\_encryption\_key\_arn](#input\_customer\_encryption\_key\_arn) | A KMS key ARN. | `string` | `null` | no |
| <a name="input_customization_type"></a> [customization\_type](#input\_customization\_type) | The customization type. Valid values: FINE\_TUNING, CONTINUED\_PRE\_TRAINING. | `string` | `"FINE_TUNING"` | no |
| <a name="input_data_deletion_policy"></a> [data\_deletion\_policy](#input\_data\_deletion\_policy) | Policy for deleting data from the data source. Can be either DELETE or RETAIN. | `string` | `"DELETE"` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the database. | `string` | `null` | no |
| <a name="input_default_variant"></a> [default\_variant](#input\_default\_variant) | Name for a variant. | `string` | `null` | no |
| <a name="input_document_metadata_configurations"></a> [document\_metadata\_configurations](#input\_document\_metadata\_configurations) | List of document metadata configurations for Kendra. | <pre>list(object({<br/>    name = optional(string)<br/>    type = optional(string)<br/>    search = optional(object({<br/>      facetable   = optional(bool)<br/>      searchable  = optional(bool)<br/>      displayable = optional(bool)<br/>      sortable    = optional(bool)<br/>    }))<br/>    relevance = optional(object({<br/>      duration   = optional(string)<br/>      freshness  = optional(bool)<br/>      importance = optional(number)<br/>      rank_order = optional(string)<br/>      value_importance_items = optional(list(object({<br/>        key   = optional(string)<br/>        value = optional(number)<br/>      })))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_embedding_data_type"></a> [embedding\_data\_type](#input\_embedding\_data\_type) | The data type for the vectors when using a model to convert text into vector embeddings. | `string` | `null` | no |
| <a name="input_embedding_model_dimensions"></a> [embedding\_model\_dimensions](#input\_embedding\_model\_dimensions) | The dimensions details for the vector configuration used on the Bedrock embeddings model. | `number` | `null` | no |
| <a name="input_enable_model_invocation_logging"></a> [enable\_model\_invocation\_logging](#input\_enable\_model\_invocation\_logging) | Enable Bedrock Model Invocation Logging | `bool` | `false` | no |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Database endpoint | `string` | `null` | no |
| <a name="input_endpoint_service_name"></a> [endpoint\_service\_name](#input\_endpoint\_service\_name) | MongoDB Atlas endpoint service name. | `string` | `null` | no |
| <a name="input_exclusion_filters"></a> [exclusion\_filters](#input\_exclusion\_filters) | A set of regular expression filter patterns for a type of object. | `list(string)` | `[]` | no |
| <a name="input_existing_kb"></a> [existing\_kb](#input\_existing\_kb) | The ID of the existing knowledge base. | `string` | `null` | no |
| <a name="input_filters_config"></a> [filters\_config](#input\_filters\_config) | List of content filter configs in content policy. | `list(map(string))` | `null` | no |
| <a name="input_flow_alias_description"></a> [flow\_alias\_description](#input\_flow\_alias\_description) | A description of the flow alias. | `string` | `null` | no |
| <a name="input_flow_alias_name"></a> [flow\_alias\_name](#input\_flow\_alias\_name) | The name of your flow alias. | `string` | `"BedrockFlowAlias"` | no |
| <a name="input_flow_arn"></a> [flow\_arn](#input\_flow\_arn) | ARN representation of the flow. | `string` | `null` | no |
| <a name="input_flow_version"></a> [flow\_version](#input\_flow\_version) | Version of the flow. | `string` | `null` | no |
| <a name="input_flow_version_description"></a> [flow\_version\_description](#input\_flow\_version\_description) | A description of flow version. | `string` | `null` | no |
| <a name="input_foundation_model"></a> [foundation\_model](#input\_foundation\_model) | The foundation model for the Bedrock agent. | `string` | `null` | no |
| <a name="input_graph_arn"></a> [graph\_arn](#input\_graph\_arn) | ARN for Neptune Analytics graph database. | `string` | `null` | no |
| <a name="input_guardrail_description"></a> [guardrail\_description](#input\_guardrail\_description) | Description of the guardrail. | `string` | `null` | no |
| <a name="input_guardrail_kms_key_arn"></a> [guardrail\_kms\_key\_arn](#input\_guardrail\_kms\_key\_arn) | KMS encryption key to use for the guardrail. | `string` | `null` | no |
| <a name="input_guardrail_name"></a> [guardrail\_name](#input\_guardrail\_name) | The name of the guardrail. | `string` | `"TerraformBedrockGuardrail"` | no |
| <a name="input_guardrail_tags"></a> [guardrail\_tags](#input\_guardrail\_tags) | A map of tags keys and values for the knowledge base. | `list(map(string))` | `null` | no |
| <a name="input_heirarchical_overlap_tokens"></a> [heirarchical\_overlap\_tokens](#input\_heirarchical\_overlap\_tokens) | The number of tokens to repeat across chunks in the same layer. | `number` | `null` | no |
| <a name="input_host_type"></a> [host\_type](#input\_host\_type) | The supported host type, whether online/cloud or server/on-premises. | `string` | `null` | no |
| <a name="input_host_url"></a> [host\_url](#input\_host\_url) | The host URL or instance URL. | `string` | `null` | no |
| <a name="input_idle_session_ttl"></a> [idle\_session\_ttl](#input\_idle\_session\_ttl) | How long sessions should be kept open for the agent. | `number` | `600` | no |
| <a name="input_inclusion_filters"></a> [inclusion\_filters](#input\_inclusion\_filters) | A set of regular expression filter patterns for a type of object. | `list(string)` | `[]` | no |
| <a name="input_instruction"></a> [instruction](#input\_instruction) | A narrative instruction to provide the agent as context. | `string` | `""` | no |
| <a name="input_kb_description"></a> [kb\_description](#input\_kb\_description) | Description of knowledge base. | `string` | `"Terraform deployed Knowledge Base"` | no |
| <a name="input_kb_embedding_model_arn"></a> [kb\_embedding\_model\_arn](#input\_kb\_embedding\_model\_arn) | The ARN of the model used to create vector embeddings for the knowledge base. | `string` | `"arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"` | no |
| <a name="input_kb_log_group_retention_in_days"></a> [kb\_log\_group\_retention\_in\_days](#input\_kb\_log\_group\_retention\_in\_days) | The retention period of the knowledge base log group. | `number` | `0` | no |
| <a name="input_kb_monitoring_arn"></a> [kb\_monitoring\_arn](#input\_kb\_monitoring\_arn) | The ARN of the target for delivery of knowledge base application logs | `string` | `null` | no |
| <a name="input_kb_name"></a> [kb\_name](#input\_kb\_name) | Name of the knowledge base. | `string` | `"knowledge-base"` | no |
| <a name="input_kb_role_arn"></a> [kb\_role\_arn](#input\_kb\_role\_arn) | The ARN of the IAM role with permission to invoke API operations on the knowledge base. | `string` | `null` | no |
| <a name="input_kb_s3_data_source"></a> [kb\_s3\_data\_source](#input\_kb\_s3\_data\_source) | The S3 data source ARN for the knowledge base. | `string` | `null` | no |
| <a name="input_kb_s3_data_source_kms_arn"></a> [kb\_s3\_data\_source\_kms\_arn](#input\_kb\_s3\_data\_source\_kms\_arn) | The ARN of the KMS key used to encrypt S3 content | `string` | `null` | no |
| <a name="input_kb_state"></a> [kb\_state](#input\_kb\_state) | State of knowledge base; whether it is enabled or disabled | `string` | `"ENABLED"` | no |
| <a name="input_kb_storage_type"></a> [kb\_storage\_type](#input\_kb\_storage\_type) | The storage type of a knowledge base. | `string` | `null` | no |
| <a name="input_kb_tags"></a> [kb\_tags](#input\_kb\_tags) | A map of tags keys and values for the knowledge base. | `map(string)` | `null` | no |
| <a name="input_kb_type"></a> [kb\_type](#input\_kb\_type) | The type of a knowledge base. | `string` | `"VECTOR"` | no |
| <a name="input_kendra_data_source_description"></a> [kendra\_data\_source\_description](#input\_kendra\_data\_source\_description) | A description for the Kendra data source. | `string` | `null` | no |
| <a name="input_kendra_data_source_language_code"></a> [kendra\_data\_source\_language\_code](#input\_kendra\_data\_source\_language\_code) | The code for the language of the Kendra data source content. | `string` | `"en"` | no |
| <a name="input_kendra_data_source_name"></a> [kendra\_data\_source\_name](#input\_kendra\_data\_source\_name) | The name of the Kendra data source. | `string` | `"kendra-data-source"` | no |
| <a name="input_kendra_data_source_schedule"></a> [kendra\_data\_source\_schedule](#input\_kendra\_data\_source\_schedule) | The schedule for Amazon Kendra to update the index. | `string` | `null` | no |
| <a name="input_kendra_data_source_tags"></a> [kendra\_data\_source\_tags](#input\_kendra\_data\_source\_tags) | A map of tag keys and values for Kendra data source. | `list(map(string))` | `null` | no |
| <a name="input_kendra_index_arn"></a> [kendra\_index\_arn](#input\_kendra\_index\_arn) | The ARN of the existing Kendra index. | `string` | `null` | no |
| <a name="input_kendra_index_description"></a> [kendra\_index\_description](#input\_kendra\_index\_description) | A description for the Kendra index. | `string` | `null` | no |
| <a name="input_kendra_index_edition"></a> [kendra\_index\_edition](#input\_kendra\_index\_edition) | The Amazon Kendra Edition to use for the index. | `string` | `"GEN_AI_ENTERPRISE_EDITION"` | no |
| <a name="input_kendra_index_id"></a> [kendra\_index\_id](#input\_kendra\_index\_id) | The ID of the existing Kendra index. | `string` | `null` | no |
| <a name="input_kendra_index_name"></a> [kendra\_index\_name](#input\_kendra\_index\_name) | The name of the Kendra index. | `string` | `"kendra-genai-index"` | no |
| <a name="input_kendra_index_query_capacity"></a> [kendra\_index\_query\_capacity](#input\_kendra\_index\_query\_capacity) | The number of queries per second allowed for the Kendra index. | `number` | `1` | no |
| <a name="input_kendra_index_storage_capacity"></a> [kendra\_index\_storage\_capacity](#input\_kendra\_index\_storage\_capacity) | The storage capacity of the Kendra index. | `number` | `1` | no |
| <a name="input_kendra_index_tags"></a> [kendra\_index\_tags](#input\_kendra\_index\_tags) | A map of tag keys and values for Kendra index. | `list(map(string))` | `null` | no |
| <a name="input_kendra_index_user_context_policy"></a> [kendra\_index\_user\_context\_policy](#input\_kendra\_index\_user\_context\_policy) | The Kendra index user context policy. | `string` | `null` | no |
| <a name="input_kendra_kms_key_id"></a> [kendra\_kms\_key\_id](#input\_kendra\_kms\_key\_id) | The Kendra index is encrypted at rest using this key. Specify the key ARN. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS encryption key to use for the agent. | `string` | `null` | no |
| <a name="input_lambda_action_group_executor"></a> [lambda\_action\_group\_executor](#input\_lambda\_action\_group\_executor) | ARN of Lambda. | `string` | `null` | no |
| <a name="input_level_configurations_list"></a> [level\_configurations\_list](#input\_level\_configurations\_list) | Token settings for each layer. | `list(object({ max_tokens = number }))` | `null` | no |
| <a name="input_managed_word_lists_config"></a> [managed\_word\_lists\_config](#input\_managed\_word\_lists\_config) | A config for the list of managed words. | `list(map(string))` | `null` | no |
| <a name="input_max_length"></a> [max\_length](#input\_max\_length) | The maximum number of tokens to generate in the response. | `number` | `0` | no |
| <a name="input_memory_configuration"></a> [memory\_configuration](#input\_memory\_configuration) | Configuration for agent memory storage | <pre>object({<br/>    enabled_memory_types = optional(list(string))<br/>    session_summary_configuration = optional(object({<br/>      max_recent_sessions = optional(number)<br/>    }))<br/>    storage_days = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_metadata_field"></a> [metadata\_field](#input\_metadata\_field) | The name of the field in which Amazon Bedrock stores metadata about the vector store. | `string` | `"AMAZON_BEDROCK_METADATA"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | This value is appended at the beginning of resource names. | `string` | `"BedrockAgents"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to be used to write new data to your pinecone database | `string` | `null` | no |
| <a name="input_number_of_replicas"></a> [number\_of\_replicas](#input\_number\_of\_replicas) | The number of replica shards for the OpenSearch index. | `string` | `"1"` | no |
| <a name="input_number_of_shards"></a> [number\_of\_shards](#input\_number\_of\_shards) | The number of shards for the OpenSearch index. This setting cannot be changed after index creation. | `string` | `"1"` | no |
| <a name="input_override_lambda_arn"></a> [override\_lambda\_arn](#input\_override\_lambda\_arn) | The ARN of the Lambda function to use when parsing the raw foundation model output in parts of the agent sequence. | `string` | `null` | no |
| <a name="input_parent_action_group_signature"></a> [parent\_action\_group\_signature](#input\_parent\_action\_group\_signature) | Action group signature for a builtin action. | `string` | `null` | no |
| <a name="input_parser_mode"></a> [parser\_mode](#input\_parser\_mode) | Specifies whether to override the default parser Lambda function. | `string` | `null` | no |
| <a name="input_parsing_config_model_arn"></a> [parsing\_config\_model\_arn](#input\_parsing\_config\_model\_arn) | The model's ARN. | `string` | `null` | no |
| <a name="input_parsing_prompt_text"></a> [parsing\_prompt\_text](#input\_parsing\_prompt\_text) | Instructions for interpreting the contents of a document. | `string` | `null` | no |
| <a name="input_parsing_strategy"></a> [parsing\_strategy](#input\_parsing\_strategy) | The parsing strategy for the data source. | `string` | `null` | no |
| <a name="input_pattern_object_filter_list"></a> [pattern\_object\_filter\_list](#input\_pattern\_object\_filter\_list) | List of pattern object information. | <pre>list(object({<br/>    exclusion_filters = optional(list(string))<br/>    inclusion_filters = optional(list(string))<br/>    object_type       = optional(string)<br/><br/>  }))</pre> | `[]` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | The ARN of the IAM permission boundary for the role. | `string` | `null` | no |
| <a name="input_pii_entities_config"></a> [pii\_entities\_config](#input\_pii\_entities\_config) | List of entities. | `list(map(string))` | `null` | no |
| <a name="input_primary_key_field"></a> [primary\_key\_field](#input\_primary\_key\_field) | The name of the field in which Bedrock stores the ID for each entry. | `string` | `null` | no |
| <a name="input_prompt_creation_mode"></a> [prompt\_creation\_mode](#input\_prompt\_creation\_mode) | Specifies whether to override the default prompt template. | `string` | `null` | no |
| <a name="input_prompt_description"></a> [prompt\_description](#input\_prompt\_description) | Description for a prompt resource. | `string` | `null` | no |
| <a name="input_prompt_name"></a> [prompt\_name](#input\_prompt\_name) | Name for a prompt resource. | `string` | `null` | no |
| <a name="input_prompt_override"></a> [prompt\_override](#input\_prompt\_override) | Whether to provide prompt override configuration. | `bool` | `false` | no |
| <a name="input_prompt_state"></a> [prompt\_state](#input\_prompt\_state) | Specifies whether to allow the agent to carry out the step specified in the promptType. | `string` | `null` | no |
| <a name="input_prompt_tags"></a> [prompt\_tags](#input\_prompt\_tags) | A map of tag keys and values for prompt resource. | `map(string)` | `null` | no |
| <a name="input_prompt_type"></a> [prompt\_type](#input\_prompt\_type) | The step in the agent sequence that this prompt configuration applies to. | `string` | `null` | no |
| <a name="input_prompt_version_description"></a> [prompt\_version\_description](#input\_prompt\_version\_description) | Description for a prompt version resource. | `string` | `null` | no |
| <a name="input_prompt_version_tags"></a> [prompt\_version\_tags](#input\_prompt\_version\_tags) | A map of tag keys and values for a prompt version resource. | `map(string)` | `null` | no |
| <a name="input_provisioned_auth_configuration"></a> [provisioned\_auth\_configuration](#input\_provisioned\_auth\_configuration) | Configurations for provisioned Redshift query engine | <pre>object({<br/>    database_user                = optional(string)<br/>    type                         = optional(string)<br/>    username_password_secret_arn = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_provisioned_config_cluster_identifier"></a> [provisioned\_config\_cluster\_identifier](#input\_provisioned\_config\_cluster\_identifier) | The cluster identifier for the provisioned Redshift query engine. | `string` | `null` | no |
| <a name="input_query_generation_configuration"></a> [query\_generation\_configuration](#input\_query\_generation\_configuration) | Configurations for generating Redshift engine queries. | <pre>object({<br/>    generation_context = optional(object({<br/>      curated_queries = optional(list(object({<br/>        natural_language = optional(string)<br/>        sql              = optional(string)<br/>      })))<br/>      tables = optional(list(object({<br/>        columns = optional(list(object({<br/>          description = optional(string)<br/>          inclusion   = optional(string)<br/>          name        = optional(string)<br/>        })))<br/>        description = optional(string)<br/>        inclusion   = optional(string)<br/>        name        = optional(string)<br/>      })))<br/>    }))<br/>    execution_timeout_seconds = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_rate_limit"></a> [rate\_limit](#input\_rate\_limit) | Rate of web URLs retrieved per minute. | `number` | `null` | no |
| <a name="input_redshift_query_engine_type"></a> [redshift\_query\_engine\_type](#input\_redshift\_query\_engine\_type) | Redshift query engine type for the knowledge base. Defaults to SERVERLESS | `string` | `"SERVERLESS"` | no |
| <a name="input_redshift_storage_configuration"></a> [redshift\_storage\_configuration](#input\_redshift\_storage\_configuration) | List of configurations for available Redshift query engine storage types. | <pre>list(object({<br/>    aws_data_catalog_configuration = optional(object({<br/>      table_names = optional(list(string))<br/>    }))<br/>    redshift_configuration = optional(object({<br/>      database_name = optional(string)<br/>    }))<br/>    type = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_regexes_config"></a> [regexes\_config](#input\_regexes\_config) | List of regex. | `list(map(string))` | `null` | no |
| <a name="input_resource_arn"></a> [resource\_arn](#input\_resource\_arn) | The ARN of the vector store. | `string` | `null` | no |
| <a name="input_resource_prefix"></a> [resource\_prefix](#input\_resource\_prefix) | Prefix for resource names | `string` | n/a | yes |
| <a name="input_s3_data_source_bucket_name"></a> [s3\_data\_source\_bucket\_name](#input\_s3\_data\_source\_bucket\_name) | The name of the S3 bucket where the data source is stored. | `string` | `null` | no |
| <a name="input_s3_data_source_document_metadata_prefix"></a> [s3\_data\_source\_document\_metadata\_prefix](#input\_s3\_data\_source\_document\_metadata\_prefix) | The prefix for the S3 data source. | `string` | `null` | no |
| <a name="input_s3_data_source_exclusion_patterns"></a> [s3\_data\_source\_exclusion\_patterns](#input\_s3\_data\_source\_exclusion\_patterns) | A list of glob patterns to exclude from the data source. | `list(string)` | `null` | no |
| <a name="input_s3_data_source_inclusion_patterns"></a> [s3\_data\_source\_inclusion\_patterns](#input\_s3\_data\_source\_inclusion\_patterns) | A list of glob patterns to include in the data source. | `list(string)` | `null` | no |
| <a name="input_s3_data_source_key_path"></a> [s3\_data\_source\_key\_path](#input\_s3\_data\_source\_key\_path) | The S3 key path where for the data source. | `string` | `null` | no |
| <a name="input_s3_inclusion_prefixes"></a> [s3\_inclusion\_prefixes](#input\_s3\_inclusion\_prefixes) | List of S3 prefixes that define the object containing the data sources. | `list(string)` | `null` | no |
| <a name="input_s3_location_uri"></a> [s3\_location\_uri](#input\_s3\_location\_uri) | A location for storing content from data sources temporarily as it is processed by custom components in the ingestion pipeline. | `string` | `null` | no |
| <a name="input_salesforce_credentials_secret_arn"></a> [salesforce\_credentials\_secret\_arn](#input\_salesforce\_credentials\_secret\_arn) | The ARN of an AWS Secrets Manager secret that stores your authentication credentials for your Salesforce instance URL. | `string` | `null` | no |
| <a name="input_seed_urls"></a> [seed\_urls](#input\_seed\_urls) | A list of web urls. | `list(object({ url = string }))` | `[]` | no |
| <a name="input_semantic_buffer_size"></a> [semantic\_buffer\_size](#input\_semantic\_buffer\_size) | The buffer size. | `number` | `null` | no |
| <a name="input_semantic_max_tokens"></a> [semantic\_max\_tokens](#input\_semantic\_max\_tokens) | The maximum number of tokens that a chunk can contain. | `number` | `null` | no |
| <a name="input_serverless_auth_configuration"></a> [serverless\_auth\_configuration](#input\_serverless\_auth\_configuration) | Configuration for the Redshift serverless query engine. | <pre>object({<br/>    type                         = optional(string)<br/>    username_password_secret_arn = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_share_point_credentials_secret_arn"></a> [share\_point\_credentials\_secret\_arn](#input\_share\_point\_credentials\_secret\_arn) | The ARN of an AWS Secrets Manager secret that stores your authentication credentials for your SharePoint site/sites. | `string` | `null` | no |
| <a name="input_share_point_domain"></a> [share\_point\_domain](#input\_share\_point\_domain) | The domain of your SharePoint instance or site URL/URLs. | `string` | `null` | no |
| <a name="input_share_point_site_urls"></a> [share\_point\_site\_urls](#input\_share\_point\_site\_urls) | A list of one or more SharePoint site URLs. | `list(string)` | `[]` | no |
| <a name="input_skip_resource_in_use"></a> [skip\_resource\_in\_use](#input\_skip\_resource\_in\_use) | Specifies whether to allow deleting action group while it is in use. | `bool` | `null` | no |
| <a name="input_sql_kb_workgroup_arn"></a> [sql\_kb\_workgroup\_arn](#input\_sql\_kb\_workgroup\_arn) | The ARN of the existing workgroup. | `string` | `null` | no |
| <a name="input_stop_sequences"></a> [stop\_sequences](#input\_stop\_sequences) | A list of stop sequences. | `list(string)` | `[]` | no |
| <a name="input_supervisor_guardrail_id"></a> [supervisor\_guardrail\_id](#input\_supervisor\_guardrail\_id) | The ID of the guardrail for the supervisor agent. | `string` | `null` | no |
| <a name="input_supervisor_guardrail_version"></a> [supervisor\_guardrail\_version](#input\_supervisor\_guardrail\_version) | The version of the guardrail for the supervisor agent. | `string` | `null` | no |
| <a name="input_supervisor_id"></a> [supervisor\_id](#input\_supervisor\_id) | The ID of the supervisor. | `string` | `null` | no |
| <a name="input_supervisor_idle_session_ttl"></a> [supervisor\_idle\_session\_ttl](#input\_supervisor\_idle\_session\_ttl) | How long sessions should be kept open for the supervisor agent. | `number` | `600` | no |
| <a name="input_supervisor_instruction"></a> [supervisor\_instruction](#input\_supervisor\_instruction) | A narrative instruction to provide the agent as context. | `string` | `""` | no |
| <a name="input_supervisor_kms_key_arn"></a> [supervisor\_kms\_key\_arn](#input\_supervisor\_kms\_key\_arn) | KMS encryption key to use for the supervisor agent. | `string` | `null` | no |
| <a name="input_supervisor_model"></a> [supervisor\_model](#input\_supervisor\_model) | The foundation model for the Bedrock supervisor agent. | `string` | `null` | no |
| <a name="input_supervisor_name"></a> [supervisor\_name](#input\_supervisor\_name) | The name of the supervisor. | `string` | `"TerraformBedrockAgentSupervisor"` | no |
| <a name="input_supplemental_data_s3_uri"></a> [supplemental\_data\_s3\_uri](#input\_supplemental\_data\_s3\_uri) | The S3 URI for supplemental data storage. | `string` | `null` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | The name of the table in the database. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tag bedrock agent resource. | `map(string)` | `null` | no |
| <a name="input_temperature"></a> [temperature](#input\_temperature) | The likelihood of the model selecting higher-probability options while generating a response. | `number` | `0` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The identifier of your Microsoft 365 tenant. | `string` | `null` | no |
| <a name="input_text_field"></a> [text\_field](#input\_text\_field) | The name of the field in which Amazon Bedrock stores the raw text from your data. | `string` | `"AMAZON_BEDROCK_TEXT_CHUNK"` | no |
| <a name="input_text_index_name"></a> [text\_index\_name](#input\_text\_index\_name) | Name of a MongoDB Atlas text index. | `string` | `null` | no |
| <a name="input_top_k"></a> [top\_k](#input\_top\_k) | Sample from the k most likely next tokens. | `number` | `50` | no |
| <a name="input_top_p"></a> [top\_p](#input\_top\_p) | Cumulative probability cutoff for token selection. | `number` | `0.5` | no |
| <a name="input_topics_config"></a> [topics\_config](#input\_topics\_config) | List of topic configs in topic policy | <pre>list(object({<br/>    name       = string<br/>    examples   = list(string)<br/>    type       = string<br/>    definition = string<br/>  }))</pre> | `null` | no |
| <a name="input_transformations_list"></a> [transformations\_list](#input\_transformations\_list) | A list of Lambda functions that process documents. | <pre>list(object({<br/>    step_to_apply = optional(string)<br/>    transformation_function = optional(object({<br/>      transformation_lambda_configuration = optional(object({<br/>        lambda_arn = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_use_aws_provider_alias"></a> [use\_aws\_provider\_alias](#input\_use\_aws\_provider\_alias) | Whether or not to use the aws or awscc provider for the agent alias. Defaults to using the awscc provider. | `bool` | `false` | no |
| <a name="input_use_existing_s3_data_source"></a> [use\_existing\_s3\_data\_source](#input\_use\_existing\_s3\_data\_source) | Whether or not to use an existing S3 data source. | `bool` | `false` | no |
| <a name="input_user_token_configurations"></a> [user\_token\_configurations](#input\_user\_token\_configurations) | List of user token configurations for Kendra. | <pre>list(object({<br/><br/>    json_token_type_configurations = optional(object({<br/>      group_attribute_field     = string<br/>      user_name_attribute_field = string<br/>    }))<br/><br/>    jwt_token_type_configuration = optional(object({<br/>      claim_regex               = optional(string)<br/>      key_location              = optional(string)<br/>      group_attribute_field     = optional(string)<br/>      user_name_attribute_field = optional(string)<br/>      issuer                    = optional(string)<br/>      secret_manager_arn        = optional(string)<br/>      url                       = optional(string)<br/>    }))<br/><br/>  }))</pre> | `null` | no |
| <a name="input_variants_list"></a> [variants\_list](#input\_variants\_list) | List of prompt variants. | <pre>list(object({<br/>    name          = optional(string)<br/>    template_type = optional(string)<br/>    model_id      = optional(string)<br/>    inference_configuration = optional(object({<br/>      text = optional(object({<br/>        max_tokens     = optional(number)<br/>        stop_sequences = optional(list(string))<br/>        temperature    = optional(number)<br/>        top_p          = optional(number)<br/>      }))<br/>    }))<br/><br/>    template_configuration = optional(object({<br/>      text = optional(object({<br/>        input_variables = optional(list(object({ name = optional(string) })))<br/>        text            = optional(string)<br/>        text_s3_location = optional(object({<br/>          bucket  = optional(string)<br/>          key     = optional(string)<br/>          version = optional(string)<br/>        }))<br/>      }))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_vector_dimension"></a> [vector\_dimension](#input\_vector\_dimension) | The dimension of vectors in the OpenSearch index. Use 1024 for Titan Text Embeddings V2, 1536 for V1 | `number` | `1024` | no |
| <a name="input_vector_field"></a> [vector\_field](#input\_vector\_field) | The name of the field where the vector embeddings are stored | `string` | `"bedrock-knowledge-base-default-vector"` | no |
| <a name="input_vector_index_name"></a> [vector\_index\_name](#input\_vector\_index\_name) | The name of the vector index. | `string` | `"bedrock-knowledge-base-default-index"` | no |
| <a name="input_words_config"></a> [words\_config](#input\_words\_config) | List of custom word configs. | `list(map(string))` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#output\_cloudwatch\_log\_group) | The name of the CloudWatch log group for the knowledge base.  If no log group was requested, value will be null |
| <a name="output_datasource_identifier"></a> [datasource\_identifier](#output\_datasource\_identifier) | The unique identifier of the data source. |
| <a name="output_default_collection"></a> [default\_collection](#output\_default\_collection) | Opensearch default collection value. |
| <a name="output_default_kb_identifier"></a> [default\_kb\_identifier](#output\_default\_kb\_identifier) | The unique identifier of the default knowledge base that was created.  If no default KB was requested, value will be null |
| <a name="output_knowledge_base_role_name"></a> [knowledge\_base\_role\_name](#output\_knowledge\_base\_role\_name) | The name of the IAM role used by the knowledge base. |
| <a name="output_mongo_kb_identifier"></a> [mongo\_kb\_identifier](#output\_mongo\_kb\_identifier) | The unique identifier of the MongoDB knowledge base that was created.  If no MongoDB KB was requested, value will be null |
| <a name="output_opensearch_kb_identifier"></a> [opensearch\_kb\_identifier](#output\_opensearch\_kb\_identifier) | The unique identifier of the OpenSearch knowledge base that was created.  If no OpenSearch KB was requested, value will be null |
| <a name="output_pinecone_kb_identifier"></a> [pinecone\_kb\_identifier](#output\_pinecone\_kb\_identifier) | The unique identifier of the Pinecone knowledge base that was created.  If no Pinecone KB was requested, value will be null |
| <a name="output_rds_kb_identifier"></a> [rds\_kb\_identifier](#output\_rds\_kb\_identifier) | The unique identifier of the RDS knowledge base that was created.  If no RDS KB was requested, value will be null |
| <a name="output_s3_data_source_arn"></a> [s3\_data\_source\_arn](#output\_s3\_data\_source\_arn) | The Amazon Bedrock Data Source for S3. |
| <a name="output_s3_data_source_name"></a> [s3\_data\_source\_name](#output\_s3\_data\_source\_name) | The name of the Amazon Bedrock Data Source for S3. |
<!-- END_TF_DOCS -->
