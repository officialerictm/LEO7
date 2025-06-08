#!/bin/bash
# Leonardo USB Starter - Ensures proper environment for USB deployment

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Auto-detect USB mount point
if [[ "$SCRIPT_DIR" =~ ^(/media/[^/]+/[^/]+)/.* ]] || \
   [[ "$SCRIPT_DIR" =~ ^(/mnt/[^/]+)/.* ]] || \
   [[ "$SCRIPT_DIR" =~ ^(/run/media/[^/]+/[^/]+)/.* ]] || \
   [[ "$SCRIPT_DIR" =~ ^(/Volumes/[^/]+)/.* ]]; then
    export LEONARDO_USB_MOUNT="${BASH_REMATCH[1]}"
else
    # Fallback: assume the USB root is the parent of leonardo directory
    export LEONARDO_USB_MOUNT="${SCRIPT_DIR%/leonardo*}"
fi

# Set USB mode
export LEONARDO_USB_MODE="true"
export LEONARDO_DIR="${LEONARDO_USB_MOUNT}/leonardo"
export LEONARDO_MODEL_DIR="${LEONARDO_USB_MOUNT}/leonardo/models"
export LEONARDO_CONFIG_DIR="${LEONARDO_USB_MOUNT}/leonardo/config"

# Show detected paths
echo "Leonardo AI Universal - USB Mode"
echo "================================"
echo "USB Mount: ${LEONARDO_USB_MOUNT}"
echo "Leonardo Dir: ${LEONARDO_DIR}"
echo "Models Dir: ${LEONARDO_MODEL_DIR}"
echo

# Check if leonardo.sh exists
if [[ -f "${LEONARDO_DIR}/leonardo.sh" ]]; then
    # Make it executable
    chmod +x "${LEONARDO_DIR}/leonardo.sh"
    
    # Run Leonardo with all arguments passed through
    exec "${LEONARDO_DIR}/leonardo.sh" "$@"
else
    echo "Error: leonardo.sh not found at ${LEONARDO_DIR}/leonardo.sh"
    echo "Please ensure Leonardo is properly deployed to this USB drive."
    exit 1
fi
