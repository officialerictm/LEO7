#!/bin/bash
# Quick test for Leonardo fixes

echo "Testing Leonardo AI fixes..."
echo ""
echo "1. Check for LEONARDO_BASE_DIR:"
grep -n "LEONARDO_BASE_DIR" leonardo.sh | head -5

echo ""
echo "2. Check color variables in model menu:"
grep -n "Models installed:" leonardo.sh

echo ""
echo "3. Check web server path:"
grep -n "web_root=" leonardo.sh | grep -v "^#"

echo ""
echo "4. Testing model listing..."
./leonardo.sh model list | head -10

echo ""
echo "Done! Try running ./leonardo.sh to test the interactive menu."
