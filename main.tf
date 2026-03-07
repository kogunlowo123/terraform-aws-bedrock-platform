# =============================================================================
# Amazon Bedrock Platform - Main Resources
# =============================================================================

# -----------------------------------------------------------------------------
# Model Invocation Logging
# -----------------------------------------------------------------------------
resource "aws_bedrock_model_invocation_logging_configuration" "this" {
  count = var.enable_model_invocation_logging ? 1 : 0

  logging_config {
    embedding_data_delivery_enabled = true

    s3_config {
      bucket_name = replace(replace(var.log_s3_bucket_arn, "arn:aws:s3:::", ""), "arn:aws-us-gov:s3:::", "")
    }
  }
}

# -----------------------------------------------------------------------------
# Knowledge Bases
# -----------------------------------------------------------------------------
resource "aws_bedrockagent_knowledge_base" "this" {
  for_each = var.knowledge_bases

  name        = "${var.name_prefix}-${each.value.name}"
  description = each.value.description
  role_arn    = aws_iam_role.knowledge_base[each.key].arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${each.value.embedding_model}"
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"

    opensearch_serverless_configuration {
      collection_arn    = local.create_opensearch ? aws_opensearchserverless_collection.this[0].arn : ""
      vector_index_name = var.opensearch_vector_index_name

      field_mapping {
        vector_field   = "embedding"
        text_field     = "text"
        metadata_field = "metadata"
      }
    }
  }

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy.knowledge_base_s3,
    aws_iam_role_policy.knowledge_base_bedrock,
    aws_iam_role_policy.knowledge_base_opensearch,
    aws_opensearchserverless_access_policy.this,
  ]
}

resource "aws_bedrockagent_data_source" "this" {
  for_each = var.knowledge_bases

  name                 = "${var.name_prefix}-${each.value.name}-ds"
  knowledge_base_id    = aws_bedrockagent_knowledge_base.this[each.key].id

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = each.value.s3_data_source_bucket_arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = each.value.chunking_strategy

      dynamic "fixed_size_chunking_configuration" {
        for_each = each.value.chunking_strategy == "FIXED_SIZE" ? [1] : []

        content {
          max_tokens         = each.value.max_tokens
          overlap_percentage = each.value.overlap_percentage
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Agents
# -----------------------------------------------------------------------------
resource "aws_bedrockagent_agent" "this" {
  for_each = var.agents

  agent_name              = "${var.name_prefix}-${each.value.name}"
  description             = each.value.description
  agent_resource_role_arn  = aws_iam_role.agent[each.key].arn
  foundation_model        = each.value.foundation_model
  instruction             = each.value.instruction
  idle_session_ttl_in_seconds = each.value.idle_session_ttl

  tags = local.common_tags

  depends_on = [
    aws_iam_role_policy.agent_bedrock,
    aws_iam_role_policy.agent_kb,
  ]
}

resource "aws_bedrockagent_agent_action_group" "this" {
  for_each = {
    for ag in local.agent_action_groups :
    "${ag.agent_key}-${ag.action_group.name}" => ag
  }

  action_group_name          = each.value.action_group.name
  description                = each.value.action_group.description
  agent_id                   = aws_bedrockagent_agent.this[each.value.agent_key].agent_id
  agent_version              = "DRAFT"

  dynamic "action_group_executor" {
    for_each = each.value.action_group.lambda_function_arn != null ? [1] : []

    content {
      lambda = each.value.action_group.lambda_function_arn
    }
  }

  dynamic "api_schema" {
    for_each = each.value.action_group.api_schema_s3_bucket != null ? [1] : []

    content {
      s3 {
        s3_bucket_name = each.value.action_group.api_schema_s3_bucket
        s3_object_key  = each.value.action_group.api_schema_s3_key
      }
    }
  }

  dynamic "api_schema" {
    for_each = each.value.action_group.api_schema_payload != null && each.value.action_group.api_schema_s3_bucket == null ? [1] : []

    content {
      payload = each.value.action_group.api_schema_payload
    }
  }
}

resource "aws_bedrockagent_agent_alias" "this" {
  for_each = var.agents

  agent_alias_name = "${each.value.name}-latest"
  agent_id         = aws_bedrockagent_agent.this[each.key].agent_id
  description      = "Latest alias for agent ${each.value.name}"

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Guardrails
# -----------------------------------------------------------------------------
resource "aws_bedrock_guardrail" "this" {
  for_each = var.guardrails

  name                      = "${var.name_prefix}-${each.value.name}"
  description               = each.value.description
  blocked_input_messaging   = each.value.blocked_input_messaging
  blocked_outputs_messaging = each.value.blocked_output_messaging

  dynamic "content_policy_config" {
    for_each = length(each.value.content_filters) > 0 ? [1] : []

    content {
      dynamic "filters_config" {
        for_each = each.value.content_filters

        content {
          type            = filters_config.value.type
          input_strength  = filters_config.value.input_strength
          output_strength = filters_config.value.output_strength
        }
      }
    }
  }

  dynamic "topic_policy_config" {
    for_each = length(each.value.denied_topics) > 0 ? [1] : []

    content {
      dynamic "topics_config" {
        for_each = each.value.denied_topics

        content {
          name       = topics_config.value.name
          definition = topics_config.value.definition
          examples   = topics_config.value.examples
          type       = "DENY"
        }
      }
    }
  }

  dynamic "sensitive_information_policy_config" {
    for_each = length(each.value.sensitive_info_filters) > 0 ? [1] : []

    content {
      dynamic "pii_entities_config" {
        for_each = each.value.sensitive_info_filters

        content {
          type   = pii_entities_config.value.type
          action = pii_entities_config.value.action
        }
      }
    }
  }

  tags = local.common_tags
}

resource "aws_bedrock_guardrail_version" "this" {
  for_each = var.guardrails

  guardrail_arn = aws_bedrock_guardrail.this[each.key].guardrail_arn
  description   = "Version for guardrail ${each.value.name}"
}
