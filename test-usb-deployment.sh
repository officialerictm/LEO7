#!/usr/bin/env bash
# Test USB deployment functionality

# Load only the utilities needed for this test
source src/utils/colors.sh
source src/utils/logging.sh
source src/utils/filesystem.sh
source src/usb/detector.sh
source src/usb/manager.sh
source src/deployment/usb_deploy.sh

# Minimal logging setup
export LEONARDO_LOG_DIR="/tmp"
export LEONARDO_AUDIT_LOG=false

echo -e "${CYAN}Testing USB Deployment Functions${COLOR_RESET}"
echo "================================="
echo ""

# Test 1: USB detection
echo "1. Testing USB detection..."
if command -v detect_usb_drives >/dev/null 2>&1; then
    echo -e "${GREEN}✓ detect_usb_drives function available${COLOR_RESET}"
else
    echo -e "${RED}✗ detect_usb_drives function not found${COLOR_RESET}"
fi

# Test 2: USB deployment function
echo "2. Testing USB deployment function..."
if command -v deploy_to_usb >/dev/null 2>&1; then
    echo -e "${GREEN}✓ deploy_to_usb function available${COLOR_RESET}"
else
    echo -e "${RED}✗ deploy_to_usb function not found${COLOR_RESET}"
fi

# Test 3: USB manager functions
echo "3. Testing USB manager functions..."
if command -v install_leonardo_to_usb >/dev/null 2>&1; then
    echo -e "${GREEN}✓ install_leonardo_to_usb function available${COLOR_RESET}"
else
    echo -e "${RED}✗ install_leonardo_to_usb function not found${COLOR_RESET}"
fi

# Test 4: List current USB drives
echo ""
echo "4. Current USB drives:"
list_usb_drives 2>/dev/null || echo -e "${YELLOW}No USB drives detected${COLOR_RESET}"

echo ""
echo "5. Testing directory creation under mount point..."
tmp_dir=$(mktemp -d)
export LEONARDO_USB_MOUNT="$tmp_dir"
create_leonardo_structure "$LEONARDO_USB_MOUNT"

if [[ -d "$LEONARDO_USB_MOUNT/leonardo/models" ]] && [[ -d "$LEONARDO_USB_MOUNT/leonardo/config" ]]; then
    echo -e "${GREEN}✓ Directory tree created at $LEONARDO_USB_MOUNT${COLOR_RESET}"
else
    echo -e "${RED}✗ Directory tree not created under $LEONARDO_USB_MOUNT${COLOR_RESET}"
fi

rm -rf "$tmp_dir"

echo ""
echo -e "${DIM}Test complete${COLOR_RESET}"
