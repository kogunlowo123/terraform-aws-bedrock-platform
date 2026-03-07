# Guardrails Submodule

This submodule creates a standalone Amazon Bedrock Guardrail with content filters, denied topics, and sensitive information filters.

## Usage

```hcl
module "guardrail" {
  source = "../../modules/guardrails"

  name_prefix              = "my-project"
  name                     = "safety-guardrail"
  description              = "Safety guardrail for production"
  blocked_input_messaging  = "Your input was blocked by our safety policy."
  blocked_output_messaging = "The response was blocked by our safety policy."

  content_filters = [
    {
      type            = "SEXUAL"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    },
    {
      type            = "VIOLENCE"
      input_strength  = "HIGH"
      output_strength = "HIGH"
    }
  ]

  denied_topics = [
    {
      name       = "financial-advice"
      definition = "Providing specific financial or investment advice"
      examples   = ["Should I buy this stock?", "What should I invest in?"]
    }
  ]

  sensitive_info_filters = [
    {
      type   = "EMAIL"
      action = "ANONYMIZE"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name_prefix | Prefix for resource names | `string` | n/a | yes |
| name | Name of the guardrail | `string` | n/a | yes |
| description | Description of the guardrail | `string` | n/a | yes |
| blocked_input_messaging | Message for blocked input | `string` | n/a | yes |
| blocked_output_messaging | Message for blocked output | `string` | n/a | yes |
| content_filters | Content filter configurations | `list(object)` | `[]` | no |
| denied_topics | Denied topic configurations | `list(object)` | `[]` | no |
| sensitive_info_filters | Sensitive info filter configurations | `list(object)` | `[]` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| guardrail_id | ID of the guardrail |
| guardrail_arn | ARN of the guardrail |
| guardrail_version | Version number of the guardrail |
