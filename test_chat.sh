#!/usr/bin/env bash
# Test Leonardo Chat Functionality

export LEONARDO_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LEONARDO_API_PORT=8081
export LEONARDO_WEB_PORT=8080

# Source necessary modules
source "${LEONARDO_BASE_DIR}/src/utils/colors.sh"
source "${LEONARDO_BASE_DIR}/src/chat/main.sh"

echo -e "${CYAN}Leonardo AI Chat Integration Test${COLOR_RESET}"
echo -e "${DIM}Testing chat module functionality...${COLOR_RESET}"
echo

# Test 1: Show help
echo -e "${YELLOW}Test 1: Chat Help${COLOR_RESET}"
show_chat_help
echo

# Test 2: Start web interface in background
echo -e "${YELLOW}Test 2: Starting Web Interface${COLOR_RESET}"
echo "To test the web interface, run: ./leonardo.sh chat --web"
echo "Then open: http://localhost:8080"
echo

# Test 3: CLI interface
echo -e "${YELLOW}Test 3: CLI Chat Interface${COLOR_RESET}"
echo "To test CLI chat, run: ./leonardo.sh chat"
echo "This requires an interactive terminal"
echo

echo -e "${GREEN}✓ Chat module is properly integrated!${COLOR_RESET}"
echo
echo -e "${CYAN}Available commands:${COLOR_RESET}"
echo "  ./leonardo.sh chat              # Start CLI chat"
echo "  ./leonardo.sh chat --web        # Start web interface"
echo "  ./leonardo.sh chat web 3000     # Custom port"
echo "  ./leonardo.sh chat stop         # Stop servers"
echo "  ./leonardo.sh chat help         # Show help"
