#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Model Registry
# ==============================================================================
# Description: AI model registry and metadata management
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, network.sh, validation.sh
# ==============================================================================

# Model registry data structure
declare -A LEONARDO_MODEL_REGISTRY
declare -A LEONARDO_MODEL_METADATA

# Initialize model registry
init_model_registry() {
    log_message "INFO" "Initializing model registry"
    
    # LLaMA 3 Models
    LEONARDO_MODEL_REGISTRY["llama3-8b"]="llama-3-8b-instruct.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["llama3-8b"]="name:LLaMA 3 8B|size:4.7GB|format:gguf|quantization:Q4_K_M|family:llama|license:llama3|url:https://huggingface.co/TheBloke/Llama-3-8B-Instruct-GGUF/resolve/main/llama-3-8b-instruct.Q4_K_M.gguf|sha256:8daa8615d0e8b7975db0e939b7f32a3905ae8648f30833e73ab02577148c3354"
    
    LEONARDO_MODEL_REGISTRY["llama3-8b-q8"]="llama-3-8b-instruct.Q8_0.gguf"
    LEONARDO_MODEL_METADATA["llama3-8b-q8"]="name:LLaMA 3 8B Q8|size:8.5GB|format:gguf|quantization:Q8_0|family:llama|license:llama3|url:https://huggingface.co/TheBloke/Llama-3-8B-Instruct-GGUF/resolve/main/llama-3-8b-instruct.Q8_0.gguf|sha256:e5dc003066f7e8ac3ce23e8cc8d08b4ef3eb9e6e1e9989cf8b07b9d5dd626820"
    
    LEONARDO_MODEL_REGISTRY["llama3-70b"]="llama-3-70b-instruct.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["llama3-70b"]="name:LLaMA 3 70B|size:39.1GB|format:gguf|quantization:Q4_K_M|family:llama|license:llama3|url:https://huggingface.co/TheBloke/Llama-3-70B-Instruct-GGUF/resolve/main/llama-3-70b-instruct.Q4_K_M.gguf|sha256:0c0f952e0e2c86fd3a2bef8b5c1d7f5db96b5c523f96de33cc385d8cf1c87b73"
    
    # Mistral Models
    LEONARDO_MODEL_REGISTRY["mistral-7b"]="mistral-7b-instruct-v0.3.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["mistral-7b"]="name:Mistral 7B v0.3|size:4.1GB|format:gguf|quantization:Q4_K_M|family:mistral|license:apache-2.0|url:https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/mistral-7b-instruct-v0.3.Q4_K_M.gguf|sha256:b2f8e6cc58c476394e3e931b0e6e33b8389f5c55c0ff690e38e77ad219669816"
    
    LEONARDO_MODEL_REGISTRY["mistral-7b-q8"]="mistral-7b-instruct-v0.3.Q8_0.gguf"
    LEONARDO_MODEL_METADATA["mistral-7b-q8"]="name:Mistral 7B v0.3 Q8|size:7.7GB|format:gguf|quantization:Q8_0|family:mistral|license:apache-2.0|url:https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/mistral-7b-instruct-v0.3.Q8_0.gguf|sha256:4978bcbe6dc0c257f36339002a8e7f305ac640ad89fd97e5018a4df4b332a84a"
    
    # Mixtral Models
    LEONARDO_MODEL_REGISTRY["mixtral-8x7b"]="mixtral-8x7b-instruct-v0.1.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["mixtral-8x7b"]="name:Mixtral 8x7B|size:26.4GB|format:gguf|quantization:Q4_K_M|family:mixtral|license:apache-2.0|url:https://huggingface.co/TheBloke/Mixtral-8x7B-Instruct-v0.1-GGUF/resolve/main/mixtral-8x7b-instruct-v0.1.Q4_K_M.gguf|sha256:2395a53ed52ac1a8a7a93bfa5c7db1dd8b3a29b8e1567a5813ebd6f065d4fe3f"
    
    # Gemma Models
    LEONARDO_MODEL_REGISTRY["gemma-7b"]="gemma-7b-it.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["gemma-7b"]="name:Gemma 7B|size:5.0GB|format:gguf|quantization:Q4_K_M|family:gemma|license:gemma|url:https://huggingface.co/google/gemma-7b-it-GGUF/resolve/main/gemma-7b-it.Q4_K_M.gguf|sha256:4e94c2da4d43c861dd26dd31c6f11ace5b0799f0c52fef5f30a26a36b2d1cffe"
    
    LEONARDO_MODEL_REGISTRY["gemma-2b"]="gemma-2b-it.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["gemma-2b"]="name:Gemma 2B|size:1.7GB|format:gguf|quantization:Q4_K_M|family:gemma|license:gemma|url:https://huggingface.co/google/gemma-2b-it-GGUF/resolve/main/gemma-2b-it.Q4_K_M.gguf|sha256:7a2550ca621f42a6c91045c99c88dd2ece26c5032dc82ad87ae09076bbaa0bfb"
    
    # Phi Models
    LEONARDO_MODEL_REGISTRY["phi-3-mini"]="Phi-3-mini-4k-instruct-q4.gguf"
    LEONARDO_MODEL_METADATA["phi-3-mini"]="name:Phi 3 Mini 4K|size:2.2GB|format:gguf|quantization:Q4_K_M|family:phi|license:mit|url:https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf|sha256:09d16545cf09322a6b7e5054522f2fd4a8033327f4e2a978f051baf2c84a909f"
    
    # CodeLlama Models
    LEONARDO_MODEL_REGISTRY["codellama-7b"]="codellama-7b-instruct.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["codellama-7b"]="name:CodeLlama 7B|size:4.1GB|format:gguf|quantization:Q4_K_M|family:codellama|license:llama2|url:https://huggingface.co/TheBloke/CodeLlama-7B-Instruct-GGUF/resolve/main/codellama-7b-instruct.Q4_K_M.gguf|sha256:0e0bc5a4726d73022f90287e4fbc7609fd9bdffca87b35a5ba21fb30fc2b6618"
    
    # Vicuna Models
    LEONARDO_MODEL_REGISTRY["vicuna-13b"]="vicuna-13b-v1.5.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["vicuna-13b"]="name:Vicuna 13B v1.5|size:7.9GB|format:gguf|quantization:Q4_K_M|family:vicuna|license:llama|url:https://huggingface.co/TheBloke/vicuna-13B-v1.5-GGUF/resolve/main/vicuna-13b-v1.5.Q4_K_M.gguf|sha256:d62fc1034c2064a8c2fbe65f13fbab3c53a2362a84079bad76912094e5c87bd7"
    
    log_message "INFO" "Model registry initialized with ${#LEONARDO_MODEL_REGISTRY[@]} models"
}

# Source model database if available
if [[ -f "${LEONARDO_ROOT}/src/models/model_database.sh" ]]; then
    source "${LEONARDO_ROOT}/src/models/model_database.sh"
elif [[ -f "$(dirname "${BASH_SOURCE[0]}")/model_database.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/model_database.sh"
fi

# Get model metadata field
get_model_metadata() {
    local model_id="$1"
    local field="$2"
    
    if [[ -z "${LEONARDO_MODEL_METADATA[$model_id]:-}" ]]; then
        return 1
    fi
    
    local metadata="${LEONARDO_MODEL_METADATA[$model_id]}"
    local value=""
    
    # Parse metadata fields
    IFS='|' read -ra fields <<< "$metadata"
    for field_data in "${fields[@]}"; do
        IFS=':' read -r key val <<< "$field_data"
        if [[ "$key" == "$field" ]]; then
            echo "$val"
            return 0
        fi
    done
    
    return 1
}

# List available models from registry with enhanced formatting
list_models() {
    local format="${1:-table}"
    local provider="${2:-all}"
    
    # Get models from database
    local models=()
    if declare -F get_all_models >/dev/null 2>&1; then
        mapfile -t models < <(get_all_models)
    fi
    
    case "$format" in
        table)
            # Header
            printf "%-20s %-30s %-10s %-15s %-10s\n" \
                "ID" "Name" "Size" "Quantization" "License"
            printf "%s\n" "$(printf '%.0s-' {1..80})"
            
            # List models from database
            if [[ ${#models[@]} -gt 0 ]]; then
                for model in "${models[@]}"; do
                    IFS='|' read -r id name size quant license desc <<< "$model"
                    printf "%-20s %-30s %-10s %-15s %-10s\n" \
                        "$id" "$name" "$size" "$quant" "$license"
                done
            else
                # Fallback to registry
                for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
                    IFS='|' read -r name provider size quantization license tags <<< "${LEONARDO_MODEL_METADATA[$model_id]}"
                    
                    if [[ "$provider" == "all" ]] || [[ "$provider" == "$provider" ]]; then
                        printf "%-20s %-30s %-10s %-15s %-10s\n" \
                            "$model_id" "$name" "$size" "$quantization" "$license"
                    fi
                done
            fi
            ;;
        json)
            echo "{"
            local first=true
            for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
                [[ "$first" == "false" ]] && echo ","
                first=false
                
                echo -n "  \"$model_id\": {"
                echo -n "\"filename\": \"${LEONARDO_MODEL_REGISTRY[$model_id]}\", "
                echo -n "\"name\": \"$(get_model_metadata "$model_id" "name")\", "
                echo -n "\"size\": \"$(get_model_metadata "$model_id" "size")\", "
                echo -n "\"format\": \"$(get_model_metadata "$model_id" "format")\", "
                echo -n "\"quantization\": \"$(get_model_metadata "$model_id" "quantization")\", "
                echo -n "\"family\": \"$(get_model_metadata "$model_id" "family")\", "
                echo -n "\"license\": \"$(get_model_metadata "$model_id" "license")\", "
                echo -n "\"url\": \"$(get_model_metadata "$model_id" "url")\", "
                echo -n "\"sha256\": \"$(get_model_metadata "$model_id" "sha256")\""
                echo -n "}"
            done
            echo -e "\n}"
            ;;
        *)
            # Simple format
            for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
                echo "$model_id"
            done | sort
            ;;
    esac
}

# Get model info
get_model_info() {
    local model_id="$1"
    
    if [[ -z "${LEONARDO_MODEL_REGISTRY[$model_id]:-}" ]]; then
        log_message "ERROR" "Model not found: $model_id"
        return 1
    fi
    
    echo "${COLOR_CYAN}Model Information${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%40s' | tr ' ' '-')${COLOR_RESET}"
    echo "${COLOR_GREEN}ID:${COLOR_RESET}           $model_id"
    echo "${COLOR_GREEN}Filename:${COLOR_RESET}     ${LEONARDO_MODEL_REGISTRY[$model_id]}"
    echo "${COLOR_GREEN}Name:${COLOR_RESET}         $(get_model_metadata "$model_id" "name")"
    echo "${COLOR_GREEN}Size:${COLOR_RESET}         $(get_model_metadata "$model_id" "size")"
    echo "${COLOR_GREEN}Format:${COLOR_RESET}       $(get_model_metadata "$model_id" "format")"
    echo "${COLOR_GREEN}Quantization:${COLOR_RESET} $(get_model_metadata "$model_id" "quantization")"
    echo "${COLOR_GREEN}Family:${COLOR_RESET}       $(get_model_metadata "$model_id" "family")"
    echo "${COLOR_GREEN}License:${COLOR_RESET}      $(get_model_metadata "$model_id" "license")"
    echo "${COLOR_GREEN}SHA256:${COLOR_RESET}       $(get_model_metadata "$model_id" "sha256")"
}

# Search models by query
search_models() {
    local query="${1,,}"  # Convert to lowercase
    local found=false
    
    echo -e "${CYAN}Searching for models matching: ${WHITE}$query${COLOR_RESET}"
    echo ""
    
    # Search in database first
    if declare -F search_models_db >/dev/null 2>&1; then
        local results=()
        mapfile -t results < <(search_models_db "$query")
        
        if [[ ${#results[@]} -gt 0 ]]; then
            # Header
            printf "%-20s %-30s %-10s %-15s\n" \
                "ID" "Name" "Size" "License"
            printf "%s\n" "$(printf '%.0s-' {1..75})"
            
            for model in "${results[@]}"; do
                IFS='|' read -r id name size quant license desc <<< "$model"
                printf "%-20s %-30s %-10s %-15s\n" \
                    "$id" "$name" "$size" "$license"
                found=true
            done
            echo ""
            echo -e "${GREEN}Found ${#results[@]} model(s) matching '$query'${COLOR_RESET}"
            echo -e "${DIM}Tip: Use 'leonardo model download <id>' to download a model${COLOR_RESET}"
        fi
    fi
}

# Get recommended models by use case
get_recommended_models() {
    local use_case="$1"
    
    case "$use_case" in
        "general"|"chat")
            echo "llama3-8b mistral-7b gemma-7b vicuna-13b"
            ;;
        "coding"|"code")
            echo "codellama-7b llama3-8b mistral-7b"
            ;;
        "small"|"lightweight")
            echo "phi-3-mini gemma-2b mistral-7b"
            ;;
        "large"|"advanced")
            echo "llama3-70b mixtral-8x7b vicuna-13b"
            ;;
        "fast")
            echo "phi-3-mini gemma-2b mistral-7b llama3-8b"
            ;;
        *)
            echo "llama3-8b mistral-7b gemma-7b"
            ;;
    esac
}

# Validate model file
validate_model_file() {
    local model_path="$1"
    local expected_sha256="${2:-}"
    
    if [[ ! -f "$model_path" ]]; then
        log_message "ERROR" "Model file not found: $model_path"
        return 1
    fi
    
    # Check file size
    local file_size=$(stat -f%z "$model_path" 2>/dev/null || stat -c%s "$model_path" 2>/dev/null)
    if [[ $file_size -lt 1000000 ]]; then  # Less than 1MB
        log_message "ERROR" "Model file too small: $file_size bytes"
        return 1
    fi
    
    # Verify checksum if provided
    if [[ -n "$expected_sha256" ]]; then
        log_message "INFO" "Verifying model checksum..."
        local actual_sha256=$(sha256sum "$model_path" | awk '{print $1}')
        
        if [[ "$actual_sha256" != "$expected_sha256" ]]; then
            log_message "ERROR" "Checksum mismatch!"
            log_message "ERROR" "Expected: $expected_sha256"
            log_message "ERROR" "Actual:   $actual_sha256"
            return 1
        fi
        
        log_message "INFO" "Checksum verified successfully"
    fi
    
    # Check file format
    local file_ext="${model_path##*.}"
    case "$file_ext" in
        gguf|ggml|bin|pth|safetensors)
            log_message "INFO" "Valid model format: $file_ext"
            ;;
        *)
            log_message "WARN" "Unknown model format: $file_ext"
            ;;
    esac
    
    return 0
}

# Export model registry functions
export -f init_model_registry list_models get_model_info search_models
export -f get_model_metadata get_recommended_models validate_model_file
