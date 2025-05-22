#!/bin/bash
set -e

# Find all directories under 'iac' that contain .tf files
find ./iac -type f -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do
  echo "Generating docs for: $dir"
  terraform-docs markdown table --output-file README.md --output-mode inject "$dir"
done
