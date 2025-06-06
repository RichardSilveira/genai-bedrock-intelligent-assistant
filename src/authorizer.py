import json
import os
import boto3
from botocore.exceptions import ClientError
from aws_lambda_powertools import Logger

logger = Logger()
ssm = boto3.client("ssm")
ssm_param_name = os.environ.get("API_KEY_PARAM_NAME")


@logger.inject_lambda_context
def lambda_handler(event, context):
    logger.info("Processing authorization request")

    # Extract API key from the request header
    api_key = None
    if "headers" in event and event["headers"] is not None:
        api_key = event["headers"].get("x-api-key")

    if not api_key:
        logger.warning("No API key provided")
        return generate_policy("user", "Deny", event["routeArn"])

    # Get the valid API key from SSM Parameter Store
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
