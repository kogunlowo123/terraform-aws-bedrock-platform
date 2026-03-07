# =============================================================================
# Advanced Example - Multiple Knowledge Bases, Agents, and Guardrails
# =============================================================================

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "product_docs" {
  bucket = "adv-bedrock-product-docs"
}

resource "aws_s3_bucket" "support_docs" {
  bucket = "adv-bedrock-support-docs"
}

resource "aws_s3_bucket" "logs" {
  bucket = "adv-bedrock-logs"
}

module "bedrock_platform" {
  source = "../../"

  name_prefix       = "advanced-example"
  log_s3_bucket_arn = aws_s3_bucket.logs.arn

  knowledge_bases = {
    product = {
      name                      = "product-docs"
      description               = "Product documentation knowledge base"
      embedding_model           = "amazon.titan-embed-text-v1"
      s3_data_source_bucket_arn = aws_s3_bucket.product_docs.arn
      chunking_strategy         = "FIXED_SIZE"
      max_tokens                = 500
      overlap_percentage        = 15
    }
    support = {
      name                      = "support-articles"
      description               = "Support articles knowledge base"
      embedding_model           = "amazon.titan-embed-text-v2:0"
      s3_data_source_bucket_arn = aws_s3_bucket.support_docs.arn
      chunking_strategy         = "FIXED_SIZE"
      max_tokens                = 300
      overlap_percentage        = 20
    }
  }

  agents = {
    product_expert = {
      name             = "product-expert"
      description      = "Product expert agent"
      foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
      instruction      = "You are a product expert. Use the knowledge base to answer product questions accurately."
      idle_session_ttl = 900
    }
    support_agent = {
      name             = "support-agent"
      description      = "Customer support agent"
      foundation_model = "anthropic.claude-3-haiku-20240307-v1:0"
      instruction      = "You are a customer support agent. Help resolve customer issues using support documentation."
      idle_session_ttl = 600
      action_groups = [
        {
          name                = "ticket-management"
          description         = "Create and manage support tickets"
          lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:ticket-manager"
        }
      ]
    }
  }

  guardrails = {
    safety = {
      name                     = "safety-guardrail"
      description              = "Content safety guardrail"
      blocked_input_messaging  = "Your request could not be processed due to safety policy."
      blocked_output_messaging = "The response was filtered due to safety policy."
      content_filters = [
        {
          type            = "SEXUAL"
          input_strength  = "HIGH"
          output_strength = "HIGH"
        },
        {
          type            = "VIOLENCE"
          input_strength  = "HIGH"
          output_strength = "HIGH"
        },
        {
          type            = "HATE"
          input_strength  = "HIGH"
          output_strength = "HIGH"
        }
      ]
      denied_topics = [
        {
          name       = "competitor-comparison"
          definition = "Comparing our products negatively against competitors"
          examples   = ["Why is competitor X better?", "What are your product weaknesses?"]
        }
      ]
      sensitive_info_filters = [
        {
          type   = "EMAIL"
          action = "ANONYMIZE"
        },
        {
          type   = "PHONE"
          action = "ANONYMIZE"
        }
      ]
    }
  }

  opensearch_collection_name = "adv-vectors"

  tags = {
    Environment = "staging"
    Example     = "advanced"
  }
}
