import json
import pytest
from unittest.mock import patch, MagicMock
from src import agent


def test_should_respond_with_agent(lambda_context):
    event = {
        "body": json.dumps(
            {"input": "What can you do?", "sessionId": "test-session-123"}
        )
    }
    lambda_context.e2e_test_mode = True
    result = agent.lambda_handler(event, lambda_context)
    body = json.loads(result["body"])
    assert result["statusCode"] == 200
    assert body.get("answer") and isinstance(body["answer"], str)
    assert "raw_response" in body
