output "knowledge_base_ids" {
  description = "Map of knowledge base keys to their IDs"
  value       = { for k, v in aws_bedrockagent_knowledge_base.this : k => v.id }
}

output "knowledge_base_arns" {
  description = "Map of knowledge base keys to their ARNs"
  value       = { for k, v in aws_bedrockagent_knowledge_base.this : k => v.arn }
}

output "data_source_ids" {
  description = "Map of data source keys to their IDs"
  value       = { for k, v in aws_bedrockagent_data_source.this : k => v.data_source_id }
}

output "agent_ids" {
  description = "Map of agent keys to their IDs"
  value       = { for k, v in aws_bedrockagent_agent.this : k => v.agent_id }
}

output "agent_arns" {
  description = "Map of agent keys to their ARNs"
  value       = { for k, v in aws_bedrockagent_agent.this : k => v.agent_arn }
}

output "agent_alias_ids" {
  description = "Map of agent keys to their latest alias IDs"
  value       = { for k, v in aws_bedrockagent_agent_alias.this : k => v.agent_alias_id }
}

output "guardrail_ids" {
  description = "Map of guardrail keys to their IDs"
  value       = { for k, v in aws_bedrock_guardrail.this : k => v.guardrail_id }
}

output "guardrail_arns" {
  description = "Map of guardrail keys to their ARNs"
  value       = { for k, v in aws_bedrock_guardrail.this : k => v.guardrail_arn }
}

output "guardrail_version_ids" {
  description = "Map of guardrail keys to their version numbers"
  value       = { for k, v in aws_bedrock_guardrail_version.this : k => v.version }
}

output "opensearch_collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = var.opensearch_collection_name != "" && length(var.knowledge_bases) > 0 ? aws_opensearchserverless_collection.this[0].arn : null
}

output "opensearch_collection_endpoint" {
  description = "Endpoint of the OpenSearch Serverless collection"
  value       = var.opensearch_collection_name != "" && length(var.knowledge_bases) > 0 ? aws_opensearchserverless_collection.this[0].collection_endpoint : null
}

output "opensearch_dashboard_endpoint" {
  description = "Dashboard endpoint of the OpenSearch Serverless collection"
  value       = var.opensearch_collection_name != "" && length(var.knowledge_bases) > 0 ? aws_opensearchserverless_collection.this[0].dashboard_endpoint : null
}

output "knowledge_base_role_arns" {
  description = "Map of knowledge base keys to their IAM role ARNs"
  value       = { for k, v in aws_iam_role.knowledge_base : k => v.arn }
}

output "agent_role_arns" {
  description = "Map of agent keys to their IAM role ARNs"
  value       = { for k, v in aws_iam_role.agent : k => v.arn }
}

output "logging_role_arn" {
  description = "ARN of the model invocation logging IAM role"
  value       = var.enable_model_invocation_logging ? aws_iam_role.logging[0].arn : null
}
