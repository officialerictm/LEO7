#!/bin/bash
# Launch Leonardo AI with proper terminal settings

cd "$(dirname "$0")"

# Ensure we're in an interactive terminal
if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
    echo "Leonardo requires an interactive terminal."
    echo "Please run this script directly in a terminal, not through pipes or automation."
    exit 1
fi

# Set up terminal environment
export TERM="${TERM:-xterm}"
export LEONARDO_FORCE_INTERACTIVE=true

# Run Leonardo
exec ./leonardo.sh "$@"
