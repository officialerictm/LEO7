#!/bin/bash
# Test calling deploy_to_usb directly

cd /home/officialerictm/CascadeProjects/vibecoding/CascadeProjects/windsurf-project/LEO7

# Source leonardo.sh to get all functions
source ./leonardo.sh

# Try calling deploy_to_usb directly
echo "=== Testing deploy_to_usb directly ==="
deploy_to_usb

echo ""
echo "=== Exit code: $? ==="
