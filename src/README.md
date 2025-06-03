# Lambda Chatbot Backend (Bedrock Converse)

This folder contains Python Lambda functions for the AI chatbot backend using AWS Bedrock Converse API.

## Structure

- `chatbot.py` — Lambda handler and logic for the chatbot

## Packaging & Deployment

1. **Build the Lambda package:**

   ```zsh
   cd ../scripts
   chmod +x build.sh
   ./build.sh chatbot
   ```

   This creates `dist/chatbot.zip` ready for upload (e.g., to S3 for Terraform).

2. **Terraform Integration:**

   - Upload `chatbot.zip` to S3 via CI/CD pipeline.
   - Reference the S3 object in your `aws_lambda_function` resource in Terraform.

3. **API Gateway Integration:**
   - Use Lambda Proxy integration for flexible request/response handling.

## Environment Variables

- `BEDROCK_KB_ID` — The Knowledge Base ID for Bedrock Converse.

## Notes

- Use [AWS Lambda Powertools](https://awslabs.github.io/aws-lambda-powertools-python/latest/) for logging, metrics, and tracing in production.
- Update `requirements.txt` as needed for additional dependencies.
