#!/usr/bin/env bash

# Chat Wrapper - Provides location-aware chat interface
# Part of Leonardo AI Universal

# Check if Ollama is installed
is_ollama_installed() {
    command -v ollama >/dev/null 2>&1
}

# Ensure color variables are defined
: "${GREEN:=\033[32m}"
: "${CYAN:=\033[36m}"
: "${YELLOW:=\033[33m}"
: "${RED:=\033[31m}"
: "${DIM:=\033[2m}"
: "${BOLD:=\033[1m}"
: "${COLOR_RESET:=\033[0m}"
: "${BLUE:=\033[34m}"

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
    
    # Try to detect USB mount if not set
    if [[ -z "${LEONARDO_USB_MOUNT:-}" ]]; then
        local script_path="${BASH_SOURCE[0]:-$0}"
        local real_path=$(readlink -f "$script_path" 2>/dev/null || realpath "$script_path" 2>/dev/null || echo "$script_path")
        
        # Check if we're running from a USB location
        if echo "$real_path" | grep -iE '/(media|mnt|run/media|Volumes)/' >/dev/null 2>&1; then
            # Extract the mount point (up to leonardo directory)
            if [[ "$real_path" =~ ^(/media/[^/]+/[^/]+)/.* ]] || \
               [[ "$real_path" =~ ^(/mnt/[^/]+)/.* ]] || \
               [[ "$real_path" =~ ^(/run/media/[^/]+/[^/]+)/.* ]] || \
               [[ "$real_path" =~ ^(/Volumes/[^/]+)/.* ]]; then
                export LEONARDO_USB_MOUNT="${BASH_REMATCH[1]}"
                export LEONARDO_USB_MODE="true"
                export LEONARDO_MODEL_DIR="${LEONARDO_USB_MOUNT}/leonardo/models"
                export LEONARDO_BASE_DIR="${LEONARDO_USB_MOUNT}/leonardo"
                echo -e "${GREEN}Auto-detected USB mount: ${LEONARDO_USB_MOUNT}${COLOR_RESET}" >&2
            fi
        fi
    fi
    
    # Ensure model directory is set for USB mode
    if [[ "${LEONARDO_USB_MODE:-}" == "true" ]] && [[ -z "${LEONARDO_MODEL_DIR:-}" ]]; then
        export LEONARDO_MODEL_DIR="${LEONARDO_USB_MOUNT}/leonardo/models"
        export LEONARDO_BASE_DIR="${LEONARDO_USB_MOUNT}/leonardo"
    fi
    
    # Debug: Show USB detection
    echo -e "${DIM}USB Mode: ${LEONARDO_USB_MODE:-false}${COLOR_RESET}" >&2
    echo -e "${DIM}USB Mount: ${LEONARDO_USB_MOUNT:-not set}${COLOR_RESET}" >&2
    echo -e "${DIM}Model Dir: ${LEONARDO_MODEL_DIR:-not set}${COLOR_RESET}" >&2
    echo >&2
    
    # For USB deployments without Ollama, use direct model access
    if [[ "${LEONARDO_USB_MODE:-}" == "true" ]] || [[ "$preference" == "usb" ]]; then
        # Check for GGUF models in USB
        local model_dir="${LEONARDO_MODEL_DIR:-${LEONARDO_BASE_DIR}/models}"
        if [[ -d "$model_dir" ]] && [[ -n "$(find "$model_dir" -name "*.gguf" 2>/dev/null | head -1)" ]]; then
            echo -e "${CYAN}USB Mode: Using local GGUF models${COLOR_RESET}"
            # Select and use a GGUF model
            local selected_model=$(select_gguf_model "$model_dir")
            if [[ -n "$selected_model" ]]; then
                start_gguf_chat_session "$selected_model"
            fi
            return
        fi
    fi
    
    # Get the appropriate endpoint
    local endpoint=$(get_ollama_endpoint "$preference")
    
    # Check if endpoint is available
    if ! curl -s "$endpoint/api/tags" >/dev/null 2>&1; then
        # If Ollama not available, check for local models
        local model_dir="${LEONARDO_MODEL_DIR:-${LEONARDO_BASE_DIR}/models}"
        if [[ -d "$model_dir" ]] && [[ -n "$(find "$model_dir" -name "*.gguf" 2>/dev/null | head -1)" ]]; then
            echo -e "${YELLOW}Ollama not available, using local GGUF models${COLOR_RESET}"
            local selected_model=$(select_gguf_model "$model_dir")
            if [[ -n "$selected_model" ]]; then
                start_gguf_chat_session "$selected_model"
            fi
            return
        fi
        
        echo -e "${RED}Error: No AI service available${COLOR_RESET}"
        echo -e "${YELLOW}Tip: Make sure Ollama is running or GGUF models are installed${COLOR_RESET}"
        return 1
    fi
    
    # If no model specified, let user select
    if [[ -z "$model" ]]; then
        echo -e "\n${CYAN}Available Models:${COLOR_RESET}\n"
        
        # Build model list based on deployment mode
        local all_models=()
        
        # Check deployment mode
        if [[ "${LEONARDO_USB_ONLY:-false}" == "true" ]]; then
            echo -e "${BLUE}USB-Only Mode: Using only USB-stored models${COLOR_RESET}" >&2
            echo >&2
            
            # Only list models from USB
            if [[ -n "${LEONARDO_USB_MOUNT:-}" ]] && [[ -d "${LEONARDO_USB_MOUNT}/leonardo/models" ]]; then
                echo -e "${CYAN}Available models on USB:${COLOR_RESET}" >&2
                echo >&2
                
                # Find GGUF models on USB
                local usb_model_count=0
                while IFS= read -r model_file; do
                    if [[ -f "$model_file" ]]; then
                        local model_name=$(basename "$model_file" .gguf)
                        local model_size=$(du -h "$model_file" 2>/dev/null | cut -f1)
                        all_models+=("${model_name}:gguf:[USB-ONLY] ${model_name} (${model_size})")
                        ((usb_model_count++))
                    fi
                done < <(find "${LEONARDO_USB_MOUNT}/leonardo/models" -name "*.gguf" -type f 2>/dev/null | sort)
                
                if [[ $usb_model_count -eq 0 ]]; then
                    echo -e "${YELLOW}No models found on USB. Please download models first.${COLOR_RESET}" >&2
                    return 1
                fi
            else
                echo -e "${RED}USB not mounted or models directory not found${COLOR_RESET}" >&2
                return 1
            fi
        else
            # Original mode - check all sources
            # 1. Check Ollama models
            if is_ollama_installed; then
                local ollama_endpoint="http://localhost:11434"
                local ollama_location="HOST"
                
                # Check if Ollama is running on USB
                if [[ "${LEONARDO_USB_MODE:-false}" == "true" ]] && [[ -n "${LEONARDO_OLLAMA_HOST:-}" ]]; then
                    ollama_endpoint="${LEONARDO_OLLAMA_HOST}"
                    if [[ "$ollama_endpoint" == *":11435"* ]]; then
                        ollama_location="USB"
                    fi
                fi
                
                echo -e "${CYAN}Checking Ollama models...${COLOR_RESET}" >&2
                
                # Get Ollama models with error handling
                local ollama_models
                if ollama_models=$(OLLAMA_HOST="$ollama_endpoint" ollama list 2>/dev/null | tail -n +2); then
                    while IFS=$'\t' read -r name id size modified; do
                        if [[ -n "$name" ]]; then
                            local display_name="[${ollama_location}] ${name}"
                            if [[ -n "$size" ]]; then
                                display_name+=" (${size})"
                            fi
                            all_models+=("${name}:ollama:${display_name}")
                        fi
                    done <<< "$ollama_models"
                fi
            fi
            
            # 2. Check local GGUF models
            # First check USB if in USB mode
            if [[ "${LEONARDO_USB_MODE:-false}" == "true" ]] && [[ -n "${LEONARDO_USB_MOUNT:-}" ]]; then
                local usb_model_dir="${LEONARDO_USB_MOUNT}/leonardo/models"
                echo -e "${CYAN}Checking USB GGUF models...${COLOR_RESET}" >&2
                
                if [[ -d "$usb_model_dir" ]]; then
                    while IFS= read -r model_file; do
                        if [[ -f "$model_file" ]]; then
                            local model_name=$(basename "$model_file" .gguf)
                            local model_size=$(du -h "$model_file" 2>/dev/null | cut -f1)
                            all_models+=("${model_name}:gguf:[USB] ${model_name} (${model_size})")
                            echo -e "  Found: ${model_name} (${model_size})" >&2
                        fi
                    done < <(find "$usb_model_dir" -name "*.gguf" -type f 2>/dev/null | sort)
                fi
            fi
            
            # Then check host model directory if different
            if [[ -d "$LEONARDO_MODEL_DIR" ]] && [[ "$LEONARDO_MODEL_DIR" != "${LEONARDO_USB_MOUNT}/leonardo/models" ]]; then
                echo -e "${CYAN}Checking host GGUF models...${COLOR_RESET}" >&2
                
                while IFS= read -r model_file; do
                    if [[ -f "$model_file" ]]; then
                        local model_name=$(basename "$model_file" .gguf)
                        local model_size=$(du -h "$model_file" 2>/dev/null | cut -f1)
                        all_models+=("${model_name}:gguf:[HOST] ${model_name} (${model_size})")
                    fi
                done < <(find "$LEONARDO_MODEL_DIR" -name "*.gguf" -type f 2>/dev/null | sort)
            fi
        fi
        
        # List models
        if [[ ${#all_models[@]} -eq 0 ]]; then
            echo -e "${RED}No models found${COLOR_RESET}"
            return 1
        fi
        
        echo -e "\n${CYAN}Available Models:${COLOR_RESET}\n"
        local i=1
        for model in "${all_models[@]}"; do
            local model_name=$(echo "$model" | cut -d: -f1)
            local model_type=$(echo "$model" | cut -d: -f2)
            local model_display=$(echo "$model" | cut -d: -f3-)
            echo "  $i) $model_display"
            ((i++))
        done
        
        echo
        read -p "Select model (1-$((i-1))): " model_choice
        
        if [[ "$model_choice" =~ ^[0-9]+$ ]] && (( model_choice > 0 && model_choice < i )); then
            model=$(echo "${all_models[$((model_choice-1))]}" | cut -d: -f1)
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

# Select a GGUF model from available models
select_gguf_model() {
    local model_dir="$1"
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}               🤖 Leonardo AI Chat - Local Models${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    
    # List available GGUF models
    echo -e "\n${CYAN}Available GGUF Models:${COLOR_RESET}\n"
    local models=()
    local i=1
    
    while IFS= read -r -d '' model_file; do
        local model_name=$(basename "$model_file" .gguf)
        local model_size=$(du -h "$model_file" 2>/dev/null | cut -f1)
        echo "  $i) $model_name ($model_size)"
        models+=("$model_file")
        ((i++))
    done < <(find "$model_dir" -name "*.gguf" -print0 2>/dev/null)
    
    if [[ ${#models[@]} -eq 0 ]]; then
        echo -e "${RED}No GGUF models found in $model_dir${COLOR_RESET}"
        return 1
    fi
    
    # Select model
    echo
    read -p "Select model (1-${#models[@]}): " selection
    
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#models[@]} ]]; then
        echo -e "${RED}Invalid selection${COLOR_RESET}"
        return 1
    fi
    
    echo "${models[$((selection-1))]}"
}

# Start a GGUF chat session
start_gguf_chat_session() {
    local model_file="$1"
    local model_name=$(basename "$model_file" .gguf)
    
    echo -e "\n${GREEN}Selected: $model_name${COLOR_RESET}"
    echo -e "${DIM}Model file: $model_file${COLOR_RESET}"
    echo
    
    # Check if we can use Ollama with the GGUF model
    if command -v ollama >/dev/null 2>&1; then
        echo -e "${CYAN}Loading model into Ollama...${COLOR_RESET}"
        # Create a temporary Modelfile for the GGUF
        local temp_modelfile="/tmp/leonardo_modelfile_$$"
        echo "FROM $model_file" > "$temp_modelfile"
        
        # Create the model in Ollama
        local ollama_model_name="leonardo-${model_name,,}"
        if ollama create "$ollama_model_name" -f "$temp_modelfile" 2>/dev/null; then
            rm -f "$temp_modelfile"
            echo -e "${GREEN}Model loaded successfully!${COLOR_RESET}"
            # Start chat with the loaded model
            start_location_aware_chat "$ollama_model_name" "local"
            return
        fi
        rm -f "$temp_modelfile"
    fi
    
    # Fallback to simple chat interface
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}Chat with $model_name (Simulated)${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo
    echo -e "${YELLOW}Note: Full chat requires llama.cpp or Ollama runtime${COLOR_RESET}"
    echo -e "${DIM}This is a demonstration interface${COLOR_RESET}"
    echo
    echo -e "Type 'exit' to quit\n"
    
    # Simple chat loop for demonstration
    while true; do
        read -p "You: " user_input
        if [[ "$user_input" =~ ^(exit|quit|bye)$ ]]; then
            echo -e "\n${CYAN}Chat ended. Thank you!${COLOR_RESET}"
            break
        fi
        
        echo -e "\n${GREEN}$model_name:${COLOR_RESET} I'm a local GGUF model. To enable actual inference:"
        echo "  - Install Ollama from https://ollama.ai"
        echo "  - Or use llama.cpp for direct GGUF execution"
        echo
    done
}

# Handle GGUF model chat (legacy compatibility)
handle_gguf_chat() {
    local model_dir="$1"
    local selected_model=$(select_gguf_model "$model_dir")
    if [[ -n "$selected_model" ]]; then
        start_gguf_chat_session "$selected_model"
    fi
}

# Export functions
export -f start_location_aware_chat select_gguf_model start_gguf_chat_session handle_gguf_chat
