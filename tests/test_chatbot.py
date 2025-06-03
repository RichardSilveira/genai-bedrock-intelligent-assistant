import json
import pytest
from unittest.mock import patch, MagicMock
from src import chatbot


def test_lambda_handler_success():
    event = {"body": json.dumps({"input": "Hello"})}
    context = None
    mock_response = {"output": {"text": "Hi there!"}}

    with patch.object(chatbot, "bedrock") as mock_bedrock:
        mock_bedrock.retrieve_and_generate.return_value = mock_response
        result = chatbot.lambda_handler(event, context)

    assert result["statusCode"] == 200
    assert json.loads(result["body"]) == {"answer": "Hi there!"}


def test_lambda_handler_missing_input():
    event = {"body": json.dumps({})}
    context = None

    result = chatbot.lambda_handler(event, context)

    assert result["statusCode"] == 400
    assert "input" in result["body"]


def test_lambda_handler_exception():
    event = {"body": "not-json"}
    context = None

    with patch.object(chatbot, "bedrock") as mock_bedrock:
        mock_bedrock.retrieve_and_generate.side_effect = Exception("fail")
        # This will fail at json.loads, so we expect a 500
        result = chatbot.lambda_handler(event, context)

    assert result["statusCode"] == 500
