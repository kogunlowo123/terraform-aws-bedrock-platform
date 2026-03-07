# Knowledge Base Submodule

This submodule creates a standalone Amazon Bedrock Knowledge Base with an S3 data source and OpenSearch Serverless vector storage.

## Usage

```hcl
module "knowledge_base" {
  source = "../../modules/knowledge-base"

  name_prefix               = "my-project"
  name                      = "docs-kb"
  description               = "Knowledge base for documentation"
  embedding_model           = "amazon.titan-embed-text-v1"
  s3_data_source_bucket_arn = "arn:aws:s3:::my-docs-bucket"
  opensearch_collection_arn = "arn:aws:aoss:us-east-1:123456789012:collection/abc123"

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| name | Name of the knowledge base | `string` | n/a | yes |
| description | Description of the knowledge base | `string` | n/a | yes |
| embedding_model | Embedding model ID | `string` | n/a | yes |
| s3_data_source_bucket_arn | ARN of the S3 data source bucket | `string` | n/a | yes |
| opensearch_collection_arn | ARN of the OpenSearch collection | `string` | `""` | no |
| vector_index_name | Vector index name | `string` | `"bedrock-knowledge-base-index"` | no |
| chunking_strategy | Chunking strategy | `string` | `"FIXED_SIZE"` | no |
| max_tokens | Max tokens per chunk | `number` | `300` | no |
| overlap_percentage | Overlap percentage | `number` | `20` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| knowledge_base_id | ID of the knowledge base |
| knowledge_base_arn | ARN of the knowledge base |
| data_source_id | ID of the data source |
| role_arn | ARN of the IAM role |
