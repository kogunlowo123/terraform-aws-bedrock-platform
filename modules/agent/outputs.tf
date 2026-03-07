output "agent_id" {
  description = "ID of the agent."
  value       = aws_bedrockagent_agent.this.agent_id
}

output "agent_arn" {
  description = "ARN of the agent."
  value       = aws_bedrockagent_agent.this.agent_arn
}

output "agent_alias_id" {
  description = "ID of the agent alias."
  value       = aws_bedrockagent_agent_alias.this.agent_alias_id
}

output "role_arn" {
  description = "ARN of the agent IAM role."
  value       = aws_iam_role.this.arn
}
