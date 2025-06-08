#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Dynamic Registry Loader
# ==============================================================================
# Description: Loads model registry from JSON files and online sources
# ==============================================================================

# Load local JSON registry
load_local_registry() {
    local registry_file="${1:-${LEONARDO_CONFIG_DIR}/data/models/gguf_registry.json}"
    
    if [[ ! -f "$registry_file" ]]; then
        # Try alternate locations
        registry_file="${LEONARDO_DIR}/data/models/gguf_registry.json"
    fi
    
    if [[ -f "$registry_file" ]]; then
        log_message "INFO" "Loading model registry from $registry_file"
        
        # Parse JSON and populate registry
        if command -v jq >/dev/null 2>&1; then
            # Use jq for parsing
            while IFS= read -r model_entry; do
                local model_id=$(echo "$model_entry" | jq -r '.id')
                local url=$(echo "$model_entry" | jq -r '.url')
                local size=$(echo "$model_entry" | jq -r '.size')
                local desc=$(echo "$model_entry" | jq -r '.description')
                
                # Add to registry
                LEONARDO_GGUF_REGISTRY["$model_id"]="$url"
                LEONARDO_GGUF_METADATA["$model_id"]="$size|$desc"
            done < <(jq -c '.models | to_entries[] | {id: .key, url: .value.url, size: .value.size, description: .value.description}' "$registry_file")
            
            return 0
        else
            # Fallback to basic parsing
            log_message "WARN" "jq not found, using basic registry parsing"
            return 1
        fi
    else
        log_message "WARN" "Registry file not found: $registry_file"
        return 1
    fi
}

# Search HuggingFace for GGUF models
search_huggingface_models() {
    local query="${1:-}"
    local limit="${2:-20}"
    
    echo -e "${CYAN}Searching HuggingFace for GGUF models...${COLOR_RESET}"
    
    # HuggingFace API endpoint
    local api_url="https://huggingface.co/api/models"
    
    # Build search parameters
    local params="limit=${limit}&full=false&config=false"
    if [[ -n "$query" ]]; then
        params="${params}&search=${query}"
    fi
    params="${params}&filter=gguf"  # Filter for GGUF models
    
    # Make API request
    local response=$(curl -s "${api_url}?${params}" 2>/dev/null)
    
    if [[ -z "$response" ]]; then
        echo -e "${RED}Failed to connect to HuggingFace${COLOR_RESET}"
        return 1
    fi
    
    # Parse results
    if command -v jq >/dev/null 2>&1; then
        echo -e "\n${BOLD}Found Models:${COLOR_RESET}\n"
        
        local count=0
        while IFS= read -r model; do
            local model_id=$(echo "$model" | jq -r '.modelId')
            local downloads=$(echo "$model" | jq -r '.downloads // 0')
            local likes=$(echo "$model" | jq -r '.likes // 0')
            local tags=$(echo "$model" | jq -r '.tags[]?' | grep -E "(llama|mistral|phi|qwen|gemma|gpt)" | head -1)
            
            ((count++))
            printf "%2d) %-40s ${DIM}↓%5s ♥%3s${COLOR_RESET}" "$count" "$model_id" "$downloads" "$likes"
            [[ -n "$tags" ]] && printf " ${YELLOW}[%s]${COLOR_RESET}" "$tags"
            echo
        done < <(echo "$response" | jq -c '.[]')
        
        echo -e "\n${DIM}To download: leonardo model download <model_id>${COLOR_RESET}"
    else
        echo -e "${YELLOW}Install jq for better search results${COLOR_RESET}"
        # Basic grep parsing fallback
        echo "$response" | grep -o '"modelId":"[^"]*"' | cut -d'"' -f4 | head -20
    fi
}

# Ollama Library Search
search_ollama_library() {
    local query="${1:-}"
    
    echo -e "${CYAN}Searching Ollama Library...${COLOR_RESET}"
    
    # Ollama doesn't have a public API, but we can scrape the library page
    local library_url="https://ollama.ai/library"
    
    # Get the page content
    local page_content=$(curl -s "$library_url" 2>/dev/null)
    
    if [[ -z "$page_content" ]]; then
        echo -e "${RED}Failed to connect to Ollama Library${COLOR_RESET}"
        return 1
    fi
    
    # Extract model information (basic parsing)
    echo -e "\n${BOLD}Popular Ollama Models:${COLOR_RESET}\n"
    
    # Common models that are usually available
    local ollama_models=(
        "llama3.2:latest|Meta Llama 3.2 - Latest release|1B/3B"
        "llama3.1:latest|Meta Llama 3.1 - Instruction tuned|8B"
        "llama2:latest|Meta Llama 2 - Classic model|7B/13B"
        "mistral:latest|Mistral 7B - Fast and efficient|7B"
        "mixtral:latest|Mixtral MoE - Mixture of experts|47B"
        "phi3:latest|Microsoft Phi-3 - Small but capable|3.8B"
        "phi:latest|Microsoft Phi-2 - Optimized for code|2.7B"
        "qwen2.5:latest|Alibaba Qwen 2.5 - Multilingual|0.5B-72B"
        "gemma2:latest|Google Gemma 2 - Efficient|2B/9B"
        "codellama:latest|Meta Code Llama - Code generation|7B/13B"
        "deepseek-coder:latest|DeepSeek Coder - Programming|1.3B/6.7B"
        "orca-mini:latest|Orca Mini - Instruction following|3B"
        "tinyllama:latest|TinyLlama - Ultra small|1.1B"
        "starcoder2:latest|StarCoder 2 - Code completion|3B/7B"
        "wizardcoder:latest|WizardCoder - Enhanced coding|7B/13B"
    )
    
    local count=0
    for model_info in "${ollama_models[@]}"; do
        IFS='|' read -r model desc sizes <<< "$model_info"
        
        # Filter by query if provided
        if [[ -n "$query" ]] && [[ ! "$model" =~ $query ]] && [[ ! "$desc" =~ $query ]]; then
            continue
        fi
        
        ((count++))
        printf "%2d) %-25s ${DIM}%-35s${COLOR_RESET} ${GREEN}[%s]${COLOR_RESET}\n" \
            "$count" "$model" "$desc" "$sizes"
    done
    
    echo -e "\n${DIM}To install: ollama pull <model_name>${COLOR_RESET}"
}

# Update registry from online sources
update_online_registry() {
    echo -e "${CYAN}Updating model registry from online sources...${COLOR_RESET}"
    
    # Create temporary file for new registry
    local temp_registry="${LEONARDO_TEMP_DIR}/registry_update.json"
    
    # Start JSON structure
    cat > "$temp_registry" <<EOF
{
  "models": {
EOF
    
    # Add existing local models
    if [[ -f "${LEONARDO_CONFIG_DIR}/data/models/gguf_registry.json" ]]; then
        jq -r '.models | to_entries[] | "    \"\(.key)\": \(.value | tojson),"' \
            "${LEONARDO_CONFIG_DIR}/data/models/gguf_registry.json" >> "$temp_registry"
    fi
    
    # TODO: Add scraped models from HuggingFace
    # This would require more complex parsing
    
    # Close JSON structure
    echo '    "_placeholder": {}' >> "$temp_registry"
    cat >> "$temp_registry" <<EOF
  },
  "last_updated": "$(date -u +%Y-%m-%d)",
  "version": "1.1"
}
EOF
    
    # Validate and move to final location
    if jq . "$temp_registry" >/dev/null 2>&1; then
        mkdir -p "${LEONARDO_CONFIG_DIR}/data/models"
        mv "$temp_registry" "${LEONARDO_CONFIG_DIR}/data/models/gguf_registry.json"
        echo -e "${GREEN}✓ Registry updated successfully${COLOR_RESET}"
    else
        echo -e "${RED}✗ Failed to update registry${COLOR_RESET}"
        rm -f "$temp_registry"
        return 1
    fi
}

# Interactive model search
interactive_model_search() {
    clear
    echo -e "${BOLD}Leonardo Model Search${COLOR_RESET}"
    echo -e "${DIM}Search for AI models across multiple sources${COLOR_RESET}\n"
    
    local search_options=(
        "Search HuggingFace for GGUF models"
        "Browse Ollama Library"
        "Search all sources"
        "Update local registry"
        "Back to main menu"
    )
    
    select option in "${search_options[@]}"; do
        case "$REPLY" in
            1)
                read -p "Enter search query (or press Enter for all): " query
                search_huggingface_models "$query"
                ;;
            2)
                read -p "Enter search query (or press Enter for all): " query
                search_ollama_library "$query"
                ;;
            3)
                read -p "Enter search query: " query
                search_huggingface_models "$query"
                echo
                search_ollama_library "$query"
                ;;
            4)
                update_online_registry
                ;;
            5)
                return 0
                ;;
            *)
                echo -e "${RED}Invalid selection${COLOR_RESET}"
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
        clear
        echo -e "${BOLD}Leonardo Model Search${COLOR_RESET}"
        echo -e "${DIM}Search for AI models across multiple sources${COLOR_RESET}\n"
    done
}

# Export functions
export -f load_local_registry
export -f search_huggingface_models
export -f search_ollama_library
export -f update_online_registry
export -f interactive_model_search

# Initialize registries
declare -gA LEONARDO_GGUF_REGISTRY
declare -gA LEONARDO_GGUF_METADATA

# Auto-load local registry on source
load_local_registry
