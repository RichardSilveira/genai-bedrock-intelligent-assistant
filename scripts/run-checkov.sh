#!/bin/bash
set -e

# Check if checkov is installed
if ! command -v checkov &>/dev/null; then
  echo "Checkov is not installed. Installing now..."
  pip install checkov
fi

# Capture staged Terraform files from lint-staged arguments
FILES=("$@")

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No .tf files passed to checkov."
  exit 0
fi

echo "Running Checkov on the following files:"
printf ' - %s\n' "${FILES[@]}"

# Run Checkov on each file individually
for file in "${FILES[@]}"; do
  checkov --file "$file" --quiet || exit 1
done

# #!/bin/bash

# # Check if checkov is installed
# if ! command -v checkov &> /dev/null; then
#     echo "Checkov is not installed. Installing now..."
#     pip install checkov
# fi

# # Run checkov on the iac directory
# echo "Running Checkov security scan on Terraform files..."
# checkov --directory iac --framework terraform

# # Exit with the same status code as checkov
# exit $?
