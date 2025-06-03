import json
import pytest
from unittest.mock import patch, MagicMock
from src import chatbot


class FakeContext:
    def __init__(self):
        self.test_mode = True


def test_should_respond_with_greeting_when_kb_is_accessible():
    event = {"body": json.dumps({"input": "Hello"})}
    context = FakeContext()

    result = chatbot.lambda_handler(event, context)
    body = json.loads(result["body"])

    assert result["statusCode"] == 200
    assert "AnyTicket" in body["answer"]
    assert "citations" in body
    assert isinstance(body["citations"], list)
    assert len(body["citations"]) > 0
