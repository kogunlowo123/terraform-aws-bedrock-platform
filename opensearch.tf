###############################################################################
# OpenSearch Serverless - Vector Store for Knowledge Bases
###############################################################################

resource "aws_opensearchserverless_collection" "this" {
  count = var.opensearch_collection_name != "" && length(var.knowledge_bases) > 0 ? 1 : 0

  name        = var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"
  description = "Vector store for ${var.name_prefix} Bedrock knowledge bases"
  type        = "VECTORSEARCH"

  tags = var.tags

  depends_on = [
    aws_opensearchserverless_security_policy.encryption,
    aws_opensearchserverless_security_policy.network,
  ]
}

###############################################################################
# Encryption Policy
###############################################################################

resource "aws_opensearchserverless_security_policy" "encryption" {
  count = var.opensearch_collection_name != "" && length(var.knowledge_bases) > 0 ? 1 : 0

  name        = "${var.name_prefix}-encryption"
  type        = "encryption"
  description = "Encryption policy for ${var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"}"

  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/${var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"}"]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = true
  })
}

###############################################################################
# Network Policy
###############################################################################

resource "aws_opensearchserverless_security_policy" "network" {
  count = var.opensearch_collection_name != "" && length(var.knowledge_bases) > 0 ? 1 : 0

  name        = "${var.name_prefix}-network"
  type        = "network"
  description = "Network policy for ${var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"}"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource     = ["collection/${var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"}"]
          ResourceType = "collection"
        },
        {
          Resource     = ["collection/${var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"}"]
          ResourceType = "dashboard"
        }
      ]
      AllowFromPublic = true
    }
  ])
}

###############################################################################
# Access Policy
###############################################################################

resource "aws_opensearchserverless_access_policy" "this" {
  count = var.opensearch_collection_name != "" && length(var.knowledge_bases) > 0 ? 1 : 0

  name        = "${var.name_prefix}-access"
  type        = "data"
  description = "Data access policy for ${var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"}"

  policy = jsonencode([
    {
      Rules = [
        {
          Resource     = ["collection/${var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"}"]
          ResourceType = "collection"
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
        },
        {
          Resource     = ["index/${var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"}/*"]
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
