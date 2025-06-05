#!/usr/bin/env bash
# Demo: Portable USB Features
# Shows how to use Leonardo in stealth/portable mode

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
DIM='\033[2m'
RESET='\033[0m'

echo -e "${CYAN}=== Leonardo Portable USB Demo ===${RESET}"
echo
echo -e "${GREEN}New Features:${RESET}"
echo
echo "1. ${CYAN}Portable Ollama (Stealth Mode)${RESET}"
echo "   • Run AI models directly from USB"
echo "   • No installation required on host computer"
echo "   • Leaves no traces or files behind"
echo "   • Perfect for public/shared computers"
echo
echo "2. ${CYAN}Dynamic Model Registry${RESET}"
echo "   • Fetches live list of available models"
echo "   • Supports custom model registries"
echo "   • Always up-to-date with latest models"
echo "   • No more hardcoded model lists"
echo
echo -e "${YELLOW}Example Usage:${RESET}"
echo
echo "# Deploy to USB with portable mode:"
echo "$ ./leonardo.sh deploy usb"
echo "  > Select option 2 for 'Portable mode'"
echo "  > Models and Ollama will be installed on USB"
echo
echo "# Run from USB in stealth mode:"
echo "$ /media/usb/leonardo/tools/ollama/stealth-chat.sh"
echo "  > Starts private chat session"
echo "  > No files left on host computer"
echo
echo "# Use custom model registry:"
echo "$ export LEONARDO_MODEL_REGISTRY='https://my-models.com/registry.json'"
echo "$ ./leonardo.sh deploy usb"
echo
echo -e "${DIM}Note: Portable mode requires ~500MB extra space for Ollama${RESET}"
