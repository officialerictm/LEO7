#!/bin/bash
source ./leonardo.sh > /dev/null 2>&1
# Override main to prevent it running
LEONARDO_MAIN_CALLED=true

# Just display the menu frame once
display_menu_frame "Main Menu" "AI Model Management" "Create/Manage USB Drive" "System Dashboard" "Launch Web Interface" "Settings & Preferences" "Run System Tests" "About Leonardo" "Exit"
echo
echo "The menu above would be interactive in the actual program."
echo "Use arrow keys to navigate and Enter to select."
