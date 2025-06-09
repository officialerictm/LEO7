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

# Start the output file with shebang and header
cat > "$OUTPUT_FILE" << 'EOF'
#!/usr/bin/env bash
# Leonardo AI Universal - Portable AI Deployment System
# Version: 7.0.0
# This file was automatically generated - DO NOT EDIT

# Ensure TERM is set for terminal operations
if [[ -z "${TERM:-}" ]]; then
    export TERM=xterm
fi

EOF

# Components to build
COMPONENTS=(
    # Core components (required)
    "src/core/header.sh"
    "src/core/config.sh"
    
    # Utilities
    "src/utils/logging.sh"
    "src/utils/colors.sh"
    "src/utils/validation.sh"
    "src/utils/filesystem.sh"
    "src/utils/network.sh"
    "src/utils/terminal.sh"
    
    # System status tracking
    "src/core/system_status.sh"
    
    # UI components
    "src/ui/menu.sh"
    "src/ui/progress.sh"
    "src/ui/dashboard.sh"
    "src/ui/web.sh"
    "src/ui/web_server.sh"
    
    # Chat features
    "src/chat/chat_wrapper.sh"
    "src/chat/usb_inference.sh"
    
    # Security (stubs for now)
    "src/security/audit.sh"
    "src/security/memory.sh" 
    "src/security/encryption.sh"
    
    # Model management
    "src/models/model_database.sh"
    "src/models/registry.sh"
    "src/models/metadata.sh"
    "src/models/providers/ollama.sh"
    "src/models/manager.sh"
    "src/models/selector.sh"
    "src/models/cli.sh"
    
    # Deployment
    "src/deployment/validator.sh"
    "src/deployment/deployment.sh"
    "src/deployment/usb_deploy.sh"
    "src/deployment/cli.sh"
    
    # USB management
    "src/usb/detector.sh"
    "src/usb/manager.sh"
    "src/usb/health.sh"
    "src/usb/cli.sh"
    
    # Main entry point (must be last)
    "src/core/main.sh"
)

# Stub files to create if missing
STUB_FILES=(
    "src/security/audit.sh"
    "src/security/memory.sh"
    "src/security/encryption.sh"
    "src/deployment/validator.sh"
    "src/deployment/deployment.sh"
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
        if [[ " ${STUB_FILES[@]} " =~ " $component " ]]; then
            echo -e "${BLUE}Creating stub for${NC}: $component"
            echo -e "\n# ==== Component: $component (STUB) ====" >> "$OUTPUT_FILE"
            echo "# TODO: Implement $component" >> "$OUTPUT_FILE"
        else
            echo -e "${BLUE}Error: Missing component${NC}: $component"
            exit 1
        fi
    fi
done

# Add main call at the end
cat >> "$OUTPUT_FILE" << 'EOF'

# Call main function with all arguments
main "$@"
EOF

# Make executable
chmod +x "$OUTPUT_FILE"

echo -e "${GREEN}✓ Build complete!${NC}"
echo -e "Output: ${CYAN}$OUTPUT_FILE${NC}"
echo -e "Run ${CYAN}./leonardo.sh${NC} to start"
