# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-07

### Added

- Root module with support for Knowledge Bases, Agents, Guardrails, OpenSearch Serverless, and model invocation logging.
- `aws_bedrock_model_invocation_logging_configuration` for centralized invocation logging to S3.
- `aws_bedrockagent_knowledge_base` with S3 data sources and configurable chunking strategies.
- `aws_bedrockagent_agent` with foundation model selection, instructions, and action groups.
- `aws_bedrockagent_agent_action_group` with Lambda and API schema support.
- `aws_bedrockagent_agent_alias` for stable agent references.
- `aws_bedrock_guardrail` with content filters, denied topics, and PII entity filters.
- `aws_bedrock_guardrail_version` for versioned guardrail deployments.
- `aws_opensearchserverless_collection` for vector storage (VECTORSEARCH type).
- `aws_opensearchserverless_security_policy` for encryption and network policies.
- `aws_opensearchserverless_access_policy` for data access control.
- Least-privilege IAM roles for knowledge bases, agents, and the logging service.
- Submodule `modules/knowledge-base` for standalone knowledge base deployments.
- Submodule `modules/agent` for standalone agent deployments.
- Submodule `modules/guardrails` for standalone guardrail deployments.
- Basic, advanced, and complete usage examples.
- Comprehensive README with RAG architecture diagram.
