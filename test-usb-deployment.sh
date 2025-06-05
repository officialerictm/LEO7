#!/usr/bin/env bash
# Test USB deployment functionality

source leonardo.sh

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
    # Invoke help or dry-run to ensure it executes without error
    if deploy_to_usb --help >/dev/null 2>&1; then
        echo -e "${GREEN}✓ deploy_to_usb --help succeeded${COLOR_RESET}"
    else
        echo -e "${RED}✗ deploy_to_usb --help failed${COLOR_RESET}"
    fi
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

# Test 5: create_leonardo_structure with temporary directory
echo ""
echo "5. Testing create_leonardo_structure..."
temp_dir=$(mktemp -d)
if create_leonardo_structure "$temp_dir" >/dev/null 2>&1; then
    if [[ -d "$temp_dir/leonardo/models" && -d "$temp_dir/leonardo/config" ]]; then
        echo -e "${GREEN}✓ Directory structure created in temp dir${COLOR_RESET}"
    else
        echo -e "${RED}✗ Directory structure missing in temp dir${COLOR_RESET}"
    fi
else
    echo -e "${RED}✗ create_leonardo_structure command failed${COLOR_RESET}"
fi
rm -rf "$temp_dir"

echo ""
echo -e "${DIM}Test complete${COLOR_RESET}"
