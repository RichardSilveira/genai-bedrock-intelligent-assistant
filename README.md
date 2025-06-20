# 🤖 Building a Production-Ready Generative AI Chatbot at Scale – AWS Bedrock & Agentic RAG

A **production-ready** showcase for building scalable AI assistants with AWS Bedrock and Agentic RAG.

Beyond the "getting start", this practical example highlights:

- Advanced cloud architecture for GenAI applications
- Secure, Terraform-managed infrastructure (IaC).
- Autonomous AI agents capable of orchestrating complex, multi-step user journeys

This repository serves as a practical reference for professionals building robust, scalable, and production-ready GenAI chatbots at scale, following AWS’s Well-Architected Framework.

## The Evolution of Generative AI: From RAG to Agentic RAG

### 📚 What is RAG?

Standard Large Language Models (LLMs) are limited by their static, offline training data.
Retrieval-Augmented Generation (RAG) addresses this limitation by enabling LLMs to dynamically retrieve and incorporate current, proprietary data into their responses. This enhances accuracy, context relevance, and verifiable outputs, transforming LLMs into precise, enterprise-focused knowledge engines.

![RAG](./docs/assets/rag-kb.png)

#### Strategic Advantages of RAG

- **Real-time Data Accuracy:** Ensures LLM responses are up-to-date by leveraging current enterprise data.
- **Hallucination Reduction:** Grounds AI responses in verified facts to minimize inaccuracies.
- **Effective Use of Proprietary Knowledge:** Enables secure integration of confidential and internal datasets.
- **Cost-Efficient:** Delivers domain-specific insights without costly model retraining.

### 🦄 Agentic RAG: Autonomous, Multi-step AI Workflows

Traditional RAG provides context-aware responses. Agentic RAG advances this capability further, empowering LLMs to function as autonomous agents capable of reasoning, planning, and executing multi-step tasks.

For example, this project's Agentic RAG chatbot demonstrates an autonomous conversational workflow:

- User requests event options on a specific date.
- Agent provides detailed event information.
- **Agent seamlessly guides the user to complete a ticket purchase**.

🧞‍♂️ This multi-step, agent-driven approach showcases how Agentic RAG automates **complex processes**, delivering sophisticated, **task-oriented solutions with minimal human intervention**.

![Agentic RAG](./docs/assets/agentic-rag.drawio.png)

## 🏗️ High-Level Architecture

- **Frontend:** Streamlit demo (for portfolio/demo only)
- **API Layer:**
  - Amazon API Gateway (HTTP API, Lambda Proxy integration **for scalable, managed entry point**)
  - Custom Lambda Authorizer (**ensures robust API key & origin verification for secure access**)
- **Application Logic & Agent Orchestration:**
  - AWS Lambda (Python, serving as the orchestrator for Bedrock Agents and other services)
  - **Amazon Bedrock Agents:** Drives multi-turn conversations and complex task execution. Manages session state directly (no separate database needed) and leverages tools for actions.
- **Data & Knowledge Base:**
  - Bedrock Knowledge Base (backed by S3, supports various data sources like Pinecone, OpenSearch, etc.)
  - Secure prompt engineering applied at the Bedrock layer (guiding Agent behavior and content safety)
- **Networking & Security:**
  - **AWS WAF (Layer 7 protection at the edge), CloudFront (API acceleration, DDoS protection)**
  - VPC, private subnets, NAT Gateway, **NACL**, security groups (for secure and isolated networking)
- **Observability:**
  - CloudWatch logs, metrics, and alarms (for comprehensive operational insight)
- **IaC:**
  - Modular Terraform (ensuring repeatable, scalable, and auditable infrastructure deployment)

---

## 🚀 Architecting for Scale: Reusability and Integration Capabilities

Unlocking enterprise value through versatile Generative AI integration.

### 🧭 Amazon Bedrock Knowledge Bases: Flexible Integration Points

Amazon Bedrock Knowledge Bases are designed for broad reusability and seamless integration across diverse applications:

- **API-oriented Solution:** Knowledge Bases can be exposed as an API, powering a wide array of applications, from internal, company-dedicated solutions to external-facing SaaS products, enabling scalable and secure access to your proprietary data.
- **Foundation for Bedrock Agents:** Beyond direct querying, Knowledge Bases serve as a foundational data source for Bedrock Agents, enabling them to retrieve contextually rich information necessary for building complex, multi-step conversational flows and automated tasks.
- **Direct MCP Integration:** Through [MCP](https://awslabs.github.io/mcp/servers/bedrock-kb-retrieval-mcp-server/), developers can query Knowledge Bases from various Integrated Development Environments (IDEs) such as Cursor or VSCode, or via the AWS Q CLI. This also enables building **custom internal tools** that allow product managers or data analysts to directly explore, validate, or audit specific private data points within the knowledge base, offering quick factual lookups outside of a conversational AI.

### 🤖 Amazon Bedrock Agents: Orchestrating Advanced Workflows

Amazon Bedrock Agents offer powerful reusability and collaboration patterns for complex automation:

- **Agent Flow as an API:** Individual Agent workflows can be exposed as APIs, providing powerful, task-oriented capabilities that can be consumed by other applications or services, whether for internal automation or as part of a public-facing product.
- **Multi-Agent Collaboration:** For highly complex tasks, Amazon Bedrock Agents supports advanced multi-agent collaboration. A designated **Supervisor Agent** orchestrates sophisticated workflows by intelligently delegating specific sub-tasks to specialized **Collaborator Agents**. This modular approach allows for breaking down intricate problems, leveraging distinct areas of expertise, and seamlessly combining results to achieve comprehensive, automated solutions.

---

## 💯 Building Robust AI Applications at Scale: A Well-Architected Approach

Building production-grade Generative AI applications requires a strong architectural foundation. The AWS Well-Architected Framework provides essential guidance for achieving these goals. This project rigorously applies its principles, making it truly prepared for large-scale, real-world deployment.

**Key Pillars for Production-Ready AI:**

- **Operational Excellence:** Logging and monitoring (e.g., Model Invocation Logs, VPC Flow Logs) for continuous improvement and efficiency.
- **Security:** Multi-layered protection with AWS WAF on top of CloudFront for protection at the edge, complemented by API keys, IAM least privilege, restrict networking firewall rules (NACL/SG), Bedrock Guardrails, and prompt injection defenses.
- **Reliability:** High availability and fault tolerance via Multi-AZ VPC (with multiple NATs), reserved Lambda concurrency, API Gateway throttling, and Cross-Region Inference Profiles for enhanced resilience and throughput across geographies.
- **Performance Efficiency:** Optimized resource utilization with serverless architecture, Lambda Provisioned Concurrency and Auto-Scaling for consistent low-latency responses, and global CDN (CloudFront).
- **Cost Optimization:** Efficient resource sizing, pay-as-you-go models, Cost Allocation Tags for effective cost tracking, and effective Foundation Model selection strategy as we need 2 FM in this use-case _(one for the KB, and another for the Agent)_.

This project's core architecture exemplifies these principles, particularly in its robust API communication and comprehensive security framework—critical aspects for any Generative AI solution operating at scale.

### 🛡️ API Communication and Security Architecture

This architecture follows a defense-in-depth model to provide a secure and globally accelerated entry point for the application's API. Its design focuses on protecting traffic at the network edge, accelerating user requests via the AWS global backbone, and decoupling the API endpoint layer from the core Agentic RAG processing logic.

![API Communication and Security Architecture](./docs/assets/api-communication-security-architecture.drawio.png)

The request flow and key components are:

- **AWS WAF:** Provides a defense-in-depth, Layer 7 firewall at the network edge. It inspects incoming requests with a prioritized, multi-layered strategy, optimized for efficiency and performance _(managing WAF Capacity Units (WCU) to balance the computational cost of complex rules with their security benefits and the need for low-latency traffic inspection)_.

- **IP & Rate Limiting:** Immediately blocks known malicious IPs (`AmazonIpReputationList`) and provides automated protection against brute-force and DDoS attacks using a `RateLimitRule`.
- **Threat Signature Matching:** Utilizes AWS Managed Rule Sets to block requests from anonymous proxies (`AnonymousIpList`), known exploit patterns (`KnownBadInputsRuleSet`), and common web attacks defined in the OWASP Top 10 (`CoreRuleSet`).

- **Amazon CloudFront:** It **accelerates API performance** by routing users to the nearest edge location and utilizes the AWS global backbone to communicate with the origin. It is configured to be the **only** entry point to the API Gateway to enhance security.

- **API Gateway _(HTTP API)_:** Serves as the managed, regional entry point for our backend. It handles request validation, throttling, and routing. Access to the API Gateway is locked down and verified by a **custom Lambda Authorizer**, which performs two critical checks:

  1.  It validates a secret `X-Origin-Verify` header to ensure the request is from our CloudFront distribution.
  2.  It validates the client-provided `x-api-key` required for API access.

- **AWS Lambda:** The function is invoked synchronously by API Gateway and runs within our private VPC.

  - **Availability and Performance Efficiency:** To ensure responsiveness during traffic spikes and protect downstream resources, the key functions are configured with **reserved concurrency** and **provisioned concurrency**.
  - **Dependency Management:** Common libraries and dependencies are managed using **Lambda Layers** to promote code re-use, better organization, and smaller deployment package sizes.

- **Guardrails:** To **prevent PII leakage**, filter harmful content, and block undesirable topics, both FMs uses Guardrails to enhance safety and privacy.

- **Secure Prompt Engineering:** The prompts are designed with a safety-first approach leveraging industry best-practices to prevent prompt injections.

- **Parameter Store:** Simplest approach to safely store all project's secrets

- **S3:** Stores **company's private data** with Restricted Resource Policies for Knowledge Base-only access, leveraging **SSE-KMS with Bucket Keys enabled** for enhanced key control, auditable access tracking by security teams, and cost optimization.

### 🌐 Networking Architecture

The diagram below illustrates the networking components provisioned by the infrastructure code. While networking is not the main focus of this repository, it demonstrates production-grade VPC design and AWS best practices.

![Networking Components](./docs/assets/networking-components.drawio.png)

---

## 👩‍💻 Getting Started & Project Overview

### Quickstart

1. **Install prerequisites:**
   - Terraform, terraform-docs, Python 3.11+, Node.js 18+, Rust
2. **Clone the repo & set up environment variables**
3. **Build & deploy infrastructure:**
   - See `iac/README.md` for details
4. **Run the Streamlit demo:**
   - See `streamlit_demo/README.md` (if present)

### Project Structure

- `src/` — Lambda source code (chatbot, authorizer)
- `iac/` — Infrastructure as Code (Terraform modules, diagrams, docs)
- `streamlit_demo/` — Minimal frontend for API demo
- `tests/` — Unit and integration tests

### Key Technologies & Notes

- Uses [AWS Lambda Powertools](https://awslabs.github.io/aws-lambda-powertools-python/latest/) for logging, metrics, and tracing.
