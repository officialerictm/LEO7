#!/bin/bash
#
# Leonardo AI Universal - Model Metadata Management
# Defines model metadata structure and utilities
#

# Model metadata schema version
readonly MODEL_METADATA_VERSION="1.0.0"

# Model types
readonly MODEL_TYPE_LLM="llm"
readonly MODEL_TYPE_IMAGE="image"
readonly MODEL_TYPE_AUDIO="audio"
readonly MODEL_TYPE_VIDEO="video"
readonly MODEL_TYPE_EMBEDDING="embedding"

# Model providers
readonly PROVIDER_OLLAMA="ollama"
readonly PROVIDER_HUGGINGFACE="huggingface"
readonly PROVIDER_OPENAI="openai"
readonly PROVIDER_CUSTOM="custom"

# Create model metadata JSON
create_model_metadata() {
    local name="$1"
    local type="$2"
    local provider="$3"
    local version="$4"
    local size="$5"
    local description="$6"
    
    cat <<EOF
{
    "schema_version": "$MODEL_METADATA_VERSION",
    "name": "$name",
    "type": "$type",
    "provider": "$provider",
    "version": "$version",
    "size": "$size",
    "description": "$description",
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "requirements": {
        "min_ram": "8GB",
        "min_disk": "$size",
        "gpu": false
    },
    "files": [],
    "config": {},
    "tags": []
}
EOF
}

# Parse model metadata from JSON
parse_model_metadata() {
    local json_file="$1"
    local field="$2"
    
    if [[ -f "$json_file" ]]; then
        # Simple JSON parsing without jq dependency
        grep "\"$field\":" "$json_file" | sed 's/.*"'$field'": *"\([^"]*\)".*/\1/' | head -1
    fi
}

# Validate model metadata
validate_model_metadata() {
    local metadata_file="$1"
    
    if [[ ! -f "$metadata_file" ]]; then
        log_error "Metadata file not found: $metadata_file"
        return 1
    fi
    
    # Check required fields
    local required_fields=("name" "type" "provider" "version" "size")
    for field in "${required_fields[@]}"; do
        local value=$(parse_model_metadata "$metadata_file" "$field")
        if [[ -z "$value" ]]; then
            log_error "Missing required field: $field"
            return 1
        fi
    done
    
    return 0
}

# Get model install path
get_model_install_path() {
    local provider="$1"
    local name="$2"
    local version="$3"
    
    echo "${LEONARDO_MODELS_DIR}/${provider}/${name}/${version}"
}

# Check if model is installed
is_model_installed() {
    local provider="$1"
    local name="$2"
    local version="$3"
    
    local install_path=$(get_model_install_path "$provider" "$name" "$version")
    [[ -d "$install_path" && -f "$install_path/metadata.json" ]]
}

# Export functions
export -f create_model_metadata
export -f parse_model_metadata
export -f validate_model_metadata
export -f get_model_install_path
export -f is_model_installed
