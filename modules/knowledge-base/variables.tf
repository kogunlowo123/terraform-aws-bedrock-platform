variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "name" {
  description = "Name of the knowledge base."
  type        = string
}

variable "description" {
  description = "Description of the knowledge base."
  type        = string
}

variable "embedding_model" {
  description = "Embedding model ID (e.g., amazon.titan-embed-text-v1)."
  type        = string
}

variable "s3_data_source_bucket_arn" {
  description = "ARN of the S3 bucket containing the data source documents."
  type        = string
}

variable "opensearch_collection_arn" {
  description = "ARN of the OpenSearch Serverless collection."
  type        = string
  default     = ""
}

variable "vector_index_name" {
  description = "Name of the vector index in OpenSearch."
  type        = string
  default     = "bedrock-knowledge-base-index"
}

variable "chunking_strategy" {
  description = "Chunking strategy for document ingestion."
  type        = string
  default     = "FIXED_SIZE"
}

variable "max_tokens" {
  description = "Maximum number of tokens per chunk."
  type        = number
  default     = 300
}

variable "overlap_percentage" {
  description = "Overlap percentage between chunks."
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
