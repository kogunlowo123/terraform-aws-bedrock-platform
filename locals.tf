locals {
  create_opensearch       = var.opensearch_collection_name != "" && length(var.knowledge_bases) > 0
  opensearch_collection_name = var.opensearch_collection_name != "" ? var.opensearch_collection_name : "${var.name_prefix}-bedrock-vectors"

  common_tags = merge(var.tags, {
    ManagedBy = "terraform"
    Module    = "terraform-aws-bedrock-platform"
  })

  # Flatten action groups across agents for resource creation
  agent_action_groups = flatten([
    for agent_key, agent in var.agents : [
      for ag in agent.action_groups : {
        agent_key   = agent_key
        agent_name  = agent.name
        action_group = ag
      }
    ]
  ])
}
