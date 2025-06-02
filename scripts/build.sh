#!/bin/zsh
set -e

# Usage: ./build.sh <lambda_name>
# Example: ./build.sh chatbot

if [ -z "$1" ]; then
  echo "Usage: $0 <lambda_name>"
  exit 1
fi

LAMBDA_NAME="$1"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC_DIR="$PROJECT_ROOT/src"
DIST_DIR="$PROJECT_ROOT/dist"
LAMBDA_FILE="$SRC_DIR/${LAMBDA_NAME}.py"

if [ ! -f "$LAMBDA_FILE" ]; then
  echo "Lambda source file not found: $LAMBDA_FILE"
  exit 1
fi

rm -rf "$DIST_DIR/${LAMBDA_NAME}.zip" build
mkdir -p build/python "$DIST_DIR"
python3 -m venv build/venv
source build/venv/bin/activate
pip install --upgrade pip
pip install -r "$PROJECT_ROOT/requirements.txt" -t build/python
cp "$LAMBDA_FILE" build/python/
cd build/python
zip -r "$DIST_DIR/${LAMBDA_NAME}.zip" .
deactivate
cd ../..
rm -rf build

echo "Lambda package created at: $DIST_DIR/${LAMBDA_NAME}.zip"
