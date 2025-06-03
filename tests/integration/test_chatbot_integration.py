import json
import pytest
from unittest.mock import patch, MagicMock
from src import chatbot


def test_should_respond_with_greeting_when_kb_is_accessible(lambda_context):
    event = {"body": json.dumps({"input": "Hello"})}
    lambda_context.e2e_test_mode = True
    result = chatbot.lambda_handler(event, lambda_context)
    body = json.loads(result["body"])

    assert result["statusCode"] == 200
    assert "AnyTicket" in body["answer"]
    assert "citations" in body
    assert isinstance(body["citations"], list)
    assert len(body["citations"]) > 0
