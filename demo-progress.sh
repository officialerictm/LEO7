#!/bin/bash

# Demo script to showcase Leonardo progress tracking features

# Source Leonardo components
source ./leonardo.sh 2>/dev/null || {
    echo "Building leonardo.sh first..."
    ./assembly/build-simple.sh
}

echo -e "${CYAN}Leonardo AI Universal - Progress Tracking Demo${COLOR_RESET}"
echo "=============================================="
echo ""

# Demo 1: Progress Bar
echo -e "${YELLOW}1. Progress Bar Demo${COLOR_RESET}"
echo -n "Processing: "
for i in {0..100..5}; do
    printf "\r"
    show_progress_bar "$i" 100 40
    printf " ${i}%%  "
    sleep 0.1
done
echo ""
echo ""

# Demo 2: Download Progress (simulated)
echo -e "${YELLOW}2. Download Progress Demo${COLOR_RESET}"
echo "Simulating model download..."
echo ""

# Create a test file
dd if=/dev/urandom of=/tmp/test_model.bin bs=1M count=10 2>/dev/null

# Copy with progress
copy_with_progress "/tmp/test_model.bin" "/tmp/test_model_copy.bin" "Downloading llama3.2:3b"

echo ""

# Demo 3: Multi-task Progress
echo -e "${YELLOW}3. Multi-Task Progress Demo${COLOR_RESET}"
show_multi_progress "Model Download" 75 "complete"
show_multi_progress "Verification" 100 "complete"
show_multi_progress "Installation" 50 "active"
show_multi_progress "Configuration" 0 "pending"

echo ""

# Demo 4: Spinner Demo
echo -e "${YELLOW}4. Spinner Styles Demo${COLOR_RESET}"
for style in dots line box pulse matrix; do
    echo -n "Style '$style': "
    show_spinner "$style" &
    local spinner_pid=$!
    sleep 2
    stop_spinner $spinner_pid
    echo " Done"
done

echo ""

# Demo 5: Status Indicators
echo -e "${YELLOW}5. Status Indicators${COLOR_RESET}"
show_status "success" "Model downloaded successfully"
show_status "warning" "Low disk space detected"
show_status "error" "Network connection failed"
show_status "info" "Checking for updates..."

echo ""

# Demo 6: Countdown Timer
echo -e "${YELLOW}6. Countdown Timer Demo${COLOR_RESET}"
echo -n "Starting in: "
show_countdown 5

echo ""

# Demo 7: Matrix Effect
echo -e "${YELLOW}7. Matrix Rain Effect (5 seconds)${COLOR_RESET}"
echo "Press any key to skip..."
show_matrix_progress 5

# Cleanup
rm -f /tmp/test_model.bin /tmp/test_model_copy.bin

echo ""
echo -e "${GREEN}✓ Progress tracking demo complete!${COLOR_RESET}"
echo ""
echo "These progress indicators are now integrated into:"
echo "• Model downloads (leonardo model install)"
echo "• USB deployment (leonardo deploy usb)"
echo "• File operations"
echo ""
