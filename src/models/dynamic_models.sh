#!/usr/bin/env bash
# Dynamic Model Registry - Fetch live model lists

# Source dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../utils/colors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/network.sh"

# Model registry sources
declare -A MODEL_REGISTRIES=(
    ["ollama"]="https://ollama.com/api/tags"
    ["leonardo"]="https://raw.githubusercontent.com/officialerictm/leonardo-models/main/registry.json"
    ["huggingface"]="https://huggingface.co/api/models?filter=gguf&sort=downloads"
)

# Fetch models from Ollama library
fetch_ollama_models() {
    local cache_file="${LEONARDO_BASE_DIR}/.cache/ollama_models.json"
    local cache_age=3600  # 1 hour cache
    
    # Check cache
    if [[ -f "$cache_file" ]]; then
        local file_age=$(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null)))
        if [[ $file_age -lt $cache_age ]]; then
            cat "$cache_file"
            return 0
        fi
    fi
    
    echo -e "${DIM}Fetching latest models from Ollama...${COLOR_RESET}" >&2
    
    # Try to fetch from ollama.com (unofficial API)
    local models_json=$(curl -s "https://ollama.com/api/tags" 2>/dev/null || \
                       curl -s "https://registry.ollama.ai/v2/library/models" 2>/dev/null)
    
    if [[ -n "$models_json" ]]; then
        # Cache the result
        mkdir -p "$(dirname "$cache_file")"
        echo "$models_json" > "$cache_file"
        echo "$models_json"
    else
        # Fallback to predefined list if API fails
        cat << 'EOF'
{
  "models": [
    {"name": "llama3.2:1b", "size": "1GB", "description": "Compact Llama 3.2 model"},
    {"name": "llama3.2:3b", "size": "2GB", "description": "Llama 3.2 3B parameters"},
    {"name": "gemma2:2b", "size": "2GB", "description": "Google's Gemma 2B"},
    {"name": "qwen2.5:3b", "size": "2GB", "description": "Alibaba's Qwen 2.5"},
    {"name": "phi3:mini", "size": "2GB", "description": "Microsoft Phi-3 Mini"},
    {"name": "mistral:7b", "size": "4GB", "description": "Mistral 7B"},
    {"name": "llama3.1:8b", "size": "5GB", "description": "Meta Llama 3.1 8B"},
    {"name": "codellama:7b", "size": "4GB", "description": "Code-focused Llama"},
    {"name": "mixtral:8x7b", "size": "26GB", "description": "Mixture of experts"},
    {"name": "llama2:70b", "size": "40GB", "description": "Large Llama 2"}
  ]
}
EOF
    fi
}

# Fetch models from custom registry
fetch_custom_registry() {
    local registry_url="${1:-$LEONARDO_MODEL_REGISTRY}"
    
    if [[ -z "$registry_url" ]]; then
        return 1
    fi
    
    echo -e "${DIM}Fetching models from custom registry...${COLOR_RESET}" >&2
    curl -s "$registry_url" 2>/dev/null
}

# Get dynamic model list
get_dynamic_models() {
    local source="${1:-ollama}"
    local custom_url="$2"
    
    case "$source" in
        "ollama")
            fetch_ollama_models
            ;;
        "custom")
            fetch_custom_registry "$custom_url"
            ;;
        "cached")
            # Use only cached/offline models
            list_cached_models
            ;;
        *)
            echo '{"error": "Unknown source"}'
            ;;
    esac
}

# List locally cached models
list_cached_models() {
    local models_dir="${LEONARDO_BASE_DIR}/models"
    local usb_models="${LEONARDO_USB_MOUNT}/leonardo/models"
    
    echo '{"models": ['
    local first=true
    
    # Check local models directory
    for model in "$models_dir"/*.gguf "$usb_models"/*.gguf; do
        if [[ -f "$model" ]]; then
            [[ "$first" == "false" ]] && echo ","
            local name=$(basename "$model" .gguf)
            local size=$(du -h "$model" | cut -f1)
            echo -n "  {\"name\": \"$name\", \"size\": \"$size\", \"location\": \"local\"}"
            first=false
        fi
    done
    
    echo -e "\n]}"
}

# Interactive model selector with dynamic list
select_model_dynamic() {
    local prompt="${1:-Select a model:}"
    
    # Try to fetch dynamic list
    local models_json=$(get_dynamic_models "ollama")
    
    # Parse models
    local -a model_names=()
    local -a model_sizes=()
    local -a model_descs=()
    
    if command -v jq &> /dev/null; then
        # Use jq if available
        while IFS= read -r line; do
            model_names+=("$(echo "$line" | jq -r .name)")
            model_sizes+=("$(echo "$line" | jq -r .size)")
            model_descs+=("$(echo "$line" | jq -r .description // "")")
        done < <(echo "$models_json" | jq -c '.models[]')
    else
        # Fallback parser
        # Extract models using grep/sed
        while IFS= read -r name; do
            model_names+=("$name")
        done < <(echo "$models_json" | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)"/\1/')
        
        while IFS= read -r size; do
            model_sizes+=("$size")
        done < <(echo "$models_json" | grep -o '"size"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)"/\1/')
    fi
    
    # Add option to use custom registry
    model_names+=("📡 Use custom model registry")
    model_names+=("💾 Show offline models only")
    model_names+=("⏭️  Skip")
    
    # Display menu
    echo -e "${CYAN}$prompt${COLOR_RESET}"
    echo -e "${DIM}Models fetched from: ${MODEL_REGISTRIES[ollama]:-offline}${COLOR_RESET}"
    echo
    
    local i=1
    for idx in "${!model_names[@]}"; do
        local name="${model_names[$idx]}"
        local size="${model_sizes[$idx]:-}"
        local desc="${model_descs[$idx]:-}"
        
        if [[ -n "$size" ]]; then
            printf "%2d) %-20s %10s  %s\n" "$i" "$name" "($size)" "$desc"
        else
            printf "%2d) %s\n" "$i" "$name"
        fi
        ((i++))
    done
    
    # Get selection
    echo
    read -p "Enter choice (1-${#model_names[@]}): " choice
    
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#model_names[@]}" ]]; then
        local selected="${model_names[$((choice-1))]}"
        
        case "$selected" in
            "📡 Use custom model registry")
                read -p "Enter custom registry URL: " custom_url
                export LEONARDO_MODEL_REGISTRY="$custom_url"
                select_model_dynamic "$prompt"  # Recurse with custom registry
                ;;
            "💾 Show offline models only")
                local cached=$(list_cached_models)
                echo -e "${CYAN}Offline models:${COLOR_RESET}"
                echo "$cached" | jq -r '.models[] | "\(.name) (\(.size))"' 2>/dev/null || echo "$cached"
                ;;
            "⏭️  Skip")
                echo ""
                ;;
            *)
                echo "$selected"
                ;;
        esac
    else
        echo ""
    fi
}

# Export functions
export -f fetch_ollama_models
export -f fetch_custom_registry
export -f get_dynamic_models
export -f list_cached_models
export -f select_model_dynamic
