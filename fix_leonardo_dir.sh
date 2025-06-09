#!/usr/bin/env bash
# Patch script to fix LEONARDO_DIR issue in leonardo.sh

echo "Fixing LEONARDO_DIR unbound variable error..."

# Check if leonardo.sh exists
if [[ ! -f "leonardo.sh" ]]; then
    echo "Error: leonardo.sh not found in current directory"
    exit 1
fi

# Create backup
cp leonardo.sh leonardo.sh.backup
echo "Created backup: leonardo.sh.backup"

# Find the line with "echo \"Downloading from model registry...\" >&2"
LINE_NUM=$(grep -n "echo \"Downloading from model registry...\" >&2" leonardo.sh | head -1 | cut -d: -f1)

if [[ -z "$LINE_NUM" ]]; then
    echo "Error: Could not find the target line in leonardo.sh"
    exit 1
fi

echo "Found target at line $LINE_NUM"

# Create the patch content
PATCH_CONTENT='    # Set LEONARDO_DIR if not already set
    if [[ -z "${LEONARDO_DIR:-}" ]]; then
        # Try to determine the Leonardo installation directory
        if [[ -f "${LEONARDO_BASE_DIR}/src/models/registry_loader.sh" ]]; then
            LEONARDO_DIR="${LEONARDO_BASE_DIR}"
        elif [[ -f "${HOME}/.leonardo/src/models/registry_loader.sh" ]]; then
            LEONARDO_DIR="${HOME}/.leonardo"
        elif [[ -f "./src/models/registry_loader.sh" ]]; then
            LEONARDO_DIR="$(pwd)"
        else
            # Fallback - assume we are in the Leonardo directory
            LEONARDO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        fi
        export LEONARDO_DIR
    fi
    '

# Insert the patch after the target line
sed -i "${LINE_NUM}a\\
\\
    # Set LEONARDO_DIR if not already set\\
    if [[ -z \"\${LEONARDO_DIR:-}\" ]]; then\\
        # Try to determine the Leonardo installation directory\\
        if [[ -f \"\${LEONARDO_BASE_DIR}/src/models/registry_loader.sh\" ]]; then\\
            LEONARDO_DIR=\"\${LEONARDO_BASE_DIR}\"\\
        elif [[ -f \"\${HOME}/.leonardo/src/models/registry_loader.sh\" ]]; then\\
            LEONARDO_DIR=\"\${HOME}/.leonardo\"\\
        elif [[ -f \"./src/models/registry_loader.sh\" ]]; then\\
            LEONARDO_DIR=\"\$(pwd)\"\\
        else\\
            # Fallback - assume we are in the Leonardo directory\\
            LEONARDO_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd)\"\\
        fi\\
        export LEONARDO_DIR\\
    fi" leonardo.sh

echo "✓ Applied LEONARDO_DIR initialization fix"
echo ""
echo "The fix has been applied. You can now run:"
echo "  ./leonardo.sh"
echo ""
echo "To restore the original file:"
echo "  mv leonardo.sh.backup leonardo.sh"
