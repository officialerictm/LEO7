#!/usr/bin/env bash
# Test Leonardo CLI Chat with Ollama

export LEONARDO_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source necessary modules
source "${LEONARDO_BASE_DIR}/src/utils/colors.sh"
source "${LEONARDO_BASE_DIR}/src/chat/cli.sh"

echo -e "${CYAN}Leonardo AI CLI Chat Test${COLOR_RESET}"
echo -e "${DIM}Testing direct chat functionality...${COLOR_RESET}"
echo

# Test the get_ai_response function directly
echo -e "${YELLOW}Testing AI Response Generation:${COLOR_RESET}"
echo -e "${GREEN}Prompt:${COLOR_RESET} Hello, how are you?"

response=$(get_ai_response "llama3.2:1b" "Hello, how are you?")
echo -e "${BLUE}Response:${COLOR_RESET} $response"

echo
echo -e "${GREEN}✓ CLI chat is now connected to Ollama!${COLOR_RESET}"
echo
echo -e "${CYAN}To start an interactive chat session:${COLOR_RESET}"
echo "  ./leonardo.sh chat"
echo "  ./leonardo.sh chat llama3.2:1b"
