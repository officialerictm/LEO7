#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Model CLI
# ==============================================================================
# Description: Command-line interface for model management
# Version: 7.0.0
# Dependencies: all model modules, colors.sh, logging.sh
# ==============================================================================

# Model CLI help
show_model_help() {
    cat << EOF
${COLOR_CYAN}Leonardo Model Management${COLOR_RESET}

${COLOR_GREEN}Usage:${COLOR_RESET}
  leonardo model <command> [options]

${COLOR_GREEN}Commands:${COLOR_RESET}
  list              List available models
  installed         List installed models
  info <model>      Show model information
  download <model>  Download a model
  delete <model>    Delete an installed model
  import <file>     Import a model from file
  export <model>    Export a model to file
  search <query>    Search for models
  compare           Compare two models
  select            Interactive model selector
  update            Update model registry
  preferences       Configure model preferences

${COLOR_GREEN}Examples:${COLOR_RESET}
  leonardo model list
  leonardo model download llama3-8b
  leonardo model info mistral-7b
  leonardo model search llama
  leonardo model import ~/models/llama-3-8b.gguf
  leonardo model export llama3-8b ~/backup/

${COLOR_GREEN}Quick Start:${COLOR_RESET}
  leonardo model select    # Interactive model selection

EOF
}

# Model CLI router
handle_model_command() {
    local command="${1:-help}"
    shift
    
    # Initialize model manager if needed
    if [[ -z "${LEONARDO_MODEL_REGISTRY[*]:-}" ]]; then
        init_model_manager
    fi
    
    case "$command" in
        "list"|"ls")
            handle_model_list "$@"
            ;;
        "installed"|"i")
            list_installed_models
            ;;
        "info"|"show")
            handle_model_info "$@"
            ;;
        "download"|"dl"|"get")
            handle_model_download "$@"
            ;;
        "delete"|"rm"|"remove")
            handle_model_delete "$@"
            ;;
        "import")
            handle_model_import "$@"
            ;;
        "export")
            handle_model_export "$@"
            ;;
        "search"|"find")
            handle_model_search "$@"
            ;;
        "compare"|"diff")
            handle_model_compare "$@"
            ;;
        "select"|"choose")
            interactive_model_selector "$@"
            ;;
        "update"|"refresh")
            update_model_registry
            ;;
        "preferences"|"prefs"|"config")
            configure_model_preferences
            ;;
        "help"|"--help"|"-h")
            show_model_help
            ;;
        *)
            echo "${COLOR_RED}Unknown model command: $command${COLOR_RESET}"
            echo "Run 'leonardo model help' for usage"
            return 1
            ;;
    esac
}

# Handle model list command
handle_model_list() {
    local filter="${1:-}"
    local format="${2:-table}"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --json)
                format="json"
                ;;
            --simple)
                format="simple"
                ;;
            --filter=*)
                filter="${1#*=}"
                ;;
            --family=*)
                filter="${1#*=}"
                ;;
            --installed)
                filter="installed"
                ;;
            *)
                filter="$1"
                ;;
        esac
        shift
    done
    
    # Special case for installed filter
    if [[ "$filter" == "installed" ]]; then
        list_installed_models
        return
    fi
    
    list_models "$filter" "$format"
}

# Handle model info command
handle_model_info() {
    local model_id="$1"
    
    if [[ -z "$model_id" ]]; then
        echo "${COLOR_RED}Error: Model ID required${COLOR_RESET}"
        echo "Usage: leonardo model info <model-id>"
        return 1
    fi
    
    get_model_info "$model_id"
}

# Handle model download command
handle_model_download() {
    local model_id="$1"
    local force=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                force=true
                ;;
            --*)
                echo "${COLOR_RED}Unknown option: $1${COLOR_RESET}"
                return 1
                ;;
            *)
                model_id="$1"
                ;;
        esac
        shift
    done
    
    if [[ -z "$model_id" ]]; then
        # Interactive selection
        model_id=$(model_selection_menu)
        [[ -z "$model_id" ]] && return 1
    fi
    
    download_model "$model_id" "$force"
}

# Handle model delete command
handle_model_delete() {
    local model_id="$1"
    
    if [[ -z "$model_id" ]]; then
        # Show installed models for selection
        echo "${COLOR_CYAN}Select model to delete:${COLOR_RESET}"
        list_installed_models
        echo ""
        model_id=$(show_input_dialog "Model ID to delete:")
        [[ -z "$model_id" ]] && return 1
    fi
    
    delete_model "$model_id"
}

# Handle model import command
handle_model_import() {
    local file_path="$1"
    local model_id="$2"
    
    if [[ -z "$file_path" ]]; then
        echo "${COLOR_RED}Error: File path required${COLOR_RESET}"
        echo "Usage: leonardo model import <file> [model-id]"
        return 1
    fi
    
    import_model "$file_path" "$model_id"
}

# Handle model export command
handle_model_export() {
    local model_id="$1"
    local export_path="${2:-$PWD}"
    
    if [[ -z "$model_id" ]]; then
        # Show installed models for selection
        echo "${COLOR_CYAN}Select model to export:${COLOR_RESET}"
        list_installed_models
        echo ""
        model_id=$(show_input_dialog "Model ID to export:")
        [[ -z "$model_id" ]] && return 1
    fi
    
    export_model "$model_id" "$export_path"
}

# Handle model search command
handle_model_search() {
    local query="$1"
    
    if [[ -z "$query" ]]; then
        query=$(show_input_dialog "Search query:")
        [[ -z "$query" ]] && return 1
    fi
    
    search_models "$query"
}

# Handle model compare command
handle_model_compare() {
    local model1="$1"
    local model2="$2"
    
    compare_models "$model1" "$model2"
}

# Model batch operations
batch_download_models() {
    local models=("$@")
    
    if [[ ${#models[@]} -eq 0 ]]; then
        # Interactive multi-select
        local all_models=()
        local display_names=()
        
        for model_id in $(list_models "" "simple" | sort); do
            if [[ "$(get_model_status "$model_id")" != "installed" ]]; then
                all_models+=("$model_id")
                display_names+=("$(get_model_metadata "$model_id" "name") ($(get_model_metadata "$model_id" "size"))")
            fi
        done
        
        local selected=$(show_checklist "Select models to download:" "${display_names[@]}")
        
        if [[ -z "$selected" ]]; then
            return 1
        fi
        
        for idx in $selected; do
            models+=("${all_models[$idx]}")
        done
    fi
    
    echo "${COLOR_CYAN}Batch download: ${#models[@]} models${COLOR_RESET}"
    echo ""
    
    local success=0
    local failed=0
    
    for model_id in "${models[@]}"; do
        echo "${COLOR_YELLOW}Downloading: $model_id${COLOR_RESET}"
        if download_model "$model_id"; then
            ((success++))
        else
            ((failed++))
        fi
        echo ""
    done
    
    echo "${COLOR_CYAN}Batch download complete${COLOR_RESET}"
    echo "${COLOR_GREEN}Success: $success${COLOR_RESET}"
    [[ $failed -gt 0 ]] && echo "${COLOR_RED}Failed: $failed${COLOR_RESET}"
}

# Model statistics
show_model_statistics() {
    echo "${COLOR_CYAN}Model Statistics${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%60s' | tr ' ' '-')${COLOR_RESET}"
    
    # Total models
    echo "Total models available: ${#LEONARDO_MODEL_REGISTRY[@]}"
    echo "Models installed: ${#LEONARDO_INSTALLED_MODELS[@]}"
    
    # By family
    echo ""
    echo "${COLOR_GREEN}Models by family:${COLOR_RESET}"
    declare -A family_count
    for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
        local family=$(get_model_metadata "$model_id" "family")
        ((family_count[$family]++))
    done
    
    for family in "${!family_count[@]}"; do
        printf "  %-15s %3d models\n" "$family:" "${family_count[$family]}"
    done
    
    # Disk usage
    if [[ ${#LEONARDO_INSTALLED_MODELS[@]} -gt 0 ]]; then
        echo ""
        echo "${COLOR_GREEN}Disk usage:${COLOR_RESET}"
        local total_size=0
        for model_path in "${LEONARDO_INSTALLED_MODELS[@]}"; do
            if [[ -f "$model_path" ]]; then
                local size=$(stat -f%z "$model_path" 2>/dev/null || stat -c%s "$model_path" 2>/dev/null || echo 0)
                ((total_size += size))
            fi
        done
        echo "  Total: $(format_bytes $total_size)"
        echo "  Average: $(format_bytes $((total_size / ${#LEONARDO_INSTALLED_MODELS[@]})))"
    fi
}

# Export CLI functions
export -f handle_model_command show_model_help batch_download_models show_model_statistics
