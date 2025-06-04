#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Model CLI
# ==============================================================================
# Description: Command-line interface for model management
# Version: 7.0.0
# Dependencies: all model modules, colors.sh, logging.sh
# ==============================================================================

# Model CLI help
model_cli_help() {
    cat << EOF
Leonardo Model Management

Commands:
  list [--installed]       List available or installed models
  info <model>            Show detailed model information
  install <model>         Download and install a model
  remove <model>          Remove an installed model
  run <model>             Run a model (if supported)
  update                  Update model registry

Model Format:
  <provider>:<model>:<variant>  Full specification
  <model>:<variant>             Model with variant (assumes Ollama)
  <model>                       Just model name (assumes Ollama:latest)

Examples:
  leonardo model list              # List available models
  leonardo model install llama2    # Install Llama 2 (latest)
  leonardo model install mistral:7b # Install Mistral 7B
  leonardo model run codellama     # Run Code Llama
  leonardo model info phi          # Show info about Phi model

Providers:
  ollama        Ollama models (default)
  huggingface   HuggingFace models (coming soon)
  custom        Custom models

EOF
}

# Parse model CLI commands
parse_model_command() {
    local command="$1"
    shift
    
    case "$command" in
        list)
            model_list_command "$@"
            ;;
        info)
            model_info_command "$@"
            ;;
        install|download)
            model_install_command "$@"
            ;;
        remove|delete|uninstall)
            model_remove_command "$@"
            ;;
        run|start)
            model_run_command "$@"
            ;;
        update)
            model_update_command "$@"
            ;;
        help|--help|-h)
            model_cli_help
            ;;
        *)
            log_error "Unknown model command: $command"
            model_cli_help
            return 1
            ;;
    esac
}

# List models command
model_list_command() {
    local installed_only=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --installed|-i)
                installed_only=true
                ;;
            *)
                log_error "Unknown option: $1"
                return 1
                ;;
        esac
        shift
    done
    
    if [[ "$installed_only" == "true" ]]; then
        list_installed_models
    else
        list_available_models
    fi
}

# Model info command
model_info_command() {
    local model_spec="$1"
    
    if [[ -z "$model_spec" ]]; then
        log_error "Model name required"
        echo "Usage: leonardo model info <model>"
        return 1
    fi
    
    local info=$(get_model_info "$model_spec")
    
    if [[ -n "$info" ]]; then
        echo "Model Information:"
        echo "=================="
        echo "$info" | python3 -m json.tool 2>/dev/null || echo "$info"
    else
        log_error "Failed to get model information"
        return 1
    fi
}

# Install model command
model_install_command() {
    local model_spec="$1"
    
    if [[ -z "$model_spec" ]]; then
        echo -e "${RED}Error: No model specified${COLOR_RESET}"
        echo "Usage: leonardo model install <model_id>"
        echo ""
        echo "Examples:"
        echo "  leonardo model install llama2"
        echo "  leonardo model install mistral:7b"
        echo "  leonardo model install codellama:13b"
        return 1
    fi
    
    # Initialize model system if needed
    if [[ ! -d "$LEONARDO_MODELS_DIR" ]]; then
        init_model_system || return 1
    fi
    
    # Check if Ollama needs to be installed
    if [[ "$model_spec" != *":"* ]] || [[ "$model_spec" == ollama:* ]]; then
        if ! check_ollama_installed; then
            log_warn "Ollama is not installed"
            echo -n "Would you like to install Ollama? [y/N] "
            read -r response
            if [[ "$response" =~ ^[Yy] ]]; then
                install_ollama || {
                    log_error "Failed to install Ollama"
                    return 1
                }
            else
                log_info "Installing without Ollama CLI (limited functionality)"
            fi
        fi
    fi
    
    # Install the model
    install_model "$model_spec"
}

# Remove model command
model_remove_command() {
    local model_spec="$1"
    
    if [[ -z "$model_spec" ]]; then
        log_error "Model name required"
        echo "Usage: leonardo model remove <model>"
        return 1
    fi
    
    # Confirm removal
    echo -n "Are you sure you want to remove model '$model_spec'? [y/N] "
    read -r response
    
    if [[ "$response" =~ ^[Yy] ]]; then
        remove_model "$model_spec"
    else
        log_info "Model removal cancelled"
    fi
}

# Run model command
model_run_command() {
    local model_spec="$1"
    shift
    
    if [[ -z "$model_spec" ]]; then
        log_error "Model name required"
        echo "Usage: leonardo model run <model>"
        return 1
    fi
    
    run_model "$model_spec" "$@"
}

# Update model registry
model_update_command() {
    update_model_registry
}

# Model menu for interactive mode
model_management_menu() {
    while true; do
        local options=(
            "List Available Models"
            "List Installed Models"
            "Install Model"
            "Remove Model"
            "Model Information"
            "Run Model"
            "Update Registry"
            "Back to Main Menu"
        )
        
        local selection=$(show_menu "Model Management" "${options[@]}")
        
        case "$selection" in
            "List Available Models")
                clear
                list_available_models
                echo
                read -p "Press Enter to continue..."
                ;;
            "List Installed Models")
                clear
                list_installed_models
                echo
                read -p "Press Enter to continue..."
                ;;
            "Install Model")
                clear
                list_available_models
                echo
                read -p "Enter model to install (e.g., llama2, mistral:7b): " model_spec
                if [[ -n "$model_spec" ]]; then
                    model_install_command "$model_spec"
                fi
                echo
                read -p "Press Enter to continue..."
                ;;
            "Remove Model")
                clear
                list_installed_models
                echo
                read -p "Enter model to remove: " model_spec
                if [[ -n "$model_spec" ]]; then
                    model_remove_command "$model_spec"
                fi
                echo
                read -p "Press Enter to continue..."
                ;;
            "Model Information")
                clear
                list_available_models
                echo
                read -p "Enter model name: " model_spec
                if [[ -n "$model_spec" ]]; then
                    model_info_command "$model_spec"
                fi
                echo
                read -p "Press Enter to continue..."
                ;;
            "Run Model")
                clear
                list_installed_models
                echo
                read -p "Enter model to run: " model_spec
                if [[ -n "$model_spec" ]]; then
                    model_run_command "$model_spec"
                fi
                ;;
            "Update Registry")
                clear
                model_update_command
                echo
                read -p "Press Enter to continue..."
                ;;
            "Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Export functions
export -f parse_model_command
export -f model_list_command
export -f model_info_command
export -f model_install_command
export -f model_remove_command
export -f model_run_command
export -f model_update_command
export -f model_management_menu

# Model CLI router
handle_model_command() {
    local command="${1:-help}"
    shift
    
    # Parse new-style commands
    parse_model_command "$command" "$@"
}

# Export CLI functions
export -f handle_model_command
