#!/bin/bash
#
# Leonardo AI Universal - Model Management
# Central model management functionality
#

# Model directories
LEONARDO_MODELS_DIR="${LEONARDO_MODEL_DIR:-$LEONARDO_BASE_DIR/models}"
LEONARDO_MODEL_CACHE="${LEONARDO_MODEL_CACHE_DIR:-$LEONARDO_BASE_DIR/cache/models}"
LEONARDO_MODEL_REGISTRY="${LEONARDO_CONFIG_DIR}/model_registry.json"

# Initialize model system
init_model_system() {
    log_info "Initializing model system..."
    
    # Create model directories
    create_directory "$LEONARDO_MODELS_DIR" || return 1
    create_directory "$LEONARDO_MODEL_CACHE" || return 1
    create_directory "${LEONARDO_MODELS_DIR}/ollama" || return 1
    create_directory "${LEONARDO_MODELS_DIR}/huggingface" || return 1
    create_directory "${LEONARDO_MODELS_DIR}/custom" || return 1
    
    log_success "Model system initialized"
    return 0
}

# List all available models
list_available_models() {
    local provider="${1:-all}"
    
    echo "Available Models:"
    echo "================"
    echo
    
    if [[ "$provider" == "all" || "$provider" == "ollama" ]]; then
        echo "Ollama Models:"
        echo "-------------"
        get_ollama_models | while read -r model; do
            local info=$(get_ollama_model_info "$model")
            local desc=$(echo "$info" | grep '"description"' | cut -d'"' -f4)
            printf "  %-15s - %s\n" "$model" "$desc"
        done
        echo
    fi
    
    # Add other providers here as they are implemented
}

# List installed models
list_installed_models() {
    echo "Installed Models:"
    echo "================"
    echo
    
    # Check Ollama models
    if [[ -d "${LEONARDO_MODELS_DIR}/ollama" ]]; then
        echo "Ollama Models:"
        list_ollama_models
        echo
    fi
    
    # Check for models in the models directory
    find "$LEONARDO_MODELS_DIR" -name "metadata.json" -type f | while read -r metadata; do
        local name=$(parse_model_metadata "$metadata" "name")
        local provider=$(parse_model_metadata "$metadata" "provider")
        local version=$(parse_model_metadata "$metadata" "version")
        local size=$(parse_model_metadata "$metadata" "size")
        
        if [[ "$provider" != "ollama" ]]; then  # Avoid duplicates
            printf "%-15s %-10s %-10s %s\n" "$name" "$provider" "$version" "$size"
        fi
    done
}

# Download model from provider
download_model() {
    local model_spec="$1"
    local provider="${2:-ollama}"
    
    echo -e "${CYAN}Downloading model: $model_spec${COLOR_RESET}"
    
    # Check if we're in USB deployment mode
    if [[ "${LEONARDO_USB_MODE}" == "true" ]] && [[ -n "${LEONARDO_USB_MOUNT:-}" ]]; then
        echo -e "${YELLOW}USB deployment mode - downloading to USB instead of host${COLOR_RESET}"
        
        # For USB mode, always download GGUF files directly
        case "$provider" in
            ollama)
                echo "Converting Ollama model to GGUF download..."
                # Try to find GGUF URL for this model
                local model_id="${model_spec%:*}"
                local variant="${model_spec#*:}"
                
                # Check if we have a registry entry
                if [[ -f "${LEONARDO_DIR}/src/models/registry_loader.sh" ]]; then
                    source "${LEONARDO_DIR}/src/models/registry_loader.sh"
                fi
                
                local model_url=""
                if [[ -n "${LEONARDO_GGUF_REGISTRY[${model_id}:${variant}]:-}" ]]; then
                    model_url="${LEONARDO_GGUF_REGISTRY[${model_id}:${variant}]}"
                else
                    # Try common GGUF sources
                    case "$model_id" in
                        phi*) model_url="https://huggingface.co/microsoft/phi-2-gguf/resolve/main/phi-2.Q4_K_M.gguf" ;;
                        llama2*) model_url="https://huggingface.co/TheBloke/Llama-2-7B-GGUF/resolve/main/llama-2-7b.Q4_K_M.gguf" ;;
                        mistral*) model_url="https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_K_M.gguf" ;;
                        qwen*) model_url="https://huggingface.co/Qwen/Qwen2.5-3B-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf" ;;
                        *) 
                            echo -e "${RED}No GGUF URL found for $model_id. Please use direct GGUF download.${COLOR_RESET}"
                            return 1
                            ;;
                    esac
                fi
                
                # Download to USB
                local output_file="${LEONARDO_USB_MOUNT}/leonardo/models/${model_id}-${variant}.gguf"
                ensure_directory "$(dirname "$output_file")"
                
                download_with_progress "$model_url" "$output_file" "Downloading ${model_id} to USB"
                return $?
                ;;
            huggingface|gguf)
                # Direct GGUF download to USB
                local model_id="${model_spec%:*}"
                local variant="${model_spec#*:}"
                local output_file="${LEONARDO_USB_MOUNT}/leonardo/models/${model_id//\//-}-${variant}.gguf"
                
                ensure_directory "$(dirname "$output_file")"
                
                # Construct HuggingFace URL
                local hf_url="https://huggingface.co/${model_id}/resolve/main/${variant}.gguf"
                
                download_with_progress "$hf_url" "$output_file" "Downloading to USB"
                return $?
                ;;
            *)
                echo -e "${RED}Provider $provider not supported in USB mode${COLOR_RESET}"
                return 1
                ;;
        esac
    fi
    
    # Original host-based download logic
    case "$provider" in
        ollama)
            if command_exists ollama; then
                echo "Using Ollama provider..."
                ollama pull "$model_spec" 2>&1 | \
                while IFS= read -r line; do
                    # Parse Ollama progress
                    if [[ "$line" =~ pulling[[:space:]].*[[:space:]]([0-9]+)%[[:space:]]+\|.*\|[[:space:]]+([0-9.]+[[:space:]]?[KMGT]?B)/([0-9.]+[[:space:]]?[KMGT]?B)[[:space:]]+([0-9.]+[[:space:]]?[KMGT]?B/s) ]]; then
                        local percent="${BASH_REMATCH[1]}"
                        local downloaded="${BASH_REMATCH[2]}"
                        local total="${BASH_REMATCH[3]}"
                        local speed="${BASH_REMATCH[4]}"
                        
                        printf "\r"
                        show_progress_bar "$percent" 100 40
                        printf " ${percent}%% | ${downloaded}/${total} | ${speed}  "
                    elif [[ "$line" =~ "success" ]]; then
                        printf "\r%-80s\r" " "
                        echo -e "${GREEN}✓ Model downloaded successfully${COLOR_RESET}"
                        return 0
                    fi
                done
            else
                echo -e "${RED}Ollama not installed${COLOR_RESET}"
                return 1
            fi
            ;;
        huggingface)
            # Parse model spec
            local model_id="${model_spec%:*}"
            local variant="${model_spec#*:}"
            
            # Construct HuggingFace URL
            local hf_url="https://huggingface.co/${model_id}/resolve/main/${variant}.gguf"
            local output_file="${LEONARDO_MODEL_DIR}/${model_id//\//-}-${variant}.gguf"
            
            # Download with progress
            download_with_progress "$hf_url" "$output_file" "Downloading from HuggingFace"
            ;;
        custom)
            echo -e "${YELLOW}Custom provider not implemented${COLOR_RESET}"
            return 1
            ;;
        *)
            echo -e "${RED}Unknown provider: $provider${COLOR_RESET}"
            return 1
            ;;
    esac
}

# Install a model
install_model() {
    local model_spec="$1"  # Format: provider:model:variant or just model
    
    # Parse model specification
    local provider model variant
    
    if [[ "$model_spec" == *:*:* ]]; then
        # Full specification: provider:model:variant
        IFS=':' read -r provider model variant <<< "$model_spec"
    elif [[ "$model_spec" == *:* ]]; then
        # Partial specification: model:variant (assume ollama)
        provider="ollama"
        IFS=':' read -r model variant <<< "$model_spec"
    else
        # Just model name (assume ollama:latest)
        provider="ollama"
        model="$model_spec"
        variant="latest"
    fi
    
    log_info "Installing model: $provider:$model:$variant"
    
    # Check if already installed
    if is_model_installed "$provider" "$model" "$variant"; then
        log_warn "Model already installed: $model:$variant"
        return 0
    fi
    
    # Download and install
    download_model "$model_spec" "$provider"
}

# Remove a model
remove_model() {
    local model_spec="$1"
    
    # Parse model specification
    local provider model variant
    if [[ "$model_spec" == *:*:* ]]; then
        IFS=':' read -r provider model variant <<< "$model_spec"
    elif [[ "$model_spec" == *:* ]]; then
        provider="ollama"
        IFS=':' read -r model variant <<< "$model_spec"
    else
        provider="ollama"
        model="$model_spec"
        variant="latest"
    fi
    
    local model_path=$(get_model_install_path "$provider" "$model" "$variant")
    
    if [[ -d "$model_path" ]]; then
        log_info "Removing model: $model:$variant"
        rm -rf "$model_path"
        log_success "Model removed successfully"
    else
        log_error "Model not found: $model:$variant"
        return 1
    fi
}

# Run a model
run_model() {
    local model_spec="$1"
    shift
    local args="$@"
    
    # Parse model specification
    local provider model variant
    if [[ "$model_spec" == *:* ]]; then
        IFS=':' read -r model variant <<< "$model_spec"
        provider="ollama"  # Default for now
    else
        provider="ollama"
        model="$model_spec"
        variant="latest"
    fi
    
    case "$provider" in
        ollama)
            run_ollama_model "$model" "$variant"
            ;;
        *)
            log_error "Cannot run models from provider: $provider"
            return 1
            ;;
    esac
}

# Get model information
get_model_info() {
    local model_spec="$1"
    
    # Parse model specification
    local provider model variant
    if [[ "$model_spec" == *:* ]]; then
        IFS=':' read -r model variant <<< "$model_spec"
        provider="ollama"
    else
        provider="ollama"
        model="$model_spec"
        variant="7b"  # Default variant
    fi
    
    case "$provider" in
        ollama)
            get_ollama_model_info "$model" "$variant"
            ;;
        *)
            log_error "Unknown provider: $provider"
            return 1
            ;;
    esac
}

# Update model registry
update_model_registry() {
    log_info "Updating model registry..."
    
    # Scan installed models and update registry
    local registry_file="${LEONARDO_CONFIG_DIR}/model_registry.json"
    
    echo "{" > "$registry_file"
    echo '  "version": "1.0.0",' >> "$registry_file"
    echo '  "updated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",' >> "$registry_file"
    echo '  "models": [' >> "$registry_file"
    
    local first=true
    find "$LEONARDO_MODELS_DIR" -name "metadata.json" -type f | while read -r metadata; do
        if [[ "$first" != "true" ]]; then
            echo "," >> "$registry_file"
        fi
        cat "$metadata" | sed 's/^/    /' >> "$registry_file"
        first=false
    done
    
    echo "  ]" >> "$registry_file"
    echo "}" >> "$registry_file"
    
    log_success "Model registry updated"
}

# Export functions
export -f init_model_system
export -f list_available_models
export -f list_installed_models
export -f install_model
export -f remove_model
export -f run_model
export -f get_model_info
export -f update_model_registry
