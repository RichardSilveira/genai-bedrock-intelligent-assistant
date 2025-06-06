import json
import pytest
import os
from unittest.mock import patch, MagicMock
from src import authorizer


def test_should_allow_access_when_api_key_is_valid(lambda_context):
    # Arrange
    event = {
        "headers": {"x-api-key": "test-api-key-value"},
        "routeArn": "arn:aws:execute-api:us-east-1:123456789012:api-id/test-stage/GET/test-resource",
    }

    with patch.object(authorizer, "ssm") as mock_ssm:
        mock_ssm.get_parameter.return_value = {
            "Parameter": {"Value": "test-api-key-value"}
        }

        # Set the parameter name directly on the module
        authorizer.ssm_param_name = "/test-project/api-key"

        # Act
        result = authorizer.lambda_handler(event, lambda_context)

        # Verify SSM parameter was called with correct parameter name
        mock_ssm.get_parameter.assert_called_once_with(
            Name="/test-project/api-key", WithDecryption=True
        )

    # Assert
    assert result["policyDocument"]["Statement"][0]["Effect"] == "Allow"
    assert result["policyDocument"]["Statement"][0]["Resource"] == event["routeArn"]
    assert result["context"]["isAuthorized"] is True


def test_should_deny_access_when_api_key_is_invalid(lambda_context):
    # Arrange
    event = {
        "headers": {"x-api-key": "wrong-api-key-value"},
        "routeArn": "arn:aws:execute-api:us-east-1:123456789012:api-id/test-stage/GET/test-resource",
    }

    with patch.object(authorizer, "ssm") as mock_ssm:
        mock_ssm.get_parameter.return_value = {
            "Parameter": {"Value": "correct-api-key-value"}
        }

        # Set the parameter name directly on the module
        authorizer.ssm_param_name = "/test-project/api-key"

        # Act
        result = authorizer.lambda_handler(event, lambda_context)

        # Verify SSM parameter was called with correct parameter name
        mock_ssm.get_parameter.assert_called_once_with(
            Name="/test-project/api-key", WithDecryption=True
        )

    # Assert
    assert result["policyDocument"]["Statement"][0]["Effect"] == "Deny"
    assert result["policyDocument"]["Statement"][0]["Resource"] == event["routeArn"]
    assert result["context"]["isAuthorized"] is False


def test_should_deny_access_when_api_key_is_missing(lambda_context):
    # Arrange
    event = {
        "headers": {},
        "routeArn": "arn:aws:execute-api:us-east-1:123456789012:api-id/test-stage/GET/test-resource",
    }

    with patch.object(authorizer, "ssm") as mock_ssm:
        # Set the parameter name directly on the module
        authorizer.ssm_param_name = "/test-project/api-key"

        # Act
        result = authorizer.lambda_handler(event, lambda_context)

        # Verify SSM parameter was not called
        mock_ssm.get_parameter.assert_not_called()

    # Assert
    assert result["policyDocument"]["Statement"][0]["Effect"] == "Deny"
    assert result["policyDocument"]["Statement"][0]["Resource"] == event["routeArn"]
    assert result["context"]["isAuthorized"] is False
