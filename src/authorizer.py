import json
import os
import boto3
from botocore.exceptions import ClientError
from aws_lambda_powertools import Logger

logger = Logger()
ssm = boto3.client("ssm")
ssm_param_name = os.environ.get("API_KEY_PARAM_NAME")
cloudfront_secret_param_name = os.environ.get("CLOUDFRONT_SECRET_PARAM_NAME")


@logger.inject_lambda_context
def lambda_handler(event, context):
    logger.info("Processing authorization request")

    # 1. Check if request is coming from CloudFront by verifying the custom header
    cloudfront_verified = verify_cloudfront_origin(event)
    if not cloudfront_verified:
        logger.warning("Request not from CloudFront - access denied")
        return generate_policy("user", "Deny", event["routeArn"])

    # 2. Extract API key from the request header
    api_key = None
    if "headers" in event and event["headers"] is not None:
        api_key = event["headers"].get("x-api-key")

    if not api_key:
        logger.warning("No API key provided")
        return generate_policy("user", "Deny", event["routeArn"])

    # 3. Get the valid API key from SSM Parameter Store
    try:
        response = ssm.get_parameter(Name=ssm_param_name, WithDecryption=True)
        valid_api_key = response["Parameter"]["Value"]

        if api_key == valid_api_key:
            logger.info("API key is valid")
            return generate_policy("user", "Allow", event["routeArn"])
        else:
            logger.warning("Invalid API key provided")
            return generate_policy("user", "Deny", event["routeArn"])

    except ClientError as e:
        logger.error(f"Error retrieving API key from SSM: {e}")
        return generate_policy("user", "Deny", event["routeArn"])


def verify_cloudfront_origin(event):
    """
    Verify that the request is coming from our CloudFront distribution
    by checking for the custom header we set.
    """
    try:
        # Check for custom header that only our CloudFront distribution knows
        headers = event.get("headers", {}) or {}
        origin_verify_header = headers.get("x-origin-verify")

        if not origin_verify_header:
            logger.warning("Missing X-Origin-Verify header")
            return False

        # Get the expected secret from SSM
        response = ssm.get_parameter(
            Name=cloudfront_secret_param_name, WithDecryption=True
        )
        expected_secret = response["Parameter"]["Value"]

        # Compare the header value with our secret
        if origin_verify_header != expected_secret:
            logger.warning("Invalid X-Origin-Verify header value")
            return False

        # Additional check: Verify CloudFront headers are present
        # CloudFront adds these headers automatically
        has_cloudfront_headers = False
        for header_name in headers:
            if header_name.lower().startswith("cloudfront-"):
                has_cloudfront_headers = True
                break

        if not has_cloudfront_headers:
            logger.warning("No CloudFront headers found in request")
            return False

        return True

    except ClientError as e:
        logger.error(f"Error retrieving CloudFront secret from SSM: {e}")
        return False
    except Exception as e:
        logger.error(f"Error verifying CloudFront origin: {e}")
        return False


def generate_policy(principal_id, effect, resource):
    """
    Generate an IAM policy document for API Gateway authorization
    """
    auth_response = {
        "principalId": principal_id,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {"Action": "execute-api:Invoke", "Effect": effect, "Resource": resource}
            ],
        },
    }

    # Additional context (optional)
    auth_response["context"] = {"isAuthorized": effect == "Allow"}

    return auth_response
