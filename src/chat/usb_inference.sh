#!/bin/bash
# USB Inference Engine - Portable GGUF model runner
# Part of Leonardo AI Universal - Stealth Mode

# Ensure color variables are defined
: "${GREEN:=\033[32m}"
: "${CYAN:=\033[36m}"
: "${YELLOW:=\033[33m}"
: "${RED:=\033[31m}"
: "${DIM:=\033[2m}"
: "${BOLD:=\033[1m}"
: "${COLOR_RESET:=\033[0m}"
: "${BLUE:=\033[34m}"

# Check for portable llama.cpp on USB
check_portable_inference() {
    local usb_mount="${LEONARDO_USB_MOUNT:-/media/$USER/LEONARDO}"
    local llama_cpp_path="$usb_mount/leonardo/bin/llama-cli"
    
    if [[ -f "$llama_cpp_path" && -x "$llama_cpp_path" ]]; then
        echo "$llama_cpp_path"
        return 0
    fi
    return 1
}

# Download and setup portable llama.cpp on USB
setup_portable_inference() {
    local usb_mount="${LEONARDO_USB_MOUNT:-/media/$USER/LEONARDO}"
    local bin_dir="$usb_mount/leonardo/bin"
    local temp_dir="$usb_mount/leonardo/tmp"
    
    echo -e "${CYAN}Setting up portable inference engine...${COLOR_RESET}"
    
    # Create directories
    mkdir -p "$bin_dir" "$temp_dir"
    
    # Detect system architecture
    local arch=$(uname -m)
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    # Map architecture names
    case "$arch" in
        x86_64) arch="x64" ;;
        aarch64) arch="arm64" ;;
        armv7l) arch="arm" ;;
    esac
    
    # Download pre-built llama.cpp binary
    local download_url=""
    case "$os" in
        linux)
            download_url="https://github.com/ggerganov/llama.cpp/releases/latest/download/llama-cli-linux-$arch"
            ;;
        darwin)
            download_url="https://github.com/ggerganov/llama.cpp/releases/latest/download/llama-cli-macos-$arch"
            ;;
        *)
            echo -e "${RED}Unsupported OS: $os${COLOR_RESET}"
            return 1
            ;;
    esac
    
    echo -e "${DIM}Downloading llama.cpp for $os-$arch...${COLOR_RESET}"
    
    # Download with progress
    if command -v wget >/dev/null 2>&1; then
        wget -q --show-progress -O "$bin_dir/llama-cli" "$download_url"
    elif command -v curl >/dev/null 2>&1; then
        curl -L --progress-bar -o "$bin_dir/llama-cli" "$download_url"
    else
        echo -e "${RED}Neither wget nor curl found. Cannot download.${COLOR_RESET}"
        return 1
    fi
    
    # Make executable
    chmod +x "$bin_dir/llama-cli"
    
    echo -e "${GREEN}✓ Portable inference engine installed${COLOR_RESET}"
    return 0
}

# Run GGUF model using portable llama.cpp
run_gguf_inference() {
    local model_path="$1"
    local prompt="$2"
    local max_tokens="${3:-512}"
    
    local llama_path=$(check_portable_inference)
    if [[ -z "$llama_path" ]]; then
        if ! setup_portable_inference; then
            return 1
        fi
        llama_path=$(check_portable_inference)
    fi
    
    # Run inference with basic parameters
    "$llama_path" \
        -m "$model_path" \
        -p "$prompt" \
        -n "$max_tokens" \
        --temp 0.7 \
        --top-k 40 \
        --top-p 0.95 \
        --repeat-penalty 1.1 \
        --ctx-size 2048 \
        --no-display-prompt \
        2>/dev/null
}

# Interactive chat session using portable inference
run_portable_chat() {
    local model_path="$1"
    local model_name=$(basename "$model_path" .gguf)
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}               🤖 Leonardo AI Chat - USB Mode                ${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${DIM}Model: $model_name${COLOR_RESET}"
    echo -e "${DIM}Running in stealth mode - no host traces${COLOR_RESET}"
    echo
    echo -e "Type 'exit' to quit, 'clear' to clear screen\n"
    
    # Check/setup inference engine
    local llama_path=$(check_portable_inference)
    if [[ -z "$llama_path" ]]; then
        echo -e "${YELLOW}First time setup - downloading portable inference engine...${COLOR_RESET}"
        if ! setup_portable_inference; then
            echo -e "${RED}Failed to setup inference engine${COLOR_RESET}"
            return 1
        fi
        llama_path=$(check_portable_inference)
    fi
    
    # Initialize conversation context
    local context=""
    local system_prompt="You are a helpful AI assistant running locally on a USB drive. You provide accurate, thoughtful responses while respecting user privacy."
    
    # Chat loop
    while true; do
        # Get user input
        read -p $'\n\033[36mYou:\033[0m ' user_input
        
        # Handle commands
        case "$user_input" in
            exit|quit|bye)
                echo -e "\n${CYAN}Chat ended. Thank you!${COLOR_RESET}"
                break
                ;;
            clear|cls)
                clear
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
                echo -e "${BOLD}               🤖 Leonardo AI Chat - USB Mode                ${COLOR_RESET}"
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
                continue
                ;;
        esac
        
        # Build prompt with context
        local full_prompt="$system_prompt

$context
User: $user_input
Assistant:"
        
        # Show thinking indicator
        echo -ne "\n${GREEN}$model_name:${COLOR_RESET} ${DIM}Thinking...${COLOR_RESET}\r"
        
        # Run inference
        local response=$("$llama_path" \
            -m "$model_path" \
            -p "$full_prompt" \
            -n 512 \
            --temp 0.7 \
            --top-k 40 \
            --top-p 0.95 \
            --repeat-penalty 1.1 \
            --ctx-size 4096 \
            --no-display-prompt \
            --simple-io \
            2>/dev/null | sed 's/^[[:space:]]*//')
        
        # Clear thinking indicator and show response
        echo -ne "\033[2K\r"
        echo -e "${GREEN}$model_name:${COLOR_RESET} $response"
        
        # Update context (keep last 2 exchanges)
        context="${context}
User: $user_input
Assistant: $response"
        
        # Trim context if too long
        local context_lines=$(echo "$context" | wc -l)
        if [[ $context_lines -gt 8 ]]; then
            context=$(echo "$context" | tail -n 8)
        fi
    done
}

# Main handler for USB inference
handle_usb_inference() {
    local model_path="$1"
    
    if [[ ! -f "$model_path" ]]; then
        echo -e "${RED}Model file not found: $model_path${COLOR_RESET}"
        return 1
    fi
    
    # Run portable chat session
    run_portable_chat "$model_path"
}

# Export functions
export -f check_portable_inference setup_portable_inference run_gguf_inference run_portable_chat handle_usb_inference
