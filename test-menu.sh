#!/usr/bin/env bash

# Test script to verify menu is working

echo "Testing Leonardo Menu System..."
echo "Current terminal: $TERM"
echo "Is stdin a terminal? $([ -t 0 ] && echo 'Yes' || echo 'No')"
echo ""

# Run leonardo
./leonardo.sh
