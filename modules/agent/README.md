# Agent Submodule

This submodule creates a standalone Amazon Bedrock Agent with optional action groups and an alias.

## Usage

```hcl
module "agent" {
  source = "../../modules/agent"

  name_prefix      = "my-project"
  name             = "support-agent"
  description      = "Customer support agent"
  foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
  instruction      = "You are a helpful customer support agent."

  action_groups = [
    {
      name                = "lookup-order"
      description         = "Look up order details"
      lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:lookup-order"
    }
  ]

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| name | Name of the agent | `string` | n/a | yes |
| description | Description of the agent | `string` | n/a | yes |
| foundation_model | Foundation model ID | `string` | n/a | yes |
| instruction | Instruction prompt | `string` | n/a | yes |
| idle_session_ttl | Idle session TTL in seconds | `number` | `600` | no |
| action_groups | Action group configurations | `list(object)` | `[]` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| agent_id | ID of the agent |
| agent_arn | ARN of the agent |
| agent_alias_id | ID of the agent alias |
| role_arn | ARN of the IAM role |
