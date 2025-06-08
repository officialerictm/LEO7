#!/usr/bin/env bash
# Leonardo AI Universal - Fixed Launcher
# This wrapper sets LEONARDO_DIR to prevent unbound variable errors

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Export LEONARDO_DIR to the script location
export LEONARDO_DIR="$SCRIPT_DIR"

# Also set it as LEONARDO_BASE_DIR if not already set
export LEONARDO_BASE_DIR="${LEONARDO_BASE_DIR:-$SCRIPT_DIR}"

echo "Starting Leonardo with LEONARDO_DIR=$LEONARDO_DIR"

# Run the main leonardo script
exec "$SCRIPT_DIR/leonardo.sh" "$@"
