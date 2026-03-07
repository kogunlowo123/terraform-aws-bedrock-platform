# =============================================================================
# Agent Submodule
# =============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

resource "aws_iam_role" "this" {
  name = "${var.name_prefix}-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "bedrock" {
  name = "${var.name_prefix}-agent-bedrock-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel"]
        Resource = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${var.foundation_model}"]
      },
      {
        Effect   = "Allow"
        Action   = ["bedrock:Retrieve", "bedrock:RetrieveAndGenerate"]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_bedrockagent_agent" "this" {
  agent_name                  = "${var.name_prefix}-${var.name}"
  description                 = var.description
  agent_resource_role_arn     = aws_iam_role.this.arn
  foundation_model            = var.foundation_model
  instruction                 = var.instruction
  idle_session_ttl_in_seconds = var.idle_session_ttl

  tags = var.tags

  depends_on = [aws_iam_role_policy.bedrock]
}

resource "aws_bedrockagent_agent_action_group" "this" {
  for_each = { for ag in var.action_groups : ag.name => ag }

  action_group_name = each.value.name
  description       = each.value.description
  agent_id          = aws_bedrockagent_agent.this.agent_id
  agent_version     = "DRAFT"

  dynamic "action_group_executor" {
    for_each = each.value.lambda_function_arn != null ? [1] : []

    content {
      lambda = each.value.lambda_function_arn
    }
  }

  dynamic "api_schema" {
    for_each = each.value.api_schema_s3_bucket != null ? [1] : []

    content {
      s3 {
        s3_bucket_name = each.value.api_schema_s3_bucket
        s3_object_key  = each.value.api_schema_s3_key
      }
    }
  }

  dynamic "api_schema" {
    for_each = each.value.api_schema_payload != null && each.value.api_schema_s3_bucket == null ? [1] : []

    content {
      payload = each.value.api_schema_payload
    }
  }
}

resource "aws_bedrockagent_agent_alias" "this" {
  agent_alias_name = "${var.name}-latest"
  agent_id         = aws_bedrockagent_agent.this.agent_id
  description      = "Latest alias for agent ${var.name}"

  tags = var.tags
}
