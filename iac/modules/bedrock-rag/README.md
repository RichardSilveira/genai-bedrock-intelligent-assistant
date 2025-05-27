# OpenSearch Index Configuration for Bedrock Knowledge Base

The OpenSearch index configuration is critical for proper functioning of the Bedrock Knowledge Base. Below are key concepts and fields used in the index mapping:

## OpenSearch Troubleshooting Commands

These commands are useful for troubleshooting and inspecting OpenSearch Serverless collections used with Bedrock Knowledge Bases.

> OpenSearch Serverless has a more limited API compared to standard OpenSearch

First, set up environment variables for your collection endpoint and index name:

```bash

COLLECTION_NAME="bedrock-knowledge-base-tf14ti"
REGION="us-east-2"
ENDPOINT="https://3zrez7aygv9volzq0p8e.us-east-2.aoss.amazonaws.com"

# Set the index name

# Get the collection endpoint URL
COLLECTION_NAME="chatbot-dev-kb"
REGION="us-east-2"
ENDPOINT="https://nzs6tg1uotjvpdu90aqk.us-east-2.aoss.amazonaws.com"

# Set the index name
INDEX_NAME="bedrock-knowledge-base-default-index"
```

### List All Indices in a Collection

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/_cat/indices?v"
```

### Get Index Mapping

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/${INDEX_NAME}/_mapping"
```

### Query Documents in an Index

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/${INDEX_NAME}/_search" \
  -H "Content-Type: application/json" \
  -d '{"query": {"match_all": {}}, "size": 10}'
```

### Create an Index

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X PUT "${ENDPOINT}/${INDEX_NAME}" \
  -H "Content-Type: application/json" \
  -d @modules/bedrock-rag/index-mapping.json -v
```

### Delete an Index

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X DELETE "${ENDPOINT}/${INDEX_NAME}"
```

### Get Collection Health

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/_health"
```

### Get Collection Stats

```bash
awscurl --service aoss \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X GET "${ENDPOINT}/${INDEX_NAME}/_stats"
```

### Testing the Knowledge Base

```bash
awscurl --service bedrock \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"input":{"text":"hey"},"retrieveAndGenerateConfiguration":{"knowledgeBaseConfiguration":{"generationConfiguration":{"inferenceConfig":{"textInferenceConfig":{"maxTokens":512,"stopSequences":[],"temperature":0,"topP":0.9}}},"knowledgeBaseId":"VMT8T5QJ0M","modelArn":"arn:aws:bedrock:us-east-2:103881053461:inference-profile/us.amazon.nova-micro-v1:0","orchestrationConfiguration":{"inferenceConfig":{"textInferenceConfig":{"maxTokens":512,"stopSequences":[],"temperature":0,"topP":0.9}}},"retrievalConfiguration":{"vectorSearchConfiguration":{"numberOfResults":5}}},"type":"KNOWLEDGE_BASE"}}' \
  https://bedrock-agent-runtime.us-east-2.amazonaws.com/retrieveAndGenerate


  awscurl --service bedrock \
  --region ${REGION} \
  --access_key $AWS_ACCESS_KEY_ID \
  --secret_key $AWS_SECRET_ACCESS_KEY \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"input":{"text":"hey"},"retrieveAndGenerateConfiguration":{"knowledgeBaseConfiguration":{"generationConfiguration":{"inferenceConfig":{"textInferenceConfig":{"maxTokens":512,"stopSequences":[],"temperature":0,"topP":0.9}}},"knowledgeBaseId":"UWSHTYLI8J","modelArn":"arn:aws:bedrock:us-east-2:103881053461:inference-profile/us.amazon.nova-micro-v1:0","orchestrationConfiguration":{"inferenceConfig":{"textInferenceConfig":{"maxTokens":512,"stopSequences":[],"temperature":0,"topP":0.9}}},"retrievalConfiguration":{"vectorSearchConfiguration":{"numberOfResults":5}}},"type":"KNOWLEDGE_BASE"}}' \
  https://bedrock-agent-runtime.us-east-2.amazonaws.com/retrieveAndGenerate
```

## Key Fields and Their Purpose

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

## Dynamic Templates

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

## Vector Configuration

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

## Text Field with Keyword Subfields

Many fields use this pattern:
```json
"type": "text",
"fields": {
    "keyword": {
        "type": "keyword"
    }
}
```

This dual mapping allows both:
- Full-text search within the content (text field)
- Exact matching, sorting, and aggregations (keyword subfield)

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_bedrock_model_invocation_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_model_invocation_logging_configuration) | resource |
| [aws_bedrockagent_data_source.bedrock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source) | resource |
| [aws_bedrockagent_knowledge_base.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base) | resource |
| [aws_cloudwatch_log_group.bedrock_kb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.bedrock_model_invocation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.bedrock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.bedrock_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.bedrock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.bedrock_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_opensearchserverless_access_policy.data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [aws_opensearchserverless_collection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_collection) | resource |
| [aws_opensearchserverless_security_policy.encryption](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_opensearchserverless_security_policy.network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_s3_bucket.kb_documents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.kb_documents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [null_resource.create_opensearch_index](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_after_index_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ci_principal_arn"></a> [ci\_principal\_arn](#input\_ci\_principal\_arn) | ARNs of the CI/CD principal (users or role) that need to create the OpenSearch index | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resource names | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bedrock_role_arn"></a> [bedrock\_role\_arn](#output\_bedrock\_role\_arn) | ARN of the IAM role for Bedrock |
| <a name="output_kb_documents_bucket_arn"></a> [kb\_documents\_bucket\_arn](#output\_kb\_documents\_bucket\_arn) | Name of the S3 bucket storing knowledge base documents |
| <a name="output_kb_opensearch_collection_arn"></a> [kb\_opensearch\_collection\_arn](#output\_kb\_opensearch\_collection\_arn) | ID of the OpenSearch Serverless collection for knowledge base |
| <a name="output_knowledge_base_id"></a> [knowledge\_base\_id](#output\_knowledge\_base\_id) | ID of the Bedrock Knowledge Base |
<!-- END_TF_DOCS -->
