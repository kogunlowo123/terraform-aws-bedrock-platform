terraform {
  required_version = ">= 1.7.0"
}

module "test" {
  source = "../"

  name_prefix                     = "test-bedrock"
  enable_model_invocation_logging = false

  guardrails = {
    "content-filter" = {
      name                     = "test-content-filter"
      description              = "Test content filter guardrail"
      blocked_input_messaging  = "Your input has been blocked by content filters."
      blocked_output_messaging = "The model output has been blocked by content filters."
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
          name       = "illegal-activities"
          definition = "Any discussion of illegal activities or how to perform them"
          examples   = ["How do I hack a system?"]
        }
      ]
    }
  }

  tags = {
    Test = "true"
  }
}
