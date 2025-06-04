#!/usr/bin/env bash

# Simple test of the menu functionality

# Set TERM if not set
export TERM=${TERM:-xterm}

# Basic colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BRIGHT='\033[1m'
DIM='\033[2m'
COLOR_RESET='\033[0m'

# Simple menu display
echo "Testing simple menu display..."
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${GREEN}║${COLOR_RESET} Main Menu                                  ${GREEN}║${COLOR_RESET}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
echo ""
echo -e "${CYAN}▶ ${BRIGHT}AI Model Management${COLOR_RESET}"
echo -e "  ${DIM}Create/Manage USB Drive${COLOR_RESET}"
echo -e "  ${DIM}System Dashboard${COLOR_RESET}"
echo -e "  ${DIM}Launch Web Interface${COLOR_RESET}"
echo -e "  ${DIM}Exit${COLOR_RESET}"
echo ""
echo -e "${DIM}Use ↑/↓ arrows or numbers to select, Enter to confirm, q to quit${COLOR_RESET}"
echo ""
echo "If you see the menu above, the display is working!"
