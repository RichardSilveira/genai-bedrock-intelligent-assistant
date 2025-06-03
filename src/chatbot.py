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
        if not user_input:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "'input' is required in request body."}),
            }

        response = bedrock.retrieve_and_generate(
            input={"text": user_input}, retrieveAndGenerateConfiguration=RAG_CONFIG
        )
        answer = response.get("output", {}).get("text")

        if is_test_mode:
            return {
                "statusCode": 200,
                "body": json.dumps(
                    {"answer": answer, "citations": response.get("citations", [])}
                ),
            }

        return {"statusCode": 200, "body": json.dumps({"answer": answer})}
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
