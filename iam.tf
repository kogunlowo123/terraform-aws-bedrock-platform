###############################################################################
# IAM Role for Bedrock Knowledge Base
###############################################################################

resource "aws_iam_role" "knowledge_base" {
  for_each = var.knowledge_bases

  name = "${var.name_prefix}-kb-${each.key}-role"

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

resource "aws_iam_role_policy" "knowledge_base_s3" {
  for_each = var.knowledge_bases

  name = "${var.name_prefix}-kb-${each.key}-s3-policy"
  role = aws_iam_role.knowledge_base[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          each.value.s3_data_source_bucket_arn,
          "${each.value.s3_data_source_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "knowledge_base_bedrock" {
  for_each = var.knowledge_bases

  name = "${var.name_prefix}-kb-${each.key}-bedrock-policy"
  role = aws_iam_role.knowledge_base[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${each.value.embedding_model}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "knowledge_base_opensearch" {
  for_each = var.opensearch_collection_name != "" && length(var.knowledge_bases) > 0 ? var.knowledge_bases : {}

  name = "${var.name_prefix}-kb-${each.key}-opensearch-policy"
  role = aws_iam_role.knowledge_base[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aoss:APIAccessAll"
        ]
        Resource = [
          aws_opensearchserverless_collection.this[0].arn
        ]
      }
    ]
  })
}

###############################################################################
# IAM Role for Bedrock Agent
###############################################################################

resource "aws_iam_role" "agent" {
  for_each = var.agents

  name = "${var.name_prefix}-agent-${each.key}-role"

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

resource "aws_iam_role_policy" "agent_bedrock" {
  for_each = var.agents

  name = "${var.name_prefix}-agent-${each.key}-bedrock-policy"
  role = aws_iam_role.agent[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${each.value.foundation_model}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "agent_kb" {
  for_each = var.agents

  name = "${var.name_prefix}-agent-${each.key}-kb-policy"
  role = aws_iam_role.agent[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:Retrieve",
          "bedrock:RetrieveAndGenerate"
        ]
        Resource = ["*"]
      }
    ]
  })
}

###############################################################################
# IAM Role for Bedrock Model Invocation Logging
###############################################################################

resource "aws_iam_role" "logging" {
  count = var.enable_model_invocation_logging ? 1 : 0

  name = "${var.name_prefix}-bedrock-logging-role"

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

resource "aws_iam_role_policy" "logging_s3" {
  count = var.enable_model_invocation_logging ? 1 : 0

  name = "${var.name_prefix}-bedrock-logging-s3-policy"
  role = aws_iam_role.logging[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          var.log_s3_bucket_arn,
          "${var.log_s3_bucket_arn}/*"
        ]
      }
    ]
  })
}
