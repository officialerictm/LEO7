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

# Export functions
export -f clear
