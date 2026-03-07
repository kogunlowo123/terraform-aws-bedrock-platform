output "knowledge_base_id" {
  description = "ID of the knowledge base."
  value       = aws_bedrockagent_knowledge_base.this.id
}

output "knowledge_base_arn" {
  description = "ARN of the knowledge base."
  value       = aws_bedrockagent_knowledge_base.this.arn
}

output "data_source_id" {
  description = "ID of the data source."
  value       = aws_bedrockagent_data_source.this.data_source_id
}

output "role_arn" {
  description = "ARN of the knowledge base IAM role."
  value       = aws_iam_role.this.arn
}
