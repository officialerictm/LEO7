#!/usr/bin/env bash

# Debug version to find where Leonardo is getting stuck

echo "DEBUG: Starting Leonardo debug..."
echo "DEBUG: Terminal: $(tty || echo 'not a tty')"
echo "DEBUG: TERM=$TERM"
echo ""

# Run leonardo with some debug output
bash -x ./leonardo.sh 2>&1 | head -100
