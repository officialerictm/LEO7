#!/usr/bin/env bash
# Quick test of model search functionality

# Set up environment
export LEONARDO_DIR="/home/officialerictm/CascadeProjects/vibecoding/CascadeProjects/windsurf-project/LEO7"
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

# Create temp dir
mkdir -p "$LEONARDO_TEMP_DIR"

# Source logging
log_message() {
    echo "$2"
}

# Source the registry loader
source "$LEONARDO_DIR/src/models/registry_loader.sh"

# Test HuggingFace search
echo -e "${BOLD}Testing HuggingFace search for 'llama'...${COLOR_RESET}"
search_huggingface_models "llama" 10

echo
echo -e "${BOLD}Testing Ollama Library search...${COLOR_RESET}"
search_ollama_library "phi"

echo
echo -e "${BOLD}Testing local registry load...${COLOR_RESET}"
if load_local_registry; then
    echo -e "${GREEN}✓ Local registry loaded successfully${COLOR_RESET}"
    echo "Registry contains ${#LEONARDO_GGUF_REGISTRY[@]} models"
else
    echo -e "${RED}✗ Failed to load local registry${COLOR_RESET}"
fi
