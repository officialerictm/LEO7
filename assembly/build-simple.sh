#!/usr/bin/env bash
# Leonardo AI Universal - Simple Build Script (no dependencies)
# This is a simplified version that doesn't require yq

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="$PROJECT_ROOT/leonardo.sh"

echo -e "${CYAN}Leonardo AI Universal - Simple Assembler${NC}"
echo "Building leonardo.sh..."

# Start the output file
cat > "$OUTPUT_FILE" << 'EOF'
#!/usr/bin/env bash
# Leonardo AI Universal - Portable AI Deployment System
# Version: 7.0.0
# This file was automatically generated - DO NOT EDIT

set -euo pipefail

EOF

# Add components in order (simplified, based on manifest structure)
COMPONENTS=(
    "src/core/header.sh"
    "src/core/config.sh"
    "src/utils/colors.sh"
    "src/utils/logging.sh"
    "src/utils/validation.sh"
    "src/utils/filesystem.sh"
    "src/network/download.sh"
    "src/network/transfer.sh"
    "src/utils/network.sh"
    
    # USB modules
    "src/usb/detector.sh"
    "src/usb/manager.sh"
    "src/usb/health.sh"
    "src/usb/cli.sh"
    
    # UI modules
    "src/ui/menu.sh"
    "src/ui/progress.sh"
    "src/ui/dashboard.sh"
    "src/ui/web.sh"
    "src/core/main.sh"
)

# Assemble components
for component in "${COMPONENTS[@]}"; do
    component_path="$PROJECT_ROOT/$component"
    if [ -f "$component_path" ]; then
        echo -e "${BLUE}Adding${NC}: $component"
        echo -e "\n# ==== Component: $component ====" >> "$OUTPUT_FILE"
        # Skip the shebang line
        tail -n +2 "$component_path" >> "$OUTPUT_FILE"
    else
        echo -e "${BLUE}Creating stub for${NC}: $component"
        echo -e "\n# ==== Component: $component (STUB) ====" >> "$OUTPUT_FILE"
        echo "# TODO: Implement $component" >> "$OUTPUT_FILE"
    fi
done

# Add model management components
echo -e "${BLUE}Adding${NC}: src/models/registry.sh"
echo -e "\n# ==== Component: src/models/registry.sh ====" >> "$OUTPUT_FILE"
tail -n +2 "$PROJECT_ROOT/src/models/registry.sh" >> "$OUTPUT_FILE"

echo -e "${BLUE}Adding${NC}: src/models/manager.sh"
echo -e "\n# ==== Component: src/models/manager.sh ====" >> "$OUTPUT_FILE"
tail -n +2 "$PROJECT_ROOT/src/models/manager.sh" >> "$OUTPUT_FILE"

echo -e "${BLUE}Adding${NC}: src/models/selector.sh"
echo -e "\n# ==== Component: src/models/selector.sh ====" >> "$OUTPUT_FILE"
tail -n +2 "$PROJECT_ROOT/src/models/selector.sh" >> "$OUTPUT_FILE"

echo -e "${BLUE}Adding${NC}: src/models/cli.sh"
echo -e "\n# ==== Component: src/models/cli.sh ====" >> "$OUTPUT_FILE"
tail -n +2 "$PROJECT_ROOT/src/models/cli.sh" >> "$OUTPUT_FILE"

# Add footer
cat >> "$OUTPUT_FILE" << 'EOF'

# ==== Footer ====
# If main hasn't been called, call it now
if [ "${LEONARDO_MAIN_CALLED:-false}" = "false" ]; then
    main "$@"
fi
EOF

# Make executable
chmod +x "$OUTPUT_FILE"

echo -e "${GREEN}✓ Build complete!${NC}"
echo -e "Output: ${CYAN}$OUTPUT_FILE${NC}"
echo -e "Run ${CYAN}./leonardo.sh${NC} to start"
