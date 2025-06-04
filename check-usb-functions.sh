#!/usr/bin/env bash
# Check if USB functions are available

# Source just the components we need
echo "Checking USB deployment capabilities..."

# Check if leonardo.sh has the deployment functions
echo ""
echo "1. Checking for deploy_to_usb function:"
if grep -q "deploy_to_usb()" leonardo.sh; then
    echo "✓ deploy_to_usb function found"
    grep -A5 "^deploy_to_usb()" leonardo.sh | head -10
else
    echo "✗ deploy_to_usb function not found"
fi

echo ""
echo "2. Checking for USB manager functions:"
if grep -q "install_leonardo_to_usb" leonardo.sh; then
    echo "✓ install_leonardo_to_usb function found"
else
    echo "✗ install_leonardo_to_usb function not found"
fi

echo ""
echo "3. Checking for USB device detection:"
if grep -q "detect_usb_drives" leonardo.sh; then
    echo "✓ detect_usb_drives function found"
else
    echo "✗ detect_usb_drives function not found"
fi

echo ""
echo "4. Checking deployment handler update:"
if grep -q "deploy_to_usb \"\$device\"" leonardo.sh; then
    echo "✓ Deployment handler properly calls deploy_to_usb"
else
    echo "✗ Deployment handler not updated"
fi

echo ""
echo "5. Checking available USB drives:"
lsblk -d -o NAME,SIZE,TYPE,TRAN | grep -E "(disk|usb)" || echo "No USB drives detected"
