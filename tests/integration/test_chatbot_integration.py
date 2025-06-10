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
    assert "Hello!" in body["answer"]


def test_should_use_rag_for_factual_query():
    """
    Test that the classifier correctly identifies a factual query that requires RAG.
    """
    factual_query = "What is AnyTicket's refund policy for canceled events?"
    empty_conversation = []

    result = chatbot.should_use_rag(factual_query, empty_conversation)

    assert (
        result is True
    ), "The factual query about AnyTicket's refund policy should use RAG"


def test_should_not_use_rag_for_followup_query():
    """
    Test that the classifier correctly identifies a follow-up query that doesn't require RAG.
    """
    follow_up_query = "How long does the refund process usually take?"
    conversation_with_context = [
        {
            "role": "user",
            "content": [
                {"text": "What is AnyTicket's refund policy for canceled events?"}
            ],
        },
        {
            "role": "assistant",
            "content": [
                {
                    "text": "For canceled events, AnyTicket automatically processes a full refund to the original payment method used for purchase. The refund includes the ticket price and most fees, except for any delivery fees if tickets were already delivered. Refunds are typically processed within 30 business days, though most customers receive them within 7-10 business days, depending on their financial institution. You'll receive an email notification when your refund has been initiated. If you don't receive your refund within 30 days, please contact our customer support team."
                }
            ],
        },
    ]

    result = chatbot.should_use_rag(follow_up_query, conversation_with_context)

    assert result is False, "The follow-up query about refund timing should not use RAG"


def test_returns_boolean_for_ambiguous_query():
    """
    Test that the classifier returns a boolean value for ambiguous queries.
    """
    ambiguous_query = "Are there any good seats left?"
    minimal_conversation = [
        {
            "role": "user",
            "content": [
                {"text": "I'm interested in the Taylor Swift concert next month."}
            ],
        },
        {
            "role": "assistant",
            "content": [
                {
                    "text": "Great! AnyTicket has several Taylor Swift concerts scheduled for next month in different cities. Which city were you interested in attending?"
                }
            ],
        },
    ]

    result = chatbot.should_use_rag(ambiguous_query, minimal_conversation)

    assert isinstance(
        result, bool
    ), "The function should return a boolean value for ambiguous queries about ticket availability"


def test_should_use_rag_for_specific_event_info():
    """
    Test that the classifier correctly identifies a query about specific event details that requires RAG.
    """
    event_query = "What time does the NBA Finals Game 3 start and what are the available ticket prices?"
    basic_conversation = [
        {
            "role": "user",
            "content": [
                {"text": "Hello, I'm looking for information about the NBA Finals."}
            ],
        },
        {
            "role": "assistant",
            "content": [
                {
                    "text": "Hi there! I'd be happy to help you with information about the NBA Finals. What specific information are you looking for?"
                }
            ],
        },
    ]

    result = chatbot.should_use_rag(event_query, basic_conversation)

    assert result is True, "The specific event information query should use RAG"
