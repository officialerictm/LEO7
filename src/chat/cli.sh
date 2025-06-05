#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - CLI Chat Interface
# ==============================================================================
# Description: Interactive CLI chat interface for AI models
# Version: 7.0.0
# ==============================================================================

# Chat interface using Ollama
chat_with_ollama() {
    local model="$1"
    local model_name="${model#ollama:}"
    
    # Check if model is installed
    if ! ollama list 2>/dev/null | grep -q "^${model_name}"; then
        echo -e "${RED}Error: Model '${model_name}' is not installed${COLOR_RESET}"
        echo -e "${YELLOW}Install it with: leonardo model install ${model}${COLOR_RESET}"
        return 1
    fi
    
    # Clear screen and show header
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "               ${BOLD}🤖 Leonardo AI Chat - ${model_name}${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo
    echo -e "${DIM}Commands:${COLOR_RESET}"
    echo -e "  ${GREEN}/exit${COLOR_RESET} or ${GREEN}/quit${COLOR_RESET} - End chat session"
    echo -e "  ${GREEN}/clear${COLOR_RESET} - Clear conversation history"
    echo -e "  ${GREEN}/save [filename]${COLOR_RESET} - Save conversation"
    echo -e "  ${GREEN}/help${COLOR_RESET} - Show this help"
    echo
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${COLOR_RESET}"
    echo
    
    # Start Ollama chat
    ollama run "$model_name"
}

# Chat interface for local models (llama.cpp)
chat_with_local_model() {
    local model_path="$1"
    local model_name=$(basename "$model_path")
    
    # Check if model exists
    if [[ ! -f "$model_path" ]]; then
        echo -e "${RED}Error: Model file not found: $model_path${COLOR_RESET}"
        return 1
    fi
    
    # Check for llama.cpp
    local llamacpp_path="${LEONARDO_BASE_DIR}/tools/llama.cpp/main"
    if [[ ! -f "$llamacpp_path" ]]; then
        echo -e "${YELLOW}llama.cpp not found. Installing...${COLOR_RESET}"
        install_llamacpp || return 1
    fi
    
    # Clear screen and show header
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "               ${BOLD}🤖 Leonardo AI Chat - ${model_name}${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo
    echo -e "${DIM}Using llama.cpp for inference${COLOR_RESET}"
    echo -e "${DIM}Model: $model_path${COLOR_RESET}"
    echo
    echo -e "${CYAN}───────────────────────────────────────────────────────────────${COLOR_RESET}"
    echo
    
    # Start llama.cpp interactive mode
    "$llamacpp_path" \
        -m "$model_path" \
        -n -1 \
        --interactive \
        --interactive-first \
        -r "User:" \
        --in-prefix " " \
        -i \
        --color \
        -c 2048
}

# Enhanced chat interface with conversation management
chat_enhanced() {
    local model="$1"
    local conversation_file="${LEONARDO_BASE_DIR}/conversations/$(date +%Y%m%d_%H%M%S).txt"
    local save_conversation=false
    
    # Create conversations directory
    mkdir -p "${LEONARDO_BASE_DIR}/conversations"
    
    # Trap to save conversation on exit
    trap 'save_conversation_on_exit' EXIT
    
    # Clear screen and show header
    clear
    show_chat_header "$model"
    
    # Start chat loop
    local user_input=""
    local conversation_history=""
    
    while true; do
        # Prompt for user input
        echo -ne "${GREEN}You:${COLOR_RESET} "
        read -r user_input
        
        # Handle commands
        case "$user_input" in
            "/exit"|"/quit")
                echo -e "${YELLOW}Ending chat session...${COLOR_RESET}"
                break
                ;;
            "/clear")
                clear
                show_chat_header "$model"
                conversation_history=""
                echo -e "${YELLOW}Conversation cleared${COLOR_RESET}"
                continue
                ;;
            "/save"*)
                local filename="${user_input#/save }"
                save_conversation "$conversation_history" "$filename"
                continue
                ;;
            "/help")
                show_chat_help
                continue
                ;;
            "")
                continue
                ;;
        esac
        
        # Add to conversation history
        conversation_history+="User: $user_input\n"
        
        # Get AI response
        echo -ne "${BLUE}AI:${COLOR_RESET} "
        local response=$(get_ai_response "$model" "$user_input")
        echo "$response"
        
        # Add to conversation history
        conversation_history+="AI: $response\n\n"
    done
}

# Show chat header
show_chat_header() {
    local model="$1"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "               ${BOLD}🤖 Leonardo AI Chat${COLOR_RESET}"
    echo -e "               ${DIM}Model: $model${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo
}

# Show chat help
show_chat_help() {
    echo
    echo -e "${CYAN}Chat Commands:${COLOR_RESET}"
    echo -e "  ${GREEN}/exit${COLOR_RESET} or ${GREEN}/quit${COLOR_RESET} - End chat session"
    echo -e "  ${GREEN}/clear${COLOR_RESET} - Clear conversation history"
    echo -e "  ${GREEN}/save [filename]${COLOR_RESET} - Save conversation"
    echo -e "  ${GREEN}/help${COLOR_RESET} - Show this help"
    echo
}

# Get AI response (stub - implement based on model type)
get_ai_response() {
    local model="$1"
    local prompt="$2"
    
    # Check if Ollama is available
    if command -v ollama &> /dev/null; then
        # Use Ollama for inference
        local response=$(ollama run "$model" <<< "$prompt" 2>&1)
        
        # Check if model needs to be pulled
        if [[ "$response" =~ "pulling" ]] || [[ "$response" =~ "Error" ]]; then
            echo -e "${DIM}Model not found locally. Pulling $model...${COLOR_RESET}" >&2
            ollama pull "$model" >&2
            response=$(ollama run "$model" <<< "$prompt" 2>&1)
        fi
        
        echo "$response"
    elif [[ -f "${LEONARDO_BASE_DIR}/tools/llama.cpp/main" ]]; then
        # Use local llama.cpp
        local model_path="${LEONARDO_BASE_DIR}/models/$model"
        if [[ -f "$model_path" ]]; then
            "${LEONARDO_BASE_DIR}/tools/llama.cpp/main" -m "$model_path" -p "$prompt" --temp 0.7 -n 512 2>/dev/null
        else
            echo "Model file not found: $model_path"
        fi
    else
        echo "No inference backend available. Please install Ollama or llama.cpp."
    fi
}

# Save conversation
save_conversation() {
    local content="$1"
    local filename="${2:-conversation_$(date +%Y%m%d_%H%M%S).txt}"
    
    if [[ ! "$filename" =~ \.txt$ ]]; then
        filename="${filename}.txt"
    fi
    
    local filepath="${LEONARDO_BASE_DIR}/conversations/$filename"
    echo -e "$content" > "$filepath"
    echo -e "${GREEN}✓ Conversation saved to: $filepath${COLOR_RESET}"
}

# Install llama.cpp
install_llamacpp() {
    local tools_dir="${LEONARDO_BASE_DIR}/tools"
    mkdir -p "$tools_dir"
    
    echo -e "${CYAN}Installing llama.cpp...${COLOR_RESET}"
    
    cd "$tools_dir" || return 1
    
    # Clone llama.cpp
    if [[ -d "llama.cpp" ]]; then
        cd llama.cpp
        git pull
    else
        git clone https://github.com/ggerganov/llama.cpp.git
        cd llama.cpp || return 1
    fi
    
    # Build
    make -j$(nproc) || {
        echo -e "${RED}Failed to build llama.cpp${COLOR_RESET}"
        return 1
    }
    
    echo -e "${GREEN}✓ llama.cpp installed successfully${COLOR_RESET}"
    return 0
}

# Main chat function
start_chat() {
    local model="${1:-}"
    
    # If no model specified, let user choose
    if [[ -z "$model" ]]; then
        model=$(select_installed_model)
        [[ -z "$model" ]] && return 1
    fi
    
    # Start appropriate chat interface
    if [[ "$model" == ollama:* ]]; then
        chat_with_ollama "$model"
    elif [[ "$model" == local:* ]]; then
        local model_path="${model#local:}"
        chat_with_local_model "$model_path"
    else
        chat_enhanced "$model"
    fi
}

# Export functions
export -f start_chat
export -f chat_with_ollama
export -f chat_with_local_model
export -f chat_enhanced
