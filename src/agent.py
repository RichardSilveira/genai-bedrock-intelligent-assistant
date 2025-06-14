import os
import json
import boto3
from aws_lambda_powertools import Logger
import logging

REGION = os.environ.get("AWS_REGION", "us-east-1")
AGENT_ID = os.environ["BEDROCK_AGENT_ID"]
AGENT_ALIAS_ID = os.environ["BEDROCK_AGENT_ALIAS_ID"]

logger = Logger()

bedrock = boto3.client("bedrock-agent-runtime", region_name=REGION)


@logger.inject_lambda_context
def lambda_handler(event, context):
    try:
        logger.info("Processing event")
        is_test_mode = getattr(context, "e2e_test_mode", False)

        if is_test_mode:
            logging.getLogger("botocore").setLevel(logging.DEBUG)

        body = json.loads(event["body"]) if "body" in event and event["body"] else event
        user_input = body.get("input")
        session_id = body.get("sessionId")

        if not user_input:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "'input' is required in request body."}),
            }
        if not session_id:
            return {
                "statusCode": 400,
                "body": json.dumps(
                    {"error": "'sessionId' is required in request body."}
                ),
            }
        agent_args = {
            "agentId": AGENT_ID,
            "agentAliasId": AGENT_ALIAS_ID,
            "inputText": user_input,
            "sessionId": session_id,
            "streamingConfigurations": {
                "applyGuardrailInterval": 20,
                "streamFinalResponse": False,
            },
        }

        response = bedrock.invoke_agent(**agent_args)

        # Handle EventStream response
        completion_text = ""

        # Process the EventStream response
        if "completion" in response:
            for event in response.get("completion"):
                # Collect agent output from chunks
                if "chunk" in event:
                    chunk = event["chunk"]
                    if "bytes" in chunk:
                        completion_text += chunk["bytes"].decode()

        # Get session ID from response headers if available
        response_session_id = response.get("sessionId", session_id)

        # Prepare the result
        result = {"answer": completion_text, "sessionId": response_session_id}

        return {"statusCode": 200, "body": json.dumps(result)}
    except Exception as e:
        logger.exception("Error processing request")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
