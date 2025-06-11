import os
import json
import boto3
from aws_lambda_powertools import Logger

# Get environment/configuration variables once (cold start optimization)
KB_ID = os.environ["BEDROCK_KB_ID"]
MODEL_ARN = os.environ["BEDROCK_MODEL_ARN"]
REGION = os.environ.get("AWS_REGION", "us-east-1")

RAG_CONFIG = {
    "type": "KNOWLEDGE_BASE",
    "knowledgeBaseConfiguration": {
        "knowledgeBaseId": KB_ID,
        "modelArn": MODEL_ARN,
        "generationConfiguration": {
            "inferenceConfig": {
                "textInferenceConfig": {
                    "maxTokens": 512,
                    "temperature": 0.8,
                    "topP": 0.5,
                }
            },
            "promptTemplate": {
                "textPromptTemplate": (
                    "Answer as a customer support agent for AnyTicket, which is a ticket system that sells tickets for events. "
                    "Provide clear, accurate, concise, and friendly responses. Always cite your sources when possible.\n\n"
                    "Relevant information from our knowledge base:\n$search_results$\n\n"
                    "User question: $user_input$"
                )
            },
        },
    },
}

logger = Logger()
bedrock = boto3.client("bedrock-agent-runtime", region_name=REGION)


@logger.inject_lambda_context
def lambda_handler(event, context):
    try:
        logger.info("Processing event")

        is_test_mode = getattr(context, "e2e_test_mode", False)

        body = json.loads(event["body"]) if "body" in event and event["body"] else event
        user_input = body.get("input")
        session_id = body.get("sessionId")
        if not user_input:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "'input' is required in request body."}),
            }

        rag_args = {
            "input": {"text": user_input},
            "retrieveAndGenerateConfiguration": RAG_CONFIG,
        }
        if session_id:
            rag_args["sessionId"] = session_id

        response = bedrock.retrieve_and_generate(**rag_args)
        answer = response.get("output", {}).get("text")
        session_id = response.get("sessionId")

        result = {"answer": answer, "sessionId": session_id}
        if is_test_mode:
            result["citations"] = response.get("citations", [])
            return {"statusCode": 200, "body": json.dumps(result)}
        return {"statusCode": 200, "body": json.dumps(result)}
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
