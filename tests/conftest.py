import sys
import os
from pathlib import Path
import pytest
from dotenv import load_dotenv

root_dir = Path(__file__).parent.parent

# Load environment variables from a .env file
load_dotenv(dotenv_path=root_dir / ".env")

# Add the parent directory to sys.path
sys.path.insert(0, str(root_dir))


class FakeContext:
    def __init__(self, **kwargs):
        self.function_name = kwargs.get("function_name", "test_lambda")
        self.memory_limit_in_mb = kwargs.get("memory_limit_in_mb", 128)
        self.invoked_function_arn = kwargs.get(
            "invoked_function_arn",
            "arn:aws:lambda:us-east-1:123456789012:function:test_lambda",
        )
        self.aws_request_id = kwargs.get("aws_request_id", "test-request-id")
        self.e2e_test_mode = kwargs.get("e2e_test_mode", False)
        # Add more attributes as needed


@pytest.fixture
def lambda_context():
    return FakeContext()
