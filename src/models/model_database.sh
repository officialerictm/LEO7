#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Model Database
# ==============================================================================
# Description: Curated list of AI models for easy discovery and download
# Version: 7.0.0
# ==============================================================================

# Model database format: "id|name|size|quantization|license|description"
declare -a MODEL_DATABASE=(
    # Llama Models
    "llama3.2:3b|Llama 3.2 3B|1.9GB|Q4_0|Llama|Latest Llama model, great for general tasks"
    "llama3.2:1b|Llama 3.2 1B|1.3GB|Q4_0|Llama|Tiny but capable Llama model"
    "llama3.1:8b|Llama 3.1 8B|4.7GB|Q4_0|Llama|Balanced performance and size"
    "llama3.1:70b|Llama 3.1 70B|40GB|Q4_0|Llama|Large model for complex tasks"
    "llama3:8b|Llama 3 8B|4.5GB|Q4_0|Llama|Classic Llama 3 model"
    "llama2:7b|Llama 2 7B|3.8GB|Q4_0|Llama|Previous generation Llama"
    "llama2:13b|Llama 2 13B|7.3GB|Q4_0|Llama|Larger Llama 2 variant"
    
    # Code Models
    "codellama:7b|Code Llama 7B|3.8GB|Q4_0|Llama|Specialized for coding"
    "codellama:13b|Code Llama 13B|7.3GB|Q4_0|Llama|Larger code model"
    "codellama:34b|Code Llama 34B|19GB|Q4_0|Llama|Professional code assistant"
    "codegemma:7b|CodeGemma 7B|4.8GB|Q4_0|Gemma|Google's code model"
    "deepseek-coder:6.7b|DeepSeek Coder|3.8GB|Q4_0|MIT|Excellent for code generation"
    "starcoder2:3b|StarCoder2 3B|1.9GB|Q4_0|BigCode|Compact code model"
    
    # Mistral Models
    "mistral:7b|Mistral 7B|4.1GB|Q4_0|Apache-2.0|Fast and efficient"
    "mistral-nemo:12b|Mistral Nemo|7.1GB|Q4_0|Apache-2.0|Enhanced Mistral model"
    "mixtral:8x7b|Mixtral 8x7B|26GB|Q4_0|Apache-2.0|Mixture of experts model"
    "mixtral:8x22b|Mixtral 8x22B|131GB|Q4_0|Apache-2.0|Large MoE model"
    
    # Gemma Models
    "gemma2:2b|Gemma 2 2B|1.6GB|Q4_0|Gemma|Google's efficient model"
    "gemma2:9b|Gemma 2 9B|5.5GB|Q4_0|Gemma|Larger Gemma variant"
    "gemma2:27b|Gemma 2 27B|16GB|Q4_0|Gemma|High performance Gemma"
    
    # Phi Models
    "phi3:3b|Phi-3 Mini|2.0GB|Q4_0|MIT|Microsoft's compact model"
    "phi3:14b|Phi-3 Medium|7.9GB|Q4_0|MIT|Balanced Phi model"
    
    # Qwen Models
    "qwen2.5:0.5b|Qwen 2.5 0.5B|0.4GB|Q4_0|Qwen|Ultra-light model"
    "qwen2.5:3b|Qwen 2.5 3B|1.9GB|Q4_0|Qwen|Efficient Chinese/English"
    "qwen2.5:7b|Qwen 2.5 7B|4.4GB|Q4_0|Qwen|Balanced Qwen model"
    "qwen2.5:14b|Qwen 2.5 14B|8.2GB|Q4_0|Qwen|Large Qwen variant"
    "qwen2.5:32b|Qwen 2.5 32B|18GB|Q4_0|Qwen|High-end Qwen model"
    
    # Specialized Models
    "dolphin-mistral:7b|Dolphin Mistral|4.1GB|Q4_0|Apache-2.0|Uncensored assistant"
    "neural-chat:7b|Neural Chat|4.1GB|Q4_0|Apache-2.0|Intel's chat model"
    "starling-lm:7b|Starling LM|4.1GB|Q4_0|Apache-2.0|Berkeley's chat model"
    "vicuna:7b|Vicuna 7B|3.8GB|Q4_0|Llama|Fine-tuned on conversations"
    "orca-mini:3b|Orca Mini|1.9GB|Q4_0|Apache-2.0|Reasoning-focused model"
    
    # Math & Science
    "mathstral:7b|Mathstral|4.1GB|Q4_0|Apache-2.0|Mathematics specialist"
    "meditron:7b|Meditron|4.1GB|Q4_0|Llama|Medical knowledge model"
    
    # Vision Models
    "llava:7b|LLaVA 7B|4.5GB|Q4_0|Llama|Vision + Language model"
    "llava:13b|LLaVA 13B|8.0GB|Q4_0|Llama|Larger vision model"
    "bakllava:7b|BakLLaVA|4.5GB|Q4_0|Llama|Improved LLaVA variant"
    
    # Embedding Models
    "nomic-embed-text|Nomic Embed|274MB|F16|Apache-2.0|Text embeddings"
    "all-minilm|All-MiniLM|45MB|F16|Apache-2.0|Sentence embeddings"
)

# Get all available models
get_all_models() {
    printf '%s\n' "${MODEL_DATABASE[@]}"
}

# Search models by keyword
search_models_db() {
    local query="${1,,}"  # Convert to lowercase
    
    for model in "${MODEL_DATABASE[@]}"; do
        local lower_model="${model,,}"
        if [[ "$lower_model" =~ $query ]]; then
            echo "$model"
        fi
    done
}

# Get model by exact ID
get_model_by_id() {
    local id="$1"
    
    for model in "${MODEL_DATABASE[@]}"; do
        local model_id="${model%%|*}"
        if [[ "$model_id" == "$id" ]]; then
            echo "$model"
            return 0
        fi
    done
    
    return 1
}

# Format model for display
format_model_info() {
    local model="$1"
    IFS='|' read -r id name size quant license desc <<< "$model"
    
    echo "Model ID: $id"
    echo "Name: $name"
    echo "Size: $size"
    echo "Quantization: $quant"
    echo "License: $license"
    echo "Description: $desc"
}

# Get models by category
get_models_by_category() {
    local category="$1"
    
    case "$category" in
        "code")
            search_models_db "code\|starcoder\|deepseek-coder"
            ;;
        "chat")
            search_models_db "chat\|vicuna\|dolphin\|neural"
            ;;
        "vision")
            search_models_db "llava\|bakllava"
            ;;
        "tiny")
            for model in "${MODEL_DATABASE[@]}"; do
                local size=$(echo "$model" | cut -d'|' -f3)
                # Extract numeric value
                local num=${size%GB*}
                num=${num%MB*}
                if (( $(echo "$num < 2" | bc -l) )); then
                    echo "$model"
                fi
            done
            ;;
        "large")
            for model in "${MODEL_DATABASE[@]}"; do
                local size=$(echo "$model" | cut -d'|' -f3)
                # Extract numeric value
                local num=${size%GB*}
                if [[ "$size" == *"GB" ]] && (( $(echo "$num > 20" | bc -l) )); then
                    echo "$model"
                fi
            done
            ;;
    esac
}

# Suggest models based on system specs
suggest_models() {
    local available_ram="$1"  # in GB
    
    echo "=== Recommended Models for Your System ==="
    echo ""
    
    if (( $(echo "$available_ram < 8" | bc -l) )); then
        echo "⚡ Tiny Models (< 2GB) - Best for your system:"
        get_models_by_category "tiny" | head -5
    elif (( $(echo "$available_ram < 16" | bc -l) )); then
        echo "⚡ Small Models (< 5GB) - Good performance:"
        search_models_db "3b\|7b" | grep -E "3b|7b" | head -5
    elif (( $(echo "$available_ram < 32" | bc -l) )); then
        echo "⚡ Medium Models (< 10GB) - Excellent capabilities:"
        search_models_db "7b\|13b" | head -5
    else
        echo "⚡ Large Models - Maximum performance:"
        get_models_by_category "large" | head -5
    fi
}
