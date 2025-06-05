#!/bin/bash
# Test USB deployment function

# Source Leonardo
source ./leonardo.sh

# Enable debug mode
set -x

# Call deploy_to_usb
deploy_to_usb

echo "Exit code: $?"
