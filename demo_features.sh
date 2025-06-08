#!/usr/bin/env bash
# Demo script to showcase new Leonardo features

# Colors
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
BLUE='\033[34m'
DIM='\033[2m'
BOLD='\033[1m'
COLOR_RESET='\033[0m'

clear
echo -e "${BOLD}Leonardo AI Universal - Feature Demo${COLOR_RESET}"
echo -e "${DIM}Demonstrating USB/HOST distinction and model search${COLOR_RESET}\n"

# Feature 1: Model Location Tags
echo -e "${CYAN}=== Feature 1: Model Location Tags ===${COLOR_RESET}"
echo -e "When selecting models for chat, you'll now see location tags:\n"
echo -e " 1) llama3.2:latest    ${BLUE}[HOST]${COLOR_RESET}     - Running on host computer"
echo -e " 2) phi:2.7b          ${GREEN}[USB]${COLOR_RESET}      - Available on USB drive"
echo -e " 3) mistral:7b        ${YELLOW}[REMOTE]${COLOR_RESET}   - Remote Ollama instance"
echo -e " 4) qwen2.5-3b        ${GREEN}[USB-ONLY]${COLOR_RESET} - Local GGUF file only\n"
echo -e "${DIM}This helps you choose where to run your AI models${COLOR_RESET}"

echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
read

# Feature 2: Dynamic Model Registry
echo -e "\n${CYAN}=== Feature 2: Dynamic Model Registry ===${COLOR_RESET}"
echo -e "Models are now loaded from a JSON registry file:"
echo -e "${DIM}data/models/gguf_registry.json${COLOR_RESET}\n"

if [[ -f "data/models/gguf_registry.json" ]]; then
    echo -e "Current registry contains:"
    jq -r '.models | to_entries[] | " - \(.key): \(.value.description // "No description")"' data/models/gguf_registry.json | head -5
    echo -e "${DIM}... and more${COLOR_RESET}"
fi

echo -e "\n${GREEN}✓${COLOR_RESET} Easy to add new models without code changes"
echo -e "${GREEN}✓${COLOR_RESET} Can be updated from online sources"
echo -e "${GREEN}✓${COLOR_RESET} Supports metadata like size and description"

echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
read

# Feature 3: Model Search
echo -e "\n${CYAN}=== Feature 3: Model Search Database ===${COLOR_RESET}"
echo -e "New menu option: ${BOLD}🔍 Search Model Database${COLOR_RESET}\n"
echo -e "Search features:"
echo -e " 1) ${YELLOW}HuggingFace Search${COLOR_RESET} - Find GGUF models by keyword"
echo -e " 2) ${BLUE}Ollama Library${COLOR_RESET} - Browse popular Ollama models"
echo -e " 3) ${GREEN}Combined Search${COLOR_RESET} - Search all sources at once"
echo -e " 4) ${CYAN}Update Registry${COLOR_RESET} - Pull latest model information\n"

echo -e "Example search results:"
echo -e "${DIM}Searching HuggingFace for 'code'...${COLOR_RESET}"
echo -e " 1) TheBloke/CodeLlama-7B-GGUF         ${DIM}↓12534 ♥89${COLOR_RESET} ${YELLOW}[codellama]${COLOR_RESET}"
echo -e " 2) TheBloke/WizardCoder-15B-GGUF      ${DIM}↓8923  ♥67${COLOR_RESET} ${YELLOW}[wizardcoder]${COLOR_RESET}"
echo -e " 3) deepseek-ai/deepseek-coder-GGUF    ${DIM}↓5678  ♥45${COLOR_RESET} ${YELLOW}[deepseek]${COLOR_RESET}"

echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
read

# Summary
echo -e "\n${CYAN}=== Summary of Improvements ===${COLOR_RESET}"
echo -e "${GREEN}✓${COLOR_RESET} Clear distinction between USB and HOST models"
echo -e "${GREEN}✓${COLOR_RESET} Dynamic model registry system"
echo -e "${GREEN}✓${COLOR_RESET} Integrated model search across multiple sources"
echo -e "${GREEN}✓${COLOR_RESET} Improved user control and transparency\n"

echo -e "${BOLD}Ready to test?${COLOR_RESET}"
echo -e "Run ${CYAN}./leonardo.sh${COLOR_RESET} to see these features in action!"
echo
