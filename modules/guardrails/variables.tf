variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
}

variable "name" {
  description = "Name of the guardrail."
  type        = string
}

variable "description" {
  description = "Description of the guardrail."
  type        = string
}

variable "blocked_input_messaging" {
  description = "Message shown when input is blocked."
  type        = string
}

variable "blocked_output_messaging" {
  description = "Message shown when output is blocked."
  type        = string
}

variable "content_filters" {
  description = "List of content filter configurations."
  type = list(object({
    type            = string
    input_strength  = string
    output_strength = string
  }))
  default = []
}

variable "denied_topics" {
  description = "List of denied topic configurations."
  type = list(object({
    name       = string
    definition = string
    examples   = optional(list(string), [])
  }))
  default = []
}

variable "sensitive_info_filters" {
  description = "List of sensitive information filter configurations."
  type = list(object({
    type   = string
    action = string
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}
