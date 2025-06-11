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

## Multi-turn Conversation with RAG

The chatbot implements multi-turn conversation capabilities using Amazon Bedrock's Knowledge Base with session management. This allows the chatbot to maintain context across multiple interactions while providing responses based on your knowledge base.

### How It Works

1. **Session-based Conversation Management**:

   - Uses Amazon Bedrock's built-in session management capabilities
   - Maintains conversation context automatically between requests
   - No need for additional conversation tracking or state management

2. **Prompt Engineering Optimization**:

   - Implements strategic prompt templating to shape AI behavior and responses
   - Defines clear agent persona boundaries for consistent brand representation

3. **Inference Parameter Tuning**:

   - Configures model parameters to balance creativity with factual accuracy:
     - Temperature: 0.8 (promotes creative responses while maintaining reliability)
     - Top-P: 0.5 (controls response diversity by limiting token selection)
     - Max Tokens: 512 (optimizes for concise responses while ensuring completeness)

4. **Request Format**:

   ```json
   {
     "input": "Your question here",
     "sessionId": "previous-session-id" // Optional for first request
   }
   ```

5. **Response Format**:

   ```json
   {
     "answer": "The model's response",
     "sessionId": "session-id-to-use-next-time"
   }
   ```

6. **Session Expiration**:
   - Amazon Bedrock sessions typically expire after a period of inactivity (usually 30 minutes)
   - No explicit TTL configuration is needed for basic implementation

### Implementation Notes

- No database is required for this implementation as session state is maintained by Amazon Bedrock
- The client application is responsible for storing and sending the sessionId with each request
- Citations are included in test mode to help verify knowledge base retrieval accuracy

## Lambda Chatbot Backend (Bedrock Knowledge Base)

This folder contains Python Lambda functions for the AI chatbot backend using AWS Bedrock Knowledge Base.

### Structure

- `src/chatbot.py` — Lambda handler and logic for the chatbot

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

- `BEDROCK_KB_ID` — The Knowledge Base ID for Bedrock.
- `BEDROCK_MODEL_ARN` — The ARN of the model used for knowledge base retrieval.

## Notes

- Use [AWS Lambda Powertools](https://awslabs.github.io/aws-lambda-powertools-python/latest/) for logging, metrics, and tracing in production.
- Update `requirements.txt` as needed for additional dependencies.
