# =============================================================================
# OpenSearch Serverless - Vector Store for Knowledge Bases
# =============================================================================

resource "aws_opensearchserverless_collection" "this" {
  count = local.create_opensearch ? 1 : 0

  name        = local.opensearch_collection_name
  description = "Vector store for ${var.name_prefix} Bedrock knowledge bases"
  type        = "VECTORSEARCH"

  tags = local.common_tags

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network,
  ]
}

# -----------------------------------------------------------------------------
# Encryption Policy
# -----------------------------------------------------------------------------
resource "aws_opensearchserverless_security_policy" "encryption" {
  count = local.create_opensearch ? 1 : 0

  name        = "${var.name_prefix}-encryption"
  type        = "encryption"
  description = "Encryption policy for ${local.opensearch_collection_name}"

  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/${local.opensearch_collection_name}"]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
  })
}

# -----------------------------------------------------------------------------
# Network Policy
# -----------------------------------------------------------------------------
resource "aws_opensearchserverless_security_policy" "network" {
  count = local.create_opensearch ? 1 : 0

  name        = "${var.name_prefix}-network"
  type        = "network"
  description = "Network policy for ${local.opensearch_collection_name}"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource     = ["collection/${local.opensearch_collection_name}"]
          ResourceType = "collection"
        },
        {
          Resource     = ["collection/${local.opensearch_collection_name}"]
          ResourceType = "dashboard"
        }
      ]
      AllowFromPublic = true
    }
  ])
}

# -----------------------------------------------------------------------------
# Access Policy
# -----------------------------------------------------------------------------
resource "aws_opensearchserverless_access_policy" "this" {
  count = local.create_opensearch ? 1 : 0

  name        = "${var.name_prefix}-access"
  type        = "data"
  description = "Data access policy for ${local.opensearch_collection_name}"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource     = ["collection/${local.opensearch_collection_name}"]
          ResourceType = "collection"
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
        },
        {
          Resource     = ["index/${local.opensearch_collection_name}/*"]
          ResourceType = "index"
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
        }
      ]
      Principal = concat(
        [for key, role in aws_iam_role.knowledge_base : role.arn],
        [data.aws_caller_identity.current.arn]
      )
    }
  ])
}
