#!/usr/bin/env bash
# USB Model Availability Check
# Shows which models are available on USB vs. local system

# Source dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../utils/colors.sh"

# Check models on USB
check_usb_models() {
    local usb_path="${1:-$LEONARDO_USB_MOUNT}"
    local model_dir="$usb_path/leonardo/models"
    
    echo -e "${CYAN}=== Model Availability ===${COLOR_RESET}"
    echo
    
    # Check USB models
    echo -e "${BOLD}📁 Models on USB:${COLOR_RESET}"
    if [[ -d "$model_dir" ]]; then
        local model_count=0
        for model_file in "$model_dir"/*.gguf "$model_dir"/*.bin; do
            if [[ -f "$model_file" ]]; then
                local model_name=$(basename "$model_file")
                local model_size=$(du -h "$model_file" | cut -f1)
                echo -e "  ${GREEN}✓${COLOR_RESET} $model_name ($model_size)"
                ((model_count++))
            fi
        done
        
        if [[ $model_count -eq 0 ]]; then
            echo -e "  ${YELLOW}⚠ No models found on USB${COLOR_RESET}"
            echo -e "  ${DIM}Models must be downloaded to USB for portable use${COLOR_RESET}"
        fi
    else
        echo -e "  ${RED}✗ Model directory not found${COLOR_RESET}"
    fi
    
    echo
    
    # Check local Ollama models
    echo -e "${BOLD}💻 Models on this computer (Ollama):${COLOR_RESET}"
    if command -v ollama &> /dev/null; then
        local ollama_models=$(ollama list 2>/dev/null | tail -n +2)
        if [[ -n "$ollama_models" ]]; then
            while IFS= read -r line; do
                local model_name=$(echo "$line" | awk '{print $1}')
                local model_size=$(echo "$line" | awk '{print $3, $4}')
                echo -e "  ${BLUE}◆${COLOR_RESET} $model_name ($model_size)"
            done <<< "$ollama_models"
        else
            echo -e "  ${DIM}No Ollama models installed${COLOR_RESET}"
        fi
    else
        echo -e "  ${DIM}Ollama not installed${COLOR_RESET}"
    fi
    
    echo
    echo -e "${YELLOW}ℹ Note:${COLOR_RESET}"
    echo "  • USB models (✓) are portable and work on any computer"
    echo "  • Local models (◆) only work on this computer"
    echo "  • To make a model portable, export it to USB during deployment"
}

# Export function
export -f check_usb_models
