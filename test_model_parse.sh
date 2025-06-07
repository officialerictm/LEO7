#!/bin/bash

# Test model parsing
test_model="mistral:7b"

echo "Original: '$test_model'"

# Parse model spec
model_id="${test_model%:*}"
variant="${test_model#*:}"

echo "Parsed model_id: '$model_id'"
echo "Parsed variant: '$variant'"

# Test case statement
case "${model_id}:${variant}" in
    "mistral:7b")
        echo "MATCH FOUND for mistral:7b"
        ;;
    *)
        echo "NO MATCH - looking for '${model_id}:${variant}'"
        ;;
esac

# Test with size annotation
test_with_size="mistral:7b (4GB)"
echo -e "\nTesting with size annotation: '$test_with_size'"

# Remove size annotation
cleaned="${test_with_size% (*}"
echo "After removing size: '$cleaned'"

# Clean up any carriage returns or trailing whitespace
cleaned2=$(echo "$cleaned" | tr -d '\r' | xargs)
echo "After cleanup: '$cleaned2'"
