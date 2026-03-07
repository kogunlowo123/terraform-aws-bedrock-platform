# =============================================================================
# Basic Example - Single Knowledge Base and Agent
# =============================================================================

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "docs" {
  bucket = "my-bedrock-docs-bucket"
}

resource "aws_s3_bucket" "logs" {
  bucket = "my-bedrock-logs-bucket"
}

module "bedrock_platform" {
  source = "../../"

  name_prefix        = "basic-example"
  log_s3_bucket_arn  = aws_s3_bucket.logs.arn

  knowledge_bases = {
    docs = {
      name                      = "documentation"
      description               = "Documentation knowledge base"
      embedding_model           = "amazon.titan-embed-text-v1"
      s3_data_source_bucket_arn = aws_s3_bucket.docs.arn
    }
  }

  agents = {
    assistant = {
      name             = "assistant"
      description      = "General assistant agent"
      foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
      instruction      = "You are a helpful assistant that answers questions using the knowledge base."
    }
  }

  opensearch_collection_name = "basic-vectors"

  tags = {
    Environment = "dev"
    Example     = "basic"
  }
}

output "knowledge_base_ids" {
  value = module.bedrock_platform.knowledge_base_ids
}

output "agent_ids" {
  value = module.bedrock_platform.agent_ids
}
