#!/bin/bash
# Script to reproduce the Leonardo syntax error issue

echo "Leonardo Syntax Error Reproduction Script"
echo "========================================"
echo

# Clean up any existing build
echo "1. Cleaning up old build..."
rm -f leonardo.sh

# Rebuild
echo "2. Building Leonardo..."
bash assembly/build-simple.sh

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo "✓ Build completed successfully"
else
    echo "✗ Build failed"
    exit 1
fi

# Try to run Leonardo
echo "3. Running Leonardo (expecting syntax error)..."
echo
./leonardo.sh

# The error should appear above
echo
echo "If you see syntax errors above, the issue is reproduced."
echo "See ISSUE_SYNTAX_ERRORS.md for details on fixes attempted."
