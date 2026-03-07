# =============================================================================
# Knowledge Base Submodule
# =============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

resource "aws_iam_role" "this" {
  name = "${var.name_prefix}-kb-role"

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

resource "aws_iam_role_policy" "s3" {
  name = "${var.name_prefix}-kb-s3-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:ListBucket"]
        Resource = [
          var.s3_data_source_bucket_arn,
          "${var.s3_data_source_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock" {
  name = "${var.name_prefix}-kb-bedrock-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:InvokeModel"]
        Resource = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model}"]
      }
    ]
  })
}

resource "aws_iam_role_policy" "opensearch" {
  count = var.opensearch_collection_arn != "" ? 1 : 0

  name = "${var.name_prefix}-kb-opensearch-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["aoss:APIAccessAll"]
        Resource = [var.opensearch_collection_arn]
      }
    ]
  })
}

resource "aws_bedrockagent_knowledge_base" "this" {
  name        = "${var.name_prefix}-${var.name}"
  description = var.description
  role_arn    = aws_iam_role.this.arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model}"
    }
  }

  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"

    opensearch_serverless_configuration {
      collection_arn    = var.opensearch_collection_arn
      vector_index_name = var.vector_index_name

      field_mapping {
        vector_field   = "embedding"
        text_field     = "text"
        metadata_field = "metadata"
      }
    }
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy.s3,
    aws_iam_role_policy.bedrock,
    aws_iam_role_policy.opensearch,
  ]
}

resource "aws_bedrockagent_data_source" "this" {
  name              = "${var.name_prefix}-${var.name}-ds"
  knowledge_base_id = aws_bedrockagent_knowledge_base.this.id

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = var.s3_data_source_bucket_arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = var.chunking_strategy

      dynamic "fixed_size_chunking_configuration" {
        for_each = var.chunking_strategy == "FIXED_SIZE" ? [1] : []

        content {
          max_tokens         = var.max_tokens
          overlap_percentage = var.overlap_percentage
        }
      }
    }
  }
}
