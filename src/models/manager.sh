#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Model Manager
# ==============================================================================
# Description: Model download, installation, and lifecycle management
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh, network.sh, progress.sh, registry.sh
# ==============================================================================

# Model management state
declare -A LEONARDO_INSTALLED_MODELS
declare -A LEONARDO_MODEL_STATUS
LEONARDO_ACTIVE_MODEL=""

# Initialize model manager
init_model_manager() {
    log_message "INFO" "Initializing model manager"
    
    # Create model directories
    mkdir -p "$LEONARDO_MODEL_DIR"
    mkdir -p "$LEONARDO_MODEL_CACHE_DIR"
    mkdir -p "$LEONARDO_MODEL_DIR/downloads"
    
    # Initialize model registry
    init_model_registry
    
    # Scan for installed models
    scan_installed_models
}

# Scan for installed models
scan_installed_models() {
    log_message "INFO" "Scanning for installed models..."
    
    LEONARDO_INSTALLED_MODELS=()
    
    if [[ -d "$LEONARDO_MODEL_DIR" ]]; then
        while IFS= read -r model_file; do
            local basename=$(basename "$model_file")
            
            # Check if this file matches any known model
            for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
                if [[ "${LEONARDO_MODEL_REGISTRY[$model_id]}" == "$basename" ]]; then
                    LEONARDO_INSTALLED_MODELS[$model_id]="$model_file"
                    LEONARDO_MODEL_STATUS[$model_id]="installed"
                    log_message "INFO" "Found installed model: $model_id"
                    break
                fi
            done
        done < <(find "$LEONARDO_MODEL_DIR" -name "*.gguf" -o -name "*.ggml" -o -name "*.bin" 2>/dev/null)
    fi
    
    log_message "INFO" "Found ${#LEONARDO_INSTALLED_MODELS[@]} installed model(s)"
}

# Download model
download_model() {
    local model_id="$1"
    local force="${2:-false}"
    
    # Validate model ID
    if [[ -z "${LEONARDO_MODEL_REGISTRY[$model_id]:-}" ]]; then
        log_message "ERROR" "Unknown model: $model_id"
        return 1
    fi
    
    # Check if already installed
    if [[ -n "${LEONARDO_INSTALLED_MODELS[$model_id]:-}" ]] && [[ "$force" != "true" ]]; then
        log_message "INFO" "Model already installed: $model_id"
        return 0
    fi
    
    # Get model metadata
    local filename="${LEONARDO_MODEL_REGISTRY[$model_id]}"
    local url=$(get_model_metadata "$model_id" "url")
    local size=$(get_model_metadata "$model_id" "size")
    local sha256=$(get_model_metadata "$model_id" "sha256")
    local name=$(get_model_metadata "$model_id" "name")
    
    if [[ -z "$url" ]]; then
        log_message "ERROR" "No download URL for model: $model_id"
        return 1
    fi
    
    # Show model info
    echo "${COLOR_CYAN}Downloading Model: $name${COLOR_RESET}"
    echo "${COLOR_DIM}Size: $size${COLOR_RESET}"
    echo "${COLOR_DIM}Quantization: $(get_model_metadata "$model_id" "quantization")${COLOR_RESET}"
    echo ""
    
    # Check available space
    local size_bytes=$(parse_size_to_bytes "$size")
    if ! check_space_available "$LEONARDO_MODEL_DIR" "$size_bytes"; then
        log_message "ERROR" "Insufficient space for model download"
        return 1
    fi
    
    # Set download paths
    local temp_file="$LEONARDO_MODEL_DIR/downloads/${filename}.tmp"
    local final_file="$LEONARDO_MODEL_DIR/$filename"
    
    # Update status
    LEONARDO_MODEL_STATUS[$model_id]="downloading"
    
    # Download with progress
    echo "${COLOR_YELLOW}Downloading from: $url${COLOR_RESET}"
    if download_file_with_progress "$url" "$temp_file"; then
        # Verify download if checksum available
        if [[ -n "$sha256" ]] && [[ "$LEONARDO_VERIFY_CHECKSUMS" == "true" ]]; then
            echo -n "${COLOR_CYAN}Verifying checksum...${COLOR_RESET} "
            if validate_model_file "$temp_file" "$sha256"; then
                echo "${COLOR_GREEN}✓${COLOR_RESET}"
            else
                echo "${COLOR_RED}✗${COLOR_RESET}"
                rm -f "$temp_file"
                LEONARDO_MODEL_STATUS[$model_id]="error"
                return 1
            fi
        fi
        
        # Move to final location
        mv "$temp_file" "$final_file"
        LEONARDO_INSTALLED_MODELS[$model_id]="$final_file"
        LEONARDO_MODEL_STATUS[$model_id]="installed"
        
        log_message "INFO" "Model downloaded successfully: $model_id"
        show_status "success" "Model '$name' installed successfully!"
        
        # Create metadata file
        save_model_metadata "$model_id" "$final_file"
        
        return 0
    else
        rm -f "$temp_file"
        LEONARDO_MODEL_STATUS[$model_id]="error"
        log_message "ERROR" "Failed to download model: $model_id"
        return 1
    fi
}

# Parse size string to bytes
parse_size_to_bytes() {
    local size_str="$1"
    local number=$(echo "$size_str" | grep -oE '[0-9.]+')
    local unit=$(echo "$size_str" | grep -oE '[A-Z]+')
    
    case "$unit" in
        "GB")
            echo $(awk "BEGIN {printf \"%.0f\", $number * 1024 * 1024 * 1024}")
            ;;
        "MB")
            echo $(awk "BEGIN {printf \"%.0f\", $number * 1024 * 1024}")
            ;;
        "KB")
            echo $(awk "BEGIN {printf \"%.0f\", $number * 1024}")
            ;;
        *)
            echo "$number"
            ;;
    esac
}

# Save model metadata
save_model_metadata() {
    local model_id="$1"
    local model_path="$2"
    local metadata_file="${model_path}.meta"
    
    cat > "$metadata_file" << EOF
{
    "id": "$model_id",
    "name": "$(get_model_metadata "$model_id" "name")",
    "filename": "$(basename "$model_path")",
    "size": "$(get_model_metadata "$model_id" "size")",
    "format": "$(get_model_metadata "$model_id" "format")",
    "quantization": "$(get_model_metadata "$model_id" "quantization")",
    "family": "$(get_model_metadata "$model_id" "family")",
    "license": "$(get_model_metadata "$model_id" "license")",
    "sha256": "$(get_model_metadata "$model_id" "sha256")",
    "installed_date": "$(date -u +"%Y-%m-%d %H:%M:%S UTC")",
    "leonardo_version": "$LEONARDO_VERSION"
}
EOF
}

# Delete model
delete_model() {
    local model_id="$1"
    
    if [[ -z "${LEONARDO_INSTALLED_MODELS[$model_id]:-}" ]]; then
        log_message "ERROR" "Model not installed: $model_id"
        return 1
    fi
    
    local model_path="${LEONARDO_INSTALLED_MODELS[$model_id]}"
    local name=$(get_model_metadata "$model_id" "name")
    
    # Confirm deletion
    if confirm_action "Delete model '$name'?"; then
        # Delete model file
        if [[ "$LEONARDO_SECURE_DELETE" == "true" ]]; then
            secure_delete "$model_path"
        else
            rm -f "$model_path"
        fi
        
        # Delete metadata
        rm -f "${model_path}.meta"
        
        # Update state
        unset LEONARDO_INSTALLED_MODELS[$model_id]
        unset LEONARDO_MODEL_STATUS[$model_id]
        
        log_message "INFO" "Model deleted: $model_id"
        show_status "success" "Model '$name' deleted"
        return 0
    else
        log_message "INFO" "Model deletion cancelled"
        return 1
    fi
}

# List installed models
list_installed_models() {
    if [[ ${#LEONARDO_INSTALLED_MODELS[@]} -eq 0 ]]; then
        echo "${COLOR_YELLOW}No models installed${COLOR_RESET}"
        echo "Use 'leonardo model download <model-id>' to install models"
        return
    fi
    
    echo "${COLOR_CYAN}Installed Models:${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%60s' | tr ' ' '-')${COLOR_RESET}"
    
    for model_id in "${!LEONARDO_INSTALLED_MODELS[@]}"; do
        local path="${LEONARDO_INSTALLED_MODELS[$model_id]}"
        local name=$(get_model_metadata "$model_id" "name")
        local size=$(get_model_metadata "$model_id" "size")
        local status="${LEONARDO_MODEL_STATUS[$model_id]:-unknown}"
        
        # Status icon
        local status_icon="?"
        local status_color="$COLOR_DIM"
        case "$status" in
            "installed")
                status_icon="✓"
                status_color="$COLOR_GREEN"
                ;;
            "downloading")
                status_icon="⟳"
                status_color="$COLOR_YELLOW"
                ;;
            "error")
                status_icon="✗"
                status_color="$COLOR_RED"
                ;;
        esac
        
        printf "${status_color}%s${COLOR_RESET} %-15s %-25s %10s\n" \
            "$status_icon" "$model_id" "$name" "$size"
        
        if [[ "$LEONARDO_VERBOSE" == "true" ]]; then
            echo "  ${COLOR_DIM}Path: $path${COLOR_RESET}"
        fi
    done
}

# Import model from file
import_model() {
    local model_file="$1"
    local model_id="${2:-}"
    
    if [[ ! -f "$model_file" ]]; then
        log_message "ERROR" "Model file not found: $model_file"
        return 1
    fi
    
    # Try to identify model if ID not provided
    if [[ -z "$model_id" ]]; then
        local basename=$(basename "$model_file")
        for id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
            if [[ "${LEONARDO_MODEL_REGISTRY[$id]}" == "$basename" ]]; then
                model_id="$id"
                break
            fi
        done
        
        if [[ -z "$model_id" ]]; then
            log_message "ERROR" "Cannot identify model from filename: $basename"
            echo "Please specify model ID explicitly"
            return 1
        fi
    fi
    
    # Validate model exists in registry
    if [[ -z "${LEONARDO_MODEL_REGISTRY[$model_id]:-}" ]]; then
        log_message "ERROR" "Unknown model ID: $model_id"
        return 1
    fi
    
    # Get expected filename
    local expected_filename="${LEONARDO_MODEL_REGISTRY[$model_id]}"
    local target_path="$LEONARDO_MODEL_DIR/$expected_filename"
    
    echo "${COLOR_CYAN}Importing model: $(get_model_metadata "$model_id" "name")${COLOR_RESET}"
    
    # Validate model file
    local expected_sha256=$(get_model_metadata "$model_id" "sha256")
    if [[ -n "$expected_sha256" ]] && [[ "$LEONARDO_VERIFY_CHECKSUMS" == "true" ]]; then
        echo -n "Verifying checksum... "
        if validate_model_file "$model_file" "$expected_sha256"; then
            echo "${COLOR_GREEN}✓${COLOR_RESET}"
        else
            echo "${COLOR_RED}✗${COLOR_RESET}"
            return 1
        fi
    fi
    
    # Copy model to model directory
    echo -n "Copying model file... "
    if cp "$model_file" "$target_path"; then
        echo "${COLOR_GREEN}✓${COLOR_RESET}"
        
        # Update state
        LEONARDO_INSTALLED_MODELS[$model_id]="$target_path"
        LEONARDO_MODEL_STATUS[$model_id]="installed"
        
        # Save metadata
        save_model_metadata "$model_id" "$target_path"
        
        show_status "success" "Model imported successfully!"
        return 0
    else
        echo "${COLOR_RED}✗${COLOR_RESET}"
        return 1
    fi
}

# Export model
export_model() {
    local model_id="$1"
    local export_path="${2:-$PWD}"
    
    if [[ -z "${LEONARDO_INSTALLED_MODELS[$model_id]:-}" ]]; then
        log_message "ERROR" "Model not installed: $model_id"
        return 1
    fi
    
    local model_path="${LEONARDO_INSTALLED_MODELS[$model_id]}"
    local filename=$(basename "$model_path")
    local target_file="$export_path/$filename"
    
    # Check if directory
    if [[ -d "$export_path" ]]; then
        target_file="$export_path/$filename"
    else
        target_file="$export_path"
    fi
    
    echo "${COLOR_CYAN}Exporting model: $(get_model_metadata "$model_id" "name")${COLOR_RESET}"
    echo "Target: $target_file"
    
    # Copy with progress
    if copy_with_progress "$model_path" "$target_file"; then
        # Also export metadata
        cp "${model_path}.meta" "${target_file}.meta" 2>/dev/null || true
        
        show_status "success" "Model exported successfully!"
        echo "You can import this model on another Leonardo installation using:"
        echo "  ${COLOR_CYAN}leonardo model import \"$target_file\" $model_id${COLOR_RESET}"
        return 0
    else
        log_message "ERROR" "Failed to export model"
        return 1
    fi
}

# Update model registry from remote
update_model_registry() {
    log_message "INFO" "Updating model registry..."
    
    local registry_url="$LEONARDO_MODEL_REGISTRY_URL"
    local cache_file="$LEONARDO_MODEL_CACHE_DIR/registry.json"
    
    # Download latest registry
    if fetch_model_registry "$registry_url" "$cache_file"; then
        show_status "success" "Model registry updated"
        
        # TODO: Parse and update registry from JSON
        # For now, using hardcoded registry
        
        return 0
    else
        log_message "ERROR" "Failed to update model registry"
        return 1
    fi
}

# Get model status
get_model_status() {
    local model_id="$1"
    echo "${LEONARDO_MODEL_STATUS[$model_id]:-not_installed}"
}

# Load model (placeholder for inference engine integration)
load_model() {
    local model_id="$1"
    
    if [[ -z "${LEONARDO_INSTALLED_MODELS[$model_id]:-}" ]]; then
        log_message "ERROR" "Model not installed: $model_id"
        return 1
    fi
    
    local model_path="${LEONARDO_INSTALLED_MODELS[$model_id]}"
    local name=$(get_model_metadata "$model_id" "name")
    
    echo "${COLOR_CYAN}Loading model: $name${COLOR_RESET}"
    show_spinner "Initializing inference engine..." &
    local spinner_pid=$!
    
    # Simulate loading (placeholder)
    sleep 2
    
    kill $spinner_pid 2>/dev/null
    wait $spinner_pid 2>/dev/null
    
    LEONARDO_ACTIVE_MODEL="$model_id"
    show_status "success" "Model loaded: $name"
    
    return 0
}

# Model selection menu
model_selection_menu() {
    local models=()
    local names=()
    
    # Build model list
    for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
        models+=("$model_id")
        names+=("$(get_model_metadata "$model_id" "name") ($(get_model_metadata "$model_id" "size"))")
    done
    
    # Show menu
    local selected=$(show_menu "Select a model:" "${names[@]}")
    
    if [[ -n "$selected" ]]; then
        echo "${models[$selected]}"
        return 0
    else
        return 1
    fi
}

# Export model manager functions
export -f init_model_manager scan_installed_models download_model delete_model
export -f list_installed_models import_model export_model update_model_registry
export -f get_model_status load_model model_selection_menu
