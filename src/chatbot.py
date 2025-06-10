import os
import json
import boto3
from aws_lambda_powertools import Logger

# Get environment/configuration variables once (cold start optimization)
KB_ID = os.environ["BEDROCK_KB_ID"]
MODEL_ARN = os.environ["BEDROCK_MODEL_ARN"]
MODEL_ID = os.environ["BEDROCK_MODEL_ID"]
CLASSIFIER_MODEL_ID = os.environ["BEDROCK_CLASSIFIER_MODEL_ID"]
REGION = os.environ.get("AWS_REGION", "us-east-1")

RAG_CONFIG = {
    "type": "KNOWLEDGE_BASE",
    "knowledgeBaseConfiguration": {
        "knowledgeBaseId": KB_ID,
        "modelArn": MODEL_ARN,
    },
}

logger = Logger()
bedrock_agent = boto3.client("bedrock-agent-runtime", region_name=REGION)
bedrock_runtime = boto3.client("bedrock-runtime", region_name=REGION)


def should_use_rag(query, conversation_context):
    """
    Use a cheaper LLM to determine if the query requires external knowledge.

    Args:
        query: The user's question
        conversation_context: The conversation history

    Returns:
        bool: True if RAG should be used, False otherwise
    """
    try:
        # Extract text from conversation context for the classifier
        context_text = ""
        for msg in conversation_context:
            if msg.get("role") == "assistant" and msg.get("content"):
                for content in msg.get("content", []):
                    if content.get("text"):
                        context_text += f"Assistant: {content.get('text')}\n"
            elif msg.get("role") == "user" and msg.get("content"):
                for content in msg.get("content", []):
                    if content.get("text"):
                        context_text += f"User: {content.get('text')}\n"

        # Ask the classifier model if this query needs external knowledge
        # Note: Using only user and assistant roles as system role is not supported
        classification_response = bedrock_runtime.converse(
            modelId=CLASSIFIER_MODEL_ID,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "text": (
                                "You are a query classifier. Your job is to decide if the user's query needs information that is NOT already in the conversation context and does NOT require search in a proprietary dataset via RAG.\n\n"
                                "- If the answer to the query can be found in the conversation context, even if the query is a follow-up, rephrased, or refers to information already provided, answer: NO\n"
                                "- If the query asks for facts, data, or knowledge that is NOT present in the conversation context, answer: YES\n\n"
                                "Examples:\n"
                                "Q: What is the capital of France? (context does not mention France)\nA: YES\n\n"
                                "Q: Can you repeat what you just said? (context contains previous assistant message)\nA: NO\n\n"
                                "Q: What is 2+2? (context does not mention math)\nA: YES\n\n"
                                "Q: What did I ask earlier? (context contains previous user message)\nA: NO\n\n"
                                "Q: How long does the refund process usually take? (context contains: 'Refunds are typically processed within 30 business days, though most customers receive them within 7-10 business days...')\nA: NO\n\n"
                                "Q: How do I get my money back for a canceled event? (context contains: 'AnyTicket automatically processes a full refund to the original payment method...')\nA: NO\n\n"
                                "IMPORTANT: Respond with ONLY YES or NO. Do not explain. Use uppercase.\n\n"
                                f"Query: {query}\n\nConversation context:\n{context_text}"
                            )
                        }
                    ],
                }
            ],
            inferenceConfig={
                "maxTokens": 10,
                "stopSequences": ["YES", "NO"],
                "temperature": 0.0,
                "topP": 0.1,
            },
        )

        answer = (
            classification_response.get("output", {})
            .get("message", {})
            .get("content", [{}])[0]
            .get("text", "")
            .strip()
            .upper()
        )
        logger.info(f"RAG classification result: {answer}")

        # Default to using RAG if classification is unclear
        if "YES" in answer:
            return True
        elif "NO" in answer:
            return False
        else:
            raise Exception(
                f"Unclear classification result: {answer}"
            )  # todo - while testing
            # logger.warning(
            #     f"Unclear classification result: {answer}. Defaulting to using RAG."
            # )
            # return True

    except Exception as e:
        logger.exception(f"Error in RAG classification: {str(e)}")
        # Default to using RAG if there's an error in classification
        return True


@logger.inject_lambda_context
def lambda_handler(event, context):
    try:
        logger.info("Processing event")
        is_test_mode = getattr(context, "e2e_test_mode", False)

        body = json.loads(event["body"]) if "body" in event and event["body"] else event
        user_input = body.get("input")
        session_id = body.get("sessionId")
        messages = body.get("messages", [])

        if not user_input:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "'input' is required in request body."}),
            }

        # Filter out any system messages from the input messages
        # as they're not supported by the Converse API
        filtered_messages = []
        system_instructions = ""

        for msg in messages:
            if msg.get("role") == "system":
                # Extract system instructions to use later
                for content in msg.get("content", []):
                    if content.get("text"):
                        system_instructions += content.get("text") + " "
            elif msg.get("role") in ["user", "assistant"]:
                filtered_messages.append(msg)

        # Use filtered messages for the conversation context
        messages = filtered_messages

        # Add the user's message to the conversation
        user_message = {"role": "user", "content": [{"text": user_input}]}
        messages.append(user_message)

        # Determine if RAG is needed for this query
        needs_rag = should_use_rag(user_input, messages)
        logger.info(f"Using RAG for this query: {needs_rag}")

        rag_answer = ""
        citations = []

        # If RAG is needed, retrieve information from knowledge base
        if needs_rag:
            rag_response = bedrock_agent.retrieve_and_generate(
                input={"text": user_input},
                retrieveAndGenerateConfiguration=RAG_CONFIG,
                sessionId=session_id,  # Pass session_id if available
            )

            # Get the session ID (either existing or newly generated)
            session_id = rag_response.get("sessionId")
            rag_answer = rag_response.get("output", {}).get("text", "")
            citations = rag_response.get("citations", [])

        # Prepare the messages for the Converse API
        # Include any system instructions as part of the user's first message if needed
        if (
            system_instructions and len(messages) <= 2
        ):  # Only for the first real interaction
            # Prepend system instructions to the user's message
            first_user_msg = messages[-1]  # The user message we just added
            enhanced_text = f"[Instructions for you: {system_instructions}]\n\nUser query: {first_user_msg['content'][0]['text']}"
            messages[-1] = {"role": "user", "content": [{"text": enhanced_text}]}

        # Add RAG information as part of the user's message if needed
        if needs_rag and rag_answer:
            # Get the last user message
            last_user_msg = messages[-1]
            # Enhance it with RAG information
            enhanced_text = f"{last_user_msg['content'][0]['text']}\n\n[Reference information: {rag_answer}]"
            messages[-1] = {"role": "user", "content": [{"text": enhanced_text}]}

        # Generate a response using the Converse API
        converse_response = bedrock_runtime.converse(
            modelId=MODEL_ID, messages=messages
        )

        # Extract the assistant's response
        assistant_message = converse_response.get("output", {}).get("message", {})
        messages.append(assistant_message)

        # Step 7: Return the response and conversation state
        response_data = {
            "answer": assistant_message.get("content", [{}])[0].get("text", ""),
            "sessionId": session_id,
            "messages": messages,
            "used_rag": needs_rag,
        }

        if is_test_mode and needs_rag:
            response_data["citations"] = citations

        return {"statusCode": 200, "body": json.dumps(response_data)}

    except Exception as e:
        logger.exception("Error processing request")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
