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
    local llama_server_path="$usb_mount/leonardo/bin/llama-server"
    local llama_cli_path="$usb_mount/leonardo/bin/llama-cli"
    
    # Return server path if available, otherwise cli path
    if [[ -f "$llama_server_path" && -x "$llama_server_path" ]]; then
        echo "$llama_server_path"
        return 0
    elif [[ -f "$llama_cli_path" && -x "$llama_cli_path" ]]; then
        echo "$llama_cli_path"
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
    
    # First check if llama-server is already on USB
    if [[ -f "$bin_dir/llama-server" && -x "$bin_dir/llama-server" ]]; then
        echo -e "${GREEN}✓ Inference engine already installed${COLOR_RESET}"
        return 0
    fi
    
    # Check if llama.cpp is installed on host and copy it
    if command -v llama-server >/dev/null 2>&1; then
        echo -e "${DIM}Copying llama.cpp from host system...${COLOR_RESET}"
        local host_server=$(which llama-server)
        local host_cli=$(which llama-cli 2>/dev/null || true)
        
        cp "$host_server" "$bin_dir/" && chmod +x "$bin_dir/llama-server"
        [[ -n "$host_cli" ]] && cp "$host_cli" "$bin_dir/" && chmod +x "$bin_dir/llama-cli"
        
        echo -e "${GREEN}✓ Copied inference engine from host${COLOR_RESET}"
        return 0
    fi
    
    # Build llama.cpp from source on USB
    echo -e "${YELLOW}Building llama.cpp from source...${COLOR_RESET}"
    echo -e "${DIM}This is a one-time setup that may take a few minutes${COLOR_RESET}"
    
    cd "$temp_dir"
    
    # Clone llama.cpp repository
    if [[ -d "llama.cpp" ]]; then
        echo -e "${DIM}Updating existing source...${COLOR_RESET}"
        cd llama.cpp && git pull
    else
        echo -e "${DIM}Cloning llama.cpp repository...${COLOR_RESET}"
        git clone https://github.com/ggerganov/llama.cpp.git
        cd llama.cpp
    fi
    
    # Build with minimal dependencies
    echo -e "${DIM}Building (this may take a while)...${COLOR_RESET}"
    make clean
    make -j$(nproc) LLAMA_PORTABLE=1 llama-server llama-cli
    
    # Copy binaries to USB bin directory
    cp llama-server "$bin_dir/" && chmod +x "$bin_dir/llama-server"
    cp llama-cli "$bin_dir/" && chmod +x "$bin_dir/llama-cli"
    
    # Clean up
    cd "$usb_mount/leonardo"
    rm -rf "$temp_dir/llama.cpp"
    
    echo -e "${GREEN}✓ Portable inference engine built and installed${COLOR_RESET}"
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
    local usb_mount="${LEONARDO_USB_MOUNT:-/media/$USER/LEONARDO}"
    
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
        echo -e "${YELLOW}First time setup - installing portable inference engine...${COLOR_RESET}"
        if ! setup_portable_inference; then
            echo -e "${RED}Failed to setup inference engine${COLOR_RESET}"
            return 1
        fi
        llama_path=$(check_portable_inference)
    fi
    
    # Check if we have server or just CLI
    local server_mode=false
    if [[ "$llama_path" == *"llama-server"* ]]; then
        server_mode=true
        local server_port=8080
        local server_pid=""
        
        # Start llama-server in background
        echo -e "${DIM}Starting inference server...${COLOR_RESET}"
        "$llama_path" \
            --model "$model_path" \
            --ctx-size 2048 \
            --n-gpu-layers 0 \
            --port $server_port \
            --host 127.0.0.1 \
            --log-disable \
            > /dev/null 2>&1 &
        server_pid=$!
        
        # Wait for server to start
        sleep 2
        
        # Check if server is running
        if ! kill -0 $server_pid 2>/dev/null; then
            echo -e "${RED}Failed to start inference server${COLOR_RESET}"
            server_mode=false
        fi
    fi
    
    # Initialize conversation
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
                [[ -n "$server_pid" ]] && kill $server_pid 2>/dev/null
                break
                ;;
            clear|cls)
                clear
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
                echo -e "${BOLD}               🤖 Leonardo AI Chat - USB Mode                ${COLOR_RESET}"
                echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
                continue
                ;;
            "")
                continue
                ;;
        esac
        
        # Show typing indicator
        echo -en "\n${GREEN}AI:${COLOR_RESET} ${DIM}thinking...${COLOR_RESET}"
        
        # Generate response
        local response=""
        if [[ "$server_mode" == "true" ]]; then
            # Use server API
            local prompt_json=$(jq -n \
                --arg prompt "$system_prompt\n\nHuman: $user_input\n\nAssistant:" \
                '{prompt: $prompt, n_predict: 512, temperature: 0.7}')
            
            response=$(curl -s -X POST http://127.0.0.1:$server_port/completion \
                -H "Content-Type: application/json" \
                -d "$prompt_json" | jq -r '.content // empty')
        else
            # Use CLI mode
            local full_prompt="$system_prompt\n\nHuman: $user_input\n\nAssistant:"
            response=$(echo -e "$full_prompt" | "$llama_path" \
                -m "$model_path" \
                -f - \
                -n 512 \
                --temp 0.7 \
                --top-k 40 \
                --top-p 0.95 \
                --repeat-penalty 1.1 \
                --ctx-size 2048 \
                2>/dev/null | tail -n +2)
        fi
        
        # Clear thinking message and show response
        echo -en "\r${GREEN}AI:${COLOR_RESET} "
        
        if [[ -n "$response" ]]; then
            echo "$response"
        else
            echo "${DIM}(No response generated - model may be loading)${COLOR_RESET}"
        fi
        
        # Update context for next turn
        context+="\nHuman: $user_input\nAssistant: $response"
    done
    
    # Cleanup
    [[ -n "$server_pid" ]] && kill $server_pid 2>/dev/null
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
