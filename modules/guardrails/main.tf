# =============================================================================
# Guardrails Submodule
# =============================================================================

resource "aws_bedrock_guardrail" "this" {
  name                      = "${var.name_prefix}-${var.name}"
  description               = var.description
  blocked_input_messaging   = var.blocked_input_messaging
  blocked_outputs_messaging = var.blocked_output_messaging

  dynamic "content_policy_config" {
    for_each = length(var.content_filters) > 0 ? [1] : []

    content {
      dynamic "filters_config" {
        for_each = var.content_filters

        content {
          type            = filters_config.value.type
          input_strength  = filters_config.value.input_strength
          output_strength = filters_config.value.output_strength
        }
      }
    }
  }

  dynamic "topic_policy_config" {
    for_each = length(var.denied_topics) > 0 ? [1] : []

    content {
      dynamic "topics_config" {
        for_each = var.denied_topics

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
    for_each = length(var.sensitive_info_filters) > 0 ? [1] : []

    content {
      dynamic "pii_entities_config" {
        for_each = var.sensitive_info_filters

        content {
          type   = pii_entities_config.value.type
          action = pii_entities_config.value.action
        }
      }
    }
  }

  tags = var.tags
}

resource "aws_bedrock_guardrail_version" "this" {
  guardrail_arn = aws_bedrock_guardrail.this.guardrail_arn
  description   = "Version for guardrail ${var.name}"
}
