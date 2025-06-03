import sys
import os
from pathlib import Path
import pytest
from dotenv import load_dotenv

root_dir = Path(__file__).parent.parent

# Load environment variables from a .env file if present (for local development/testing)
load_dotenv(dotenv_path=root_dir / ".env")

# Add the parent directory to sys.path
sys.path.insert(0, str(root_dir))
