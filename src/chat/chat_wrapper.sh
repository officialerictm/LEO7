#!/usr/bin/env bash

# Chat Wrapper - Provides location-aware chat interface
# Part of Leonardo AI Universal

# Ensure color variables are defined
: "${GREEN:=\033[32m}"
: "${CYAN:=\033[36m}"
: "${YELLOW:=\033[33m}"
: "${RED:=\033[31m}"
: "${DIM:=\033[2m}"
: "${BOLD:=\033[1m}"
: "${COLOR_RESET:=\033[0m}"

# Select Ollama instance
select_ollama_instance() {
    echo -e "\n${CYAN}Select Ollama Instance:${COLOR_RESET}\n"
    
    local host_status=$(detect_ollama_location | grep -q "Host" && echo "Available" || echo "Not Available")
    local usb_status=$(detect_ollama_location | grep -q "USB" && echo "Available" || echo "Not Available")
    
    echo -e "1) ${GREEN}Host Ollama${COLOR_RESET} ($host_status)"
    echo -e "2) ${CYAN}USB Ollama${COLOR_RESET} ($usb_status)"
    echo -e "3) ${YELLOW}Auto-detect${COLOR_RESET} (Use available instance)"
    echo
    
    read -p "Select option (1-3): " choice
    
    case "$choice" in
        1) echo "host" ;;
        2) echo "usb" ;;
        3|*) echo "auto" ;;
    esac
}

# Start chat with location awareness
start_location_aware_chat() {
    local model="${1:-}"
    local preference="${2:-auto}"
    
    # Get the appropriate endpoint
    local endpoint=$(get_ollama_endpoint "$preference")
    
    # Check if endpoint is available
    if ! curl -s "$endpoint/api/tags" >/dev/null 2>&1; then
        echo -e "${RED}Error: Selected Ollama instance is not available${COLOR_RESET}"
        echo -e "${YELLOW}Tip: Make sure Ollama is running on the selected system${COLOR_RESET}"
        return 1
    fi
    
    # If no model specified, let user select
    if [[ -z "$model" ]]; then
        echo -e "\n${CYAN}Available Models:${COLOR_RESET}\n"
        
        # List models from the selected endpoint
        local models=$(curl -s "$endpoint/api/tags" | jq -r '.models[].name' 2>/dev/null)
        
        if [[ -z "$models" ]]; then
            echo -e "${RED}No models found on selected instance${COLOR_RESET}"
            return 1
        fi
        
        # Show models with numbers
        local i=1
        local model_array=()
        while IFS= read -r m; do
            echo -e "$i) $m"
            model_array+=("$m")
            ((i++))
        done <<< "$models"
        
        echo
        read -p "Select model (1-$((i-1))): " model_choice
        
        if [[ "$model_choice" =~ ^[0-9]+$ ]] && (( model_choice > 0 && model_choice < i )); then
            model="${model_array[$((model_choice-1))]}"
        else
            echo -e "${RED}Invalid selection${COLOR_RESET}"
            return 1
        fi
    fi
    
    # Start chat with location prefix in prompt
    echo -e "\n${GREEN}Starting chat with $model...${COLOR_RESET}"
    echo -e "${DIM}Endpoint: $endpoint${COLOR_RESET}\n"
    
    # Export endpoint for ollama CLI
    export OLLAMA_HOST="$endpoint"
    
    # Create custom prompt with location prefix
    local location_prefix=$(get_chat_location_prefix "$endpoint" "$model")
    
    # Start interactive chat
    echo -e "${CYAN}═══════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}Leonardo AI Chat${COLOR_RESET} - ${DIM}Type 'exit' or Ctrl+C to quit${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    while true; do
        # Show custom prompt with location
        echo -ne "${BOLD}${location_prefix}${COLOR_RESET} > "
        read -r user_input
        
        # Check for exit
        if [[ "$user_input" == "exit" ]] || [[ "$user_input" == "quit" ]]; then
            break
        fi
        
        # Skip empty input
        if [[ -z "$user_input" ]]; then
            continue
        fi
        
        # Send to ollama
        echo -e "\n${DIM}Thinking...${COLOR_RESET}\n"
        
        # Use ollama run for interactive chat
        if command -v ollama >/dev/null 2>&1; then
            ollama run "$model" "$user_input"
        else
            # Fallback to API if ollama CLI not available
            local response=$(curl -s "$endpoint/api/generate" \
                -d "{\"model\": \"$model\", \"prompt\": \"$user_input\", \"stream\": false}" \
                | jq -r '.response' 2>/dev/null)
            
            if [[ -n "$response" ]]; then
                echo -e "$response"
            else
                echo -e "${RED}Error: Failed to get response${COLOR_RESET}"
            fi
        fi
        
        echo
    done
    
    echo -e "\n${GREEN}Chat session ended${COLOR_RESET}"
}

# Export functions
export -f select_ollama_instance
export -f start_location_aware_chat
