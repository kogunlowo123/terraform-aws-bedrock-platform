variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "name" {
  description = "Name of the agent."
  type        = string
}

variable "description" {
  description = "Description of the agent."
  type        = string
}

variable "foundation_model" {
  description = "Foundation model ID (e.g., anthropic.claude-3-sonnet-20240229-v1:0)."
  type        = string
}

variable "instruction" {
  description = "Instruction prompt for the agent."
  type        = string
}

variable "idle_session_ttl" {
  description = "Idle session TTL in seconds."
  type        = number
  default     = 600
}

variable "action_groups" {
  description = "List of action group configurations."
  type = list(object({
    name                 = string
    description          = string
    api_schema_s3_bucket = optional(string)
    api_schema_s3_key    = optional(string)
    api_schema_payload   = optional(string)
    lambda_function_arn  = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
