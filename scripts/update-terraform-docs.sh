#!/bin/bash
set -e

# Assume this script is run from project root
pushd iac
terraform-docs markdown table --output-file README.md --output-mode inject .
popd
