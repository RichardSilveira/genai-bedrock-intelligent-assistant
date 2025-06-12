# AnyTicket GenAI Chatbot – AWS Bedrock & RAG (Production-Ready Portfolio)

Welcome to the **AnyTicket AI Support Assistant** project—a robust, production-grade Generative AI solution built on AWS Bedrock and Retrieval-Augmented Generation (RAG). This project demonstrates advanced cloud architecture, secure infrastructure-as-code (IaC), and real-world GenAI application development for the event ticketing domain.

---

## 🚀 Executive Summary

- **Business Value:**
  - 24/7 intelligent customer support for event ticketing, reducing operational costs and improving customer satisfaction.
  - Secure, scalable, and compliant by design—ready for real-world enterprise workloads.
- **Solution Highlights:**
  - Modern GenAI patterns, multi-turn conversation, and contextual Q&A from unstructured data.
  - End-to-end security, observability, and automation using AWS best practices.

---

## 🏗️ Solution Overview

- **Domain:** Event ticketing (AnyTicket)
- **Use Case:** AI-powered, multi-turn customer support chatbot
- **Cloud Platform:** AWS (Bedrock, Lambda, API Gateway, CloudFront, WAF, VPC, S3, IAM, etc.)
- **IaC:** 100% managed via Terraform (modular, reusable, and production-ready)
- **Frontend:** Minimal Streamlit demo for API showcase (decoupled from backend)

---

## 🌟 Key Differentiators

- **Production-Ready by Design:**
  - Security, scalability, and compliance are built-in—not afterthoughts.
  - Automated deployment, monitoring, and guardrails for safe GenAI adoption.
- **AWS Well-Architected Framework Alignment:**
  - [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/) principles:
    - **Operational Excellence:** Logging and monitoring.
    - **Security:** WAF, API keys, IAM least privilege, Bedrock Guardrails, prompt injection protection.
    - **Reliability:** Multi-AZ VPC, reserved Lambda concurrency, API Gateway throttling.
    - **Performance Efficiency:** Serverless, auto-scaling, and global CDN (CloudFront).
    - **Cost Optimization:** Pay-as-you-go, no idle resources, and efficient resource sizing.
- **Real-World Patterns:**
  - Multi-turn conversation, session management, secure prompt engineering, and content safety.
  - Modular IaC for rapid adaptation to new domains or data sources.

---

## 🛡️ Security & Compliance Highlights

- **Defense-in-Depth:**
  - AWS WAF, CloudFront, and API Gateway for layered protection.
  - Lambda authorizer for API key validation and origin verification.
  - Bedrock Guardrails for content safety and compliance.
- **Data Privacy:**
  - No PII leakage—prompt template and RAG output are strictly controlled.
  - All secrets managed via environment variables and SSM Parameter Store.
- **Audit & Observability:**
  - CloudWatch logging for API, Lambda, and WAF events.
  - Modular observability stack for production monitoring.

---

## 🧩 Architecture Diagram

See [`iac/README.md`](iac/README.md) for detailed architecture diagrams:

- API Communication & Security
- Networking & VPC

---

## 🛠️ High-Level Architecture

- **Frontend:** Streamlit demo (for portfolio/demo only)
- **API Layer:**
  - Amazon API Gateway (HTTP API, Lambda Proxy integration)
  - Custom Lambda Authorizer (API key & origin verification)
- **Application Logic:**
  - AWS Lambda (Python, Bedrock Knowledge Base integration)
  - Bedrock RAG with secure prompt engineering
- **Data & Knowledge Base:**
  - Bedrock Knowledge Base (S3, Pinecone, OpenSearch, etc. supported)
  - No database required for session state (handled by Bedrock)
- **Networking & Security:**
  - VPC, private subnets, NAT Gateway, security groups
  - AWS WAF, CloudFront (global CDN, DDoS protection)
- **Observability:**
  - CloudWatch logs, metrics, and alarms
- **IaC:**
  - Modular Terraform (see `iac/` and submodules)

---

## 📦 Project Structure

- `src/` — Lambda source code (chatbot, authorizer)
- `iac/` — Infrastructure as Code (Terraform modules, diagrams, docs)
- `streamlit_demo/` — Minimal frontend for API demo
- `tests/` — Unit and integration tests

---

## 📝 Key Features & Implementation Details

- **Multi-turn Conversation:**
  - Session management via Bedrock (no DB required)
- **Prompt Security:**
  - User input wrapped in `<nonce>`, RAG output in `<KB>`
  - Prevents prompt injection and data leakage
- **Content Safety:**
  - Bedrock Guardrails, WAF, and profanity filters
- **API Security:**
  - API key, origin verification, and Lambda authorizer
- **IaC Best Practices:**
  - Modular, reusable, and environment-agnostic
- **Observability:**
  - CloudWatch logs for API, Lambda, and WAF

---

## 👩‍💻 Technical Deep Dive

- **Terraform modules** for Bedrock, Lambda, API Gateway, WAF, VPC, and more
- **Production patterns:**
  - Lambda reserved concurrency, API throttling, VPC isolation
  - Secure environment variable and secret management
- **Extensible:**
  - Add new data sources, models, or domains with minimal changes
- **Testing:**
  - Unit and integration tests for backend logic

---

## 📈 Business & Domain Impact

- **GenAI for Customer Support:**
  - Automates and enhances customer support for event ticketing
  - Reduces support costs, improves response times, and scales with demand
- **Modern Cloud Skills:**
  - Demonstrates AWS, GenAI, and security best practices
  - IaC, serverless, and production-readiness
- **Compliance & Trust:**
  - Built-in guardrails for privacy, safety, and regulatory needs

---

## 📚 Further Reading & Diagrams

- See [`iac/README.md`](iac/README.md) for deep dives into:
  - API security architecture
  - Networking and VPC design
  - Terraform module documentation
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

## 🏁 Quickstart & Developer Setup

1. **Install prerequisites:**
   - Terraform, terraform-docs, Python 3.11+, Node.js 18+, Rust
2. **Clone the repo & set up environment variables**
3. **Build & deploy infrastructure:**
   - See `iac/README.md` for details
4. **Run the Streamlit demo:**
   - See `streamlit_demo/README.md` (if present)

---

## 📝 Notes

- Uses [AWS Lambda Powertools](https://awslabs.github.io/aws-lambda-powertools-python/latest/) for logging, metrics, and tracing
- All code and infra are production-ready and modular for real-world use
- For questions or collaboration, please reach out!
