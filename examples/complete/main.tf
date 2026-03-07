# =============================================================================
# Complete Example - Full Platform with All Features
# =============================================================================

provider "aws" {
  region = "us-east-1"
}

# -----------------------------------------------------------------------------
# S3 Buckets for Data Sources and Logging
# -----------------------------------------------------------------------------
resource "aws_s3_bucket" "engineering_docs" {
  bucket = "complete-bedrock-eng-docs"
}

resource "aws_s3_bucket" "hr_docs" {
  bucket = "complete-bedrock-hr-docs"
}

resource "aws_s3_bucket" "api_specs" {
  bucket = "complete-bedrock-api-specs"
}

resource "aws_s3_bucket" "logs" {
  bucket = "complete-bedrock-invocation-logs"
}

# -----------------------------------------------------------------------------
# Bedrock Platform Module
# -----------------------------------------------------------------------------
module "bedrock_platform" {
  source = "../../"

  name_prefix                    = "complete-platform"
  enable_model_invocation_logging = true
  log_s3_bucket_arn              = aws_s3_bucket.logs.arn

  # --- Knowledge Bases ---
  knowledge_bases = {
    engineering = {
      name                      = "engineering-docs"
      description               = "Engineering documentation and runbooks"
      embedding_model           = "amazon.titan-embed-text-v2:0"
      s3_data_source_bucket_arn = aws_s3_bucket.engineering_docs.arn
      chunking_strategy         = "FIXED_SIZE"
      max_tokens                = 512
      overlap_percentage        = 10
    }
    hr = {
      name                      = "hr-policies"
      description               = "HR policies and employee handbook"
      embedding_model           = "amazon.titan-embed-text-v1"
      s3_data_source_bucket_arn = aws_s3_bucket.hr_docs.arn
      chunking_strategy         = "FIXED_SIZE"
      max_tokens                = 300
      overlap_percentage        = 20
    }
    api = {
      name                      = "api-reference"
      description               = "API reference documentation"
      embedding_model           = "amazon.titan-embed-text-v2:0"
      s3_data_source_bucket_arn = aws_s3_bucket.api_specs.arn
      chunking_strategy         = "NONE"
    }
  }

  # --- Agents ---
  agents = {
    devops = {
      name             = "devops-assistant"
      description      = "DevOps assistant for engineering questions"
      foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
      instruction      = "You are a DevOps assistant. Help engineers with infrastructure, deployment, and operational questions using the engineering knowledge base."
      idle_session_ttl = 1200
      action_groups = [
        {
          name                = "incident-management"
          description         = "Create and manage incidents"
          lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:incident-manager"
        },
        {
          name                = "deployment-status"
          description         = "Check deployment status"
          lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:deployment-checker"
        }
      ]
    }
    hr_bot = {
      name             = "hr-assistant"
      description      = "HR policy assistant"
      foundation_model = "anthropic.claude-3-haiku-20240307-v1:0"
      instruction      = "You are an HR assistant. Answer employee questions about company policies, benefits, and procedures using the HR knowledge base. Never provide legal advice."
      idle_session_ttl = 600
    }
    api_helper = {
      name             = "api-helper"
      description      = "API documentation helper"
      foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
      instruction      = "You are an API documentation helper. Assist developers in understanding API endpoints, request/response formats, and integration patterns."
      idle_session_ttl = 900
    }
  }

  # --- Guardrails ---
  guardrails = {
    general_safety = {
      name                     = "general-safety"
      description              = "General content safety guardrail"
      blocked_input_messaging  = "Your input was blocked. Please rephrase your request."
      blocked_output_messaging = "The response was filtered by our content policy."
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
        },
        {
          type            = "INSULTS"
          input_strength  = "MEDIUM"
          output_strength = "HIGH"
        }
      ]
      denied_topics = [
        {
          name       = "legal-advice"
          definition = "Providing specific legal advice or legal opinions"
          examples   = ["Can I sue my employer?", "Is this contract legally binding?"]
        },
        {
          name       = "medical-advice"
          definition = "Providing specific medical diagnoses or treatment recommendations"
          examples   = ["What medication should I take?", "Do I have this disease?"]
        }
      ]
      sensitive_info_filters = [
        { type = "EMAIL", action = "ANONYMIZE" },
        { type = "PHONE", action = "ANONYMIZE" },
        { type = "US_SOCIAL_SECURITY_NUMBER", action = "BLOCK" },
        { type = "CREDIT_DEBIT_CARD_NUMBER", action = "BLOCK" }
      ]
    }
    hr_guardrail = {
      name                     = "hr-guardrail"
      description              = "HR-specific guardrail"
      blocked_input_messaging  = "This question cannot be answered by the HR assistant."
      blocked_output_messaging = "The HR assistant cannot provide this type of response."
      content_filters = [
        {
          type            = "HATE"
          input_strength  = "HIGH"
          output_strength = "HIGH"
        }
      ]
      denied_topics = [
        {
          name       = "salary-negotiation"
          definition = "Advice on how to negotiate individual salary or compensation"
          examples   = ["How do I ask for a raise?", "What salary should I negotiate?"]
        }
      ]
    }
  }

  opensearch_collection_name = "complete-vectors"

  tags = {
    Environment = "production"
    Team        = "platform"
    Example     = "complete"
  }
}

# -----------------------------------------------------------------------------
# Outputs
# -----------------------------------------------------------------------------
output "knowledge_base_ids" {
  value = module.bedrock_platform.knowledge_base_ids
}

output "agent_ids" {
  value = module.bedrock_platform.agent_ids
}

output "guardrail_ids" {
  value = module.bedrock_platform.guardrail_ids
}

output "opensearch_endpoint" {
  value = module.bedrock_platform.opensearch_collection_endpoint
}
