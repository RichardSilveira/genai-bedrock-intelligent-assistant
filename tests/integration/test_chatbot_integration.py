import json
import pytest
from unittest.mock import patch, MagicMock
from src import chatbot


def test_should_respond_with_anyticket_refund_policy_from_rag(lambda_context):
    event = {
        "body": json.dumps(
            {"input": "What is AnyTicket's refund policy for canceled events?"}
        )
    }
    lambda_context.e2e_test_mode = True
    result = chatbot.lambda_handler(event, lambda_context)
    body = json.loads(result["body"])

    assert result["statusCode"] == 200
    # Check that an answer is present and non-empty
    assert (
        body.get("answer")
        and isinstance(body["answer"], str)
        and len(body["answer"]) > 0
    )
    # Check that citations are present in the response body
    assert "citations" in body
    assert isinstance(body["citations"], list)
