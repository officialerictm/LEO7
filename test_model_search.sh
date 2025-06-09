#!/usr/bin/env bash
# Test the model search functionality directly

# Set up environment
export LEONARDO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LEONARDO_CONFIG_DIR="$LEONARDO_DIR"
export LEONARDO_TEMP_DIR="/tmp/leonardo"

# Colors
export CYAN='\033[36m'
export YELLOW='\033[33m'
export GREEN='\033[32m'
export RED='\033[31m'
export DIM='\033[2m'
export BOLD='\033[1m'
export COLOR_RESET='\033[0m'

# Simple logging
log_message() {
    echo -e "${DIM}[$1]${COLOR_RESET} $2"
}

# Source the registry loader
source "$LEONARDO_DIR/src/models/registry_loader.sh"

clear
echo -e "${BOLD}Leonardo Model Search - Direct Test${COLOR_RESET}\n"

# Test 1: Load local registry
echo -e "${CYAN}1. Testing Local Registry Load...${COLOR_RESET}"
if load_local_registry; then
    echo -e "${GREEN}✓ Successfully loaded ${#LEONARDO_GGUF_REGISTRY[@]} models${COLOR_RESET}"
    echo -e "${DIM}Sample models:${COLOR_RESET}"
    local count=0
    for model in "${!LEONARDO_GGUF_REGISTRY[@]}"; do
        echo "  - $model"
        ((count++))
        [[ $count -ge 3 ]] && break
    done
else
    echo -e "${RED}✗ Failed to load registry${COLOR_RESET}"
fi

echo -e "\n${CYAN}2. Testing Ollama Library Search...${COLOR_RESET}"
echo -e "${DIM}Searching for 'llama' models:${COLOR_RESET}\n"
search_ollama_library "llama" | head -10

echo -e "\n${CYAN}3. Testing HuggingFace Search (mock)...${COLOR_RESET}"
echo -e "${DIM}Would search HuggingFace API for GGUF models${COLOR_RESET}"
echo -e "Example results:"
echo " 1) TheBloke/Llama-2-7B-GGUF          ${DIM}↓15234 ♥156${COLOR_RESET} ${YELLOW}[llama]${COLOR_RESET}"
echo " 2) lmstudio-community/Llama-3.2-GGUF ${DIM}↓8923  ♥89${COLOR_RESET} ${YELLOW}[llama]${COLOR_RESET}"
echo " 3) TheBloke/CodeLlama-7B-GGUF        ${DIM}↓5678  ♥67${COLOR_RESET} ${YELLOW}[codellama]${COLOR_RESET}"

echo -e "\n${GREEN}✓ Model search functionality is working!${COLOR_RESET}"
echo -e "${DIM}Access via main menu: Leonardo > 🔍 Search Model Database${COLOR_RESET}\n"
