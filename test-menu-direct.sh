#!/usr/bin/env bash

# Test menu directly
echo "Testing menu directly..."

# Basic color setup
GREEN="\033[0;32m"
CYAN="\033[0;36m"
COLOR_RESET="\033[0m"
DIM="\033[2m"
BRIGHT="\033[1m"

# Menu position
MENU_POSITION=1

display_menu_frame() {
    local title="$1"
    shift
    local options=("$@")
    
    # Draw title box
    echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
    printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
    echo
    
    # Display options
    local i=1
    for option in "${options[@]}"; do
        if [[ $i -eq $MENU_POSITION ]]; then
            # Highlighted option
            echo -e "${CYAN}▶ ${BRIGHT}${option}${COLOR_RESET}"
        else
            echo -e "  ${DIM}${option}${COLOR_RESET}"
        fi
        ((i++))
    done
    
    echo
    echo -e "${DIM}Use ↑/↓ arrows or numbers to select, Enter to confirm, q to quit${COLOR_RESET}"
}

# Test the menu display
echo "About to display menu..."
display_menu_frame "Test Menu" "Option 1" "Option 2" "Option 3"

echo "Menu displayed. Testing input..."
echo "Press any key to continue..."
read -n1

echo "Test complete!"
