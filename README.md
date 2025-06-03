# Production-Ready Generative AI chatbot using AWS Bedrock & RAG

A Generative AI intelligent assistant using AWS Bedrock & RAG, built applying production-ready principles with its infrastructure managed via IaC (Infrastructure as Code). It enables contextual Q&A from diverse data sources (unstructured/structured). A portfolio project demonstrating robust GenAI application development on AWS.

## Developer Setup

To contribute to this project, ensure the following tools are installed on your machine:

### System Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install)
- [terraform-docs](https://terraform-docs.io/user-guide/installation/)
- [Python 3.11+](https://www.python.org/downloads/)
- [Node.js 18+ and npm](https://nodejs.org/)

### Installation Steps (macOS example)

```bash
brew install terraform
brew install terraform-docs
brew install python
brew install node
brew install rust
```

# Lambda Chatbot Backend (Bedrock Converse)

This folder contains Python Lambda functions for the AI chatbot backend using AWS Bedrock Converse API.

## Structure

- `src/chatbot.py` — Lambda handler and logic for the chatbot
- `scripts/build.sh` — Script to build and package Lambda(s) for deployment

## Packaging & Deployment

1. **Build the Lambda package:**

   ```zsh
   cd scripts
   chmod +x build.sh
   ./build.sh chatbot
   ```

   This creates `dist/chatbot.zip` ready for upload (e.g., to S3 for Terraform).

2. **Terraform Integration:**

   - Upload `chatbot.zip` to S3 (manually or via CI/CD pipeline).
   - Reference the S3 object in your `aws_lambda_function` resource in Terraform.

3. **API Gateway Integration:**
   - Use Lambda Proxy integration for flexible request/response handling.

## Environment Variables

- `BEDROCK_KB_ID` — The Knowledge Base ID for Bedrock Converse.

## Notes

- Use [AWS Lambda Powertools](https://awslabs.github.io/aws-lambda-powertools-python/latest/) for logging, metrics, and tracing in production.
- Update `requirements.txt` as needed for additional dependencies.
