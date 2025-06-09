import json
import pytest
import os
from unittest.mock import patch, MagicMock
from src import authorizer


# --------------------------------------------------
# CloudFront x-origin-verify | auto-generated Headers
# --------------------------------------------------
def test_should_deny_access_when_not_from_cloudfront(lambda_context):
    # Arrange
    event = {
        "headers": {"x-api-key": "test-api-key-value"},
        "routeArn": "arn:aws:execute-api:us-east-1:123456789012:api-id/test-stage/GET/test-resource",
    }

    with patch.object(authorizer, "ssm") as mock_ssm:
        # Set the parameter names directly on the module
        authorizer.ssm_param_name = "/test-project/api-key"
        authorizer.cloudfront_secret_param_name = "/test-project/cloudfront-secret"

        # Act
        result = authorizer.lambda_handler(event, lambda_context)

    # Assert - should deny due to missing CloudFront headers
    assert result["policyDocument"]["Statement"][0]["Effect"] == "Deny"
    assert result["policyDocument"]["Statement"][0]["Resource"] == event["routeArn"]
    assert result["context"]["isAuthorized"] is False


def test_should_allow_access_when_from_cloudfront_with_valid_api_key(lambda_context):
    # Arrange
    event = {
        "headers": {
            "x-api-key": "test-api-key-value",
            "x-origin-verify": "test-cloudfront-secret",
            "cloudfront-forwarded-proto": "https",  # CloudFront adds this header
        },
        "routeArn": "arn:aws:execute-api:us-east-1:123456789012:api-id/test-stage/GET/test-resource",
    }

    with patch.object(authorizer, "ssm") as mock_ssm:
        # Configure mock to return different values based on parameter name
        def get_parameter_side_effect(Name, WithDecryption=False):
            if Name == "/test-project/api-key":
                return {"Parameter": {"Value": "test-api-key-value"}}
            elif Name == "/test-project/cloudfront-secret":
                return {"Parameter": {"Value": "test-cloudfront-secret"}}
            raise Exception(f"Unexpected parameter name: {Name}")

        mock_ssm.get_parameter.side_effect = get_parameter_side_effect

        # Set the parameter names directly on the module
        authorizer.ssm_param_name = "/test-project/api-key"
        authorizer.cloudfront_secret_param_name = "/test-project/cloudfront-secret"

        # Act
        result = authorizer.lambda_handler(event, lambda_context)

        # Verify SSM parameter was called for both CloudFront secret and API key
        assert mock_ssm.get_parameter.call_count == 2

    # Assert - should allow because request is from CloudFront with valid API key
    assert result["policyDocument"]["Statement"][0]["Effect"] == "Allow"
    assert result["policyDocument"]["Statement"][0]["Resource"] == event["routeArn"]
    assert result["context"]["isAuthorized"] is True


def test_should_deny_access_when_from_cloudfront_with_invalid_api_key(lambda_context):
    # Arrange
    event = {
        "headers": {
            "x-api-key": "wrong-api-key-value",
            "x-origin-verify": "test-cloudfront-secret",
            "cloudfront-forwarded-proto": "https",  # CloudFront adds this header
        },
        "routeArn": "arn:aws:execute-api:us-east-1:123456789012:api-id/test-stage/GET/test-resource",
    }

    with patch.object(authorizer, "ssm") as mock_ssm:
        # Configure mock to return different values based on parameter name
        def get_parameter_side_effect(Name, WithDecryption=False):
            if Name == "/test-project/api-key":
                return {"Parameter": {"Value": "test-api-key-value"}}
            elif Name == "/test-project/cloudfront-secret":
                return {"Parameter": {"Value": "test-cloudfront-secret"}}
            raise Exception(f"Unexpected parameter name: {Name}")

        mock_ssm.get_parameter.side_effect = get_parameter_side_effect

        # Set the parameter names directly on the module
        authorizer.ssm_param_name = "/test-project/api-key"
        authorizer.cloudfront_secret_param_name = "/test-project/cloudfront-secret"

        # Act
        result = authorizer.lambda_handler(event, lambda_context)

        # Verify SSM parameter was called for both CloudFront secret and API key
        assert mock_ssm.get_parameter.call_count == 2

    # Assert - should deny because API key is invalid
    assert result["policyDocument"]["Statement"][0]["Effect"] == "Deny"
    assert result["policyDocument"]["Statement"][0]["Resource"] == event["routeArn"]
    assert result["context"]["isAuthorized"] is False


def test_should_deny_access_when_cloudfront_secret_is_invalid(lambda_context):
    # Arrange
    event = {
        "headers": {
            "x-api-key": "test-api-key-value",
            "x-origin-verify": "wrong-cloudfront-secret",
            "cloudfront-forwarded-proto": "https",  # CloudFront adds this header
        },
        "routeArn": "arn:aws:execute-api:us-east-1:123456789012:api-id/test-stage/GET/test-resource",
    }

    with patch.object(authorizer, "ssm") as mock_ssm:
        # Configure mock to return CloudFront secret
        mock_ssm.get_parameter.return_value = {
            "Parameter": {"Value": "test-cloudfront-secret"}
        }

        # Set the parameter names directly on the module
        authorizer.ssm_param_name = "/test-project/api-key"
        authorizer.cloudfront_secret_param_name = "/test-project/cloudfront-secret"

        # Act
        result = authorizer.lambda_handler(event, lambda_context)

        # Verify only CloudFront secret parameter was called (should fail before API key check)
        mock_ssm.get_parameter.assert_called_once_with(
            Name="/test-project/cloudfront-secret", WithDecryption=True
        )

    # Assert - should deny because CloudFront secret is invalid
    assert result["policyDocument"]["Statement"][0]["Effect"] == "Deny"
    assert result["policyDocument"]["Statement"][0]["Resource"] == event["routeArn"]
    assert result["context"]["isAuthorized"] is False


def test_should_deny_access_when_no_cloudfront_headers(lambda_context):
    # Arrange
    event = {
        "headers": {
            "x-api-key": "test-api-key-value",
            "x-origin-verify": "test-cloudfront-secret",
            # No CloudFront headers like cloudfront-*
        },
        "routeArn": "arn:aws:execute-api:us-east-1:123456789012:api-id/test-stage/GET/test-resource",
    }

    with patch.object(authorizer, "ssm") as mock_ssm:
        # Configure mock to return CloudFront secret
        mock_ssm.get_parameter.return_value = {
            "Parameter": {"Value": "test-cloudfront-secret"}
        }

        # Set the parameter names directly on the module
        authorizer.ssm_param_name = "/test-project/api-key"
        authorizer.cloudfront_secret_param_name = "/test-project/cloudfront-secret"

        # Act
        result = authorizer.lambda_handler(event, lambda_context)

        # Verify only CloudFront secret parameter was called
        mock_ssm.get_parameter.assert_called_once_with(
            Name="/test-project/cloudfront-secret", WithDecryption=True
        )

    # Assert - should deny because no CloudFront headers
    assert result["policyDocument"]["Statement"][0]["Effect"] == "Deny"
    assert result["policyDocument"]["Statement"][0]["Resource"] == event["routeArn"]
    assert result["context"]["isAuthorized"] is False


# --------------------------------------------------
# x-api-key Header
# --------------------------------------------------
def test_should_deny_access_when_api_key_is_missing(lambda_context):
    # Arrange
    event = {
        "headers": {
            "x-origin-verify": "test-cloudfront-secret",
            "cloudfront-forwarded-proto": "https",  # CloudFront adds this header
            # No x-api-key header
        },
        "routeArn": "arn:aws:execute-api:us-east-1:123456789012:api-id/test-stage/GET/test-resource",
    }

    with patch.object(authorizer, "ssm") as mock_ssm:
        # Configure mock to return CloudFront secret
        mock_ssm.get_parameter.return_value = {
            "Parameter": {"Value": "test-cloudfront-secret"}
        }

        # Set the parameter names directly on the module
        authorizer.ssm_param_name = "/test-project/api-key"
        authorizer.cloudfront_secret_param_name = "/test-project/cloudfront-secret"

        # Act
        result = authorizer.lambda_handler(event, lambda_context)

        # Verify only CloudFront secret parameter was called
        mock_ssm.get_parameter.assert_called_once_with(
            Name="/test-project/cloudfront-secret", WithDecryption=True
        )

    # Assert - should deny because API key is missing
    assert result["policyDocument"]["Statement"][0]["Effect"] == "Deny"
    assert result["policyDocument"]["Statement"][0]["Resource"] == event["routeArn"]
    assert result["context"]["isAuthorized"] is False
