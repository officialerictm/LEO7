#!/bin/bash
#
# Leonardo AI Universal - Terminal Utilities
# Safe terminal operations
#

# Override clear to handle missing TERM
clear() {
    if [[ -n "${TERM:-}" ]]; then
        command clear 2>/dev/null || true
    else
        # Fallback: just print newlines
        printf '\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n'
    fi
}

# Check if a command exists in PATH
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Export functions
export -f clear command_exists
