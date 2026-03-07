variable "name_prefix" {
  description = "Prefix to apply to all resource names for namespacing."
  type        = string
}

variable "enable_model_invocation_logging" {
  description = "Whether to enable model invocation logging to S3."
  type        = bool
  default     = true
}

variable "log_s3_bucket_arn" {
  description = "ARN of the S3 bucket for model invocation logs."
  type        = string
  default     = ""
}

variable "knowledge_bases" {
  description = "Map of knowledge base configurations to create."
  type = map(object({
    name                     = string
    description              = string
    embedding_model          = string
    s3_data_source_bucket_arn = string
    chunking_strategy        = optional(string, "FIXED_SIZE")
    max_tokens               = optional(number, 300)
    overlap_percentage       = optional(number, 20)
  }))
  default = {}
}

variable "agents" {
  description = "Map of agent configurations to create."
  type = map(object({
    name               = string
    description        = string
    foundation_model   = string
    instruction        = string
    idle_session_ttl   = optional(number, 600)
    action_groups = optional(list(object({
      name                  = string
      description           = string
      api_schema_s3_bucket  = optional(string)
      api_schema_s3_key     = optional(string)
      api_schema_payload    = optional(string)
      lambda_function_arn   = optional(string)
    })), [])
  }))
  default = {}
}

variable "guardrails" {
  description = "Map of guardrail configurations to create."
  type = map(object({
    name                      = string
    description               = string
    blocked_input_messaging   = string
    blocked_output_messaging  = string
    content_filters = optional(list(object({
      type                  = string
      input_strength        = string
      output_strength       = string
    })), [])
    denied_topics = optional(list(object({
      name       = string
      definition = string
      examples   = optional(list(string), [])
    })), [])
    sensitive_info_filters = optional(list(object({
      type   = string
      action = string
    })), [])
  }))
  default = {}
}

variable "opensearch_collection_name" {
  description = "Name of the OpenSearch Serverless collection for vector storage."
  type        = string
  default     = ""
}

variable "opensearch_vector_index_name" {
  description = "Name of the vector index within the OpenSearch Serverless collection."
  type        = string
  default     = "bedrock-knowledge-base-index"
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
