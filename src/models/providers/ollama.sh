#!/bin/bash
#
# Leonardo AI Universal - Ollama Provider Integration
# Manages Ollama model downloads and installations
#

# Ollama configuration
readonly OLLAMA_API_URL="https://registry.ollama.ai"
readonly OLLAMA_MODELS_URL="https://ollama.ai/library"

# Popular Ollama models
declare -A OLLAMA_MODELS=(
    ["llama2"]="Meta's Llama 2 model"
    ["mistral"]="Mistral 7B model"
    ["codellama"]="Code Llama model for programming"
    ["neural-chat"]="Intel's neural chat model"
    ["starling-lm"]="Berkeley's Starling model"
    ["phi"]="Microsoft's Phi-2 model"
    ["orca-mini"]="Orca Mini model"
    ["vicuna"]="Vicuna model fine-tuned on conversations"
    ["wizardcoder"]="WizardCoder for programming tasks"
    ["deepseek-coder"]="DeepSeek Coder model"
)

# Model size mappings (approximate)
declare -A OLLAMA_MODEL_SIZES=(
    ["llama2:7b"]="3.8GB"
    ["llama2:13b"]="7.3GB"
    ["llama2:70b"]="39GB"
    ["mistral:7b"]="4.1GB"
    ["codellama:7b"]="3.8GB"
    ["neural-chat:7b"]="4.1GB"
    ["phi:2.7b"]="1.7GB"
    ["orca-mini:3b"]="1.9GB"
)

# Check if Ollama is installed
check_ollama_installed() {
    if command -v ollama &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Install Ollama binary
install_ollama() {
    log_info "Installing Ollama..."
    
    local os_type=$(detect_os)
    local install_script="/tmp/ollama-install.sh"
    
    # Download official install script
    if download_file "https://ollama.ai/install.sh" "$install_script"; then
        chmod +x "$install_script"
        if [[ "$os_type" == "macos" ]]; then
            # macOS specific installation
            log_info "Installing Ollama for macOS..."
            bash "$install_script"
        else
            # Linux installation
            log_info "Installing Ollama for Linux..."
            sudo bash "$install_script"
        fi
        rm -f "$install_script"
        return $?
    else
        log_error "Failed to download Ollama installer"
        return 1
    fi
}

# Get list of available Ollama models
get_ollama_models() {
    local models=()
    for model in "${!OLLAMA_MODELS[@]}"; do
        models+=("$model")
    done
    printf '%s\n' "${models[@]}" | sort
}

# Get model information
get_ollama_model_info() {
    local model="$1"
    local variant="${2:-7b}"  # Default to 7b variant
    
    local full_model="${model}:${variant}"
    local size="${OLLAMA_MODEL_SIZES[$full_model]:-Unknown}"
    local description="${OLLAMA_MODELS[$model]:-No description available}"
    
    cat <<EOF
{
    "name": "$model",
    "variant": "$variant",
    "full_name": "$full_model",
    "size": "$size",
    "description": "$description",
    "provider": "ollama"
}
EOF
}

# Download Ollama model
download_ollama_model() {
    local model="$1"
    local variant="${2:-latest}"
    local full_model="${model}:${variant}"
    
    log_info "Downloading Ollama model: $full_model"
    
    if check_ollama_installed; then
        # Use native Ollama CLI
        show_progress "Pulling $full_model..." &
        local progress_pid=$!
        
        if ollama pull "$full_model"; then
            kill $progress_pid 2>/dev/null || true
            log_success "Successfully downloaded $full_model"
            return 0
        else
            kill $progress_pid 2>/dev/null || true
            log_error "Failed to download $full_model"
            return 1
        fi
    else
        # Fallback: Download model files directly
        log_warn "Ollama not installed. Attempting direct download..."
        download_ollama_model_direct "$model" "$variant"
    fi
}

# Direct model download (without Ollama CLI)
download_ollama_model_direct() {
    local model="$1"
    local variant="$2"
    local model_dir="${LEONARDO_MODELS_DIR}/ollama/${model}/${variant}"
    
    # Create model directory
    create_directory "$model_dir" || return 1
    
    # Create metadata
    create_model_metadata \
        "$model" \
        "$MODEL_TYPE_LLM" \
        "$PROVIDER_OLLAMA" \
        "$variant" \
        "${OLLAMA_MODEL_SIZES[${model}:${variant}]:-Unknown}" \
        "${OLLAMA_MODELS[$model]}" > "$model_dir/metadata.json"
    
    # Download model manifest
    local manifest_url="${OLLAMA_API_URL}/v2/library/${model}/manifests/${variant}"
    local manifest_file="$model_dir/manifest.json"
    
    log_info "Downloading model manifest..."
    if download_file "$manifest_url" "$manifest_file"; then
        log_success "Model structure created at $model_dir"
        log_warn "Note: Full model download requires Ollama CLI"
        return 0
    else
        log_error "Failed to download model manifest"
        return 1
    fi
}

# List installed Ollama models
list_ollama_models() {
    if check_ollama_installed; then
        ollama list
    else
        # List from Leonardo's model directory
        local ollama_dir="${LEONARDO_MODELS_DIR}/ollama"
        if [[ -d "$ollama_dir" ]]; then
            find "$ollama_dir" -name "metadata.json" -type f | while read -r metadata; do
                local model_name=$(parse_model_metadata "$metadata" "name")
                local version=$(parse_model_metadata "$metadata" "version")
                local size=$(parse_model_metadata "$metadata" "size")
                printf "%-20s %-10s %s\n" "$model_name" "$version" "$size"
            done
        else
            log_info "No Ollama models installed"
        fi
    fi
}

# Run Ollama model
run_ollama_model() {
    local model="$1"
    local variant="${2:-latest}"
    local full_model="${model}:${variant}"
    
    if check_ollama_installed; then
        log_info "Starting Ollama with $full_model..."
        ollama run "$full_model"
    else
        log_error "Ollama CLI not installed. Please install Ollama first."
        log_info "Run: leonardo model install ollama-cli"
        return 1
    fi
}

# Export Ollama model for offline use
export_ollama_model() {
    local model="$1"
    local variant="${2:-latest}"
    local export_path="$3"
    
    local full_model="${model}:${variant}"
    local model_dir="${LEONARDO_MODELS_DIR}/ollama/${model}/${variant}"
    
    log_info "Exporting $full_model to $export_path..."
    
    # Create export directory
    create_directory "$export_path" || return 1
    
    # Copy model files
    if [[ -d "$model_dir" ]]; then
        cp -r "$model_dir"/* "$export_path/"
        log_success "Model exported to $export_path"
        return 0
    else
        log_error "Model not found: $full_model"
        return 1
    fi
}

# Export functions
export -f check_ollama_installed
export -f install_ollama
export -f get_ollama_models
export -f get_ollama_model_info
export -f download_ollama_model
export -f list_ollama_models
export -f run_ollama_model
export -f export_ollama_model
