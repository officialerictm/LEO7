#!/usr/bin/env bash
# Test script to verify LEONARDO_DIR fix

echo "Testing LEONARDO_DIR initialization..."

# Set up test environment
export LEONARDO_BASE_DIR="${HOME}/.leonardo"
export LEONARDO_MODEL_DIR="${LEONARDO_BASE_DIR}/models"

# Source just the problematic function
download_model_to_usb() {
    local model_id="${1:-}"
    local variant="${2:-latest}"
    local target_dir="${3:-${LEONARDO_MODEL_DIR}}"
    
    echo "Test: model_id=$model_id, variant=$variant"
    echo "Test: target_dir=$target_dir"
    
    echo "Downloading from model registry..." >&2
    
    # Set LEONARDO_DIR if not already set
    if [[ -z "${LEONARDO_DIR:-}" ]]; then
        echo "LEONARDO_DIR not set, initializing..."
        # Try to determine the Leonardo installation directory
        if [[ -f "${LEONARDO_BASE_DIR}/src/models/registry_loader.sh" ]]; then
            LEONARDO_DIR="${LEONARDO_BASE_DIR}"
        elif [[ -f "${HOME}/.leonardo/src/models/registry_loader.sh" ]]; then
            LEONARDO_DIR="${HOME}/.leonardo"
        elif [[ -f "./src/models/registry_loader.sh" ]]; then
            LEONARDO_DIR="$(pwd)"
        else
            # Fallback - assume we're in the Leonardo directory
            LEONARDO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        fi
        export LEONARDO_DIR
        echo "Set LEONARDO_DIR=$LEONARDO_DIR"
    fi
    
    # Load dynamic registry if available
    if [[ -f "${LEONARDO_DIR}/src/models/registry_loader.sh" ]]; then
        echo "✓ Would load registry from: ${LEONARDO_DIR}/src/models/registry_loader.sh"
    else
        echo "✗ Registry loader not found at: ${LEONARDO_DIR}/src/models/registry_loader.sh"
    fi
}

# Test the function
echo "Running test..."
download_model_to_usb "llama2" "7b"

echo
echo "Test complete. The fix should prevent the 'unbound variable' error."
