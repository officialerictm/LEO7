#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Model Selector
# ==============================================================================
# Description: Interactive model selection and configuration interface
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, menu.sh, progress.sh, registry.sh, manager.sh
# ==============================================================================

# Model selector state
LEONARDO_SELECTED_MODEL=""
LEONARDO_MODEL_PREFERENCES=()

# Interactive model selector
interactive_model_selector() {
    local use_case="${1:-general}"
    
    clear
    show_banner
    
    echo "${COLOR_CYAN}Model Selection Assistant${COLOR_RESET}"
    echo "${COLOR_DIM}Let's find the perfect AI model for your needs${COLOR_RESET}"
    echo ""
    
    # Step 1: Use case selection
    local use_cases=(
        "General Chat:general"
        "Code Generation:code"
        "Creative Writing:creative"
        "Analysis & Research:analysis"
        "Lightweight/Fast:small"
        "Advanced/Large:large"
        "Custom Selection:custom"
    )
    
    local selected_use_case=$(show_radio_menu "What will you primarily use the model for?" "${use_cases[@]}")
    
    if [[ -z "$selected_use_case" ]]; then
        return 1
    fi
    
    use_case="${use_cases[$selected_use_case]##*:}"
    
    if [[ "$use_case" == "custom" ]]; then
        # Custom selection - show all models
        custom_model_selection
        return $?
    fi
    
    # Step 2: Get recommended models
    local recommended=($(get_recommended_models "$use_case"))
    
    echo ""
    echo "${COLOR_CYAN}Recommended models for $use_case:${COLOR_RESET}"
    echo ""
    
    # Show recommended models with details
    local options=()
    local model_details=()
    
    for model_id in "${recommended[@]}"; do
        local name=$(get_model_metadata "$model_id" "name")
        local size=$(get_model_metadata "$model_id" "size")
        local status=$(get_model_status "$model_id")
        
        # Status indicator
        local status_text=""
        case "$status" in
            "installed")
                status_text="${COLOR_GREEN}[Installed]${COLOR_RESET}"
                ;;
            "downloading")
                status_text="${COLOR_YELLOW}[Downloading]${COLOR_RESET}"
                ;;
            "not_installed")
                status_text="${COLOR_DIM}[Not Installed]${COLOR_RESET}"
                ;;
        esac
        
        options+=("$model_id:$name ($size) $status_text")
        model_details+=("$model_id")
    done
    
    # Add option to see all models
    options+=("all:Browse All Models")
    
    # Show selection menu
    local selected=$(show_radio_menu "Select a model:" "${options[@]}")
    
    if [[ -z "$selected" ]]; then
        return 1
    fi
    
    local choice="${options[$selected]%%:*}"
    
    if [[ "$choice" == "all" ]]; then
        custom_model_selection
        return $?
    fi
    
    # Selected a specific model
    LEONARDO_SELECTED_MODEL="$choice"
    
    # Show model details and actions
    show_model_details_and_actions "$LEONARDO_SELECTED_MODEL"
}

# Custom model selection
custom_model_selection() {
    clear
    echo "${COLOR_CYAN}All Available Models${COLOR_RESET}"
    echo ""
    
    # Build filtered list interface
    local models=()
    local display_names=()
    
    for model_id in $(list_models "" "simple" | sort); do
        models+=("$model_id")
        local name=$(get_model_metadata "$model_id" "name")
        local size=$(get_model_metadata "$model_id" "size")
        local family=$(get_model_metadata "$model_id" "family")
        display_names+=("$name - $size [$family]")
    done
    
    # Show filtered list
    local selected=$(show_filtered_list "Search and select a model:" "${display_names[@]}")
    
    if [[ -n "$selected" ]]; then
        LEONARDO_SELECTED_MODEL="${models[$selected]}"
        show_model_details_and_actions "$LEONARDO_SELECTED_MODEL"
        return 0
    else
        return 1
    fi
}

# Show model details and actions
show_model_details_and_actions() {
    local model_id="$1"
    
    clear
    echo "${COLOR_CYAN}Model Selected${COLOR_RESET}"
    echo ""
    
    # Show model info
    get_model_info "$model_id"
    echo ""
    
    # Check status
    local status=$(get_model_status "$model_id")
    
    # Show appropriate actions
    local actions=()
    
    case "$status" in
        "installed")
            echo "${COLOR_GREEN}✓ This model is installed and ready to use${COLOR_RESET}"
            actions=(
                "load:Load Model"
                "export:Export Model"
                "delete:Delete Model"
                "back:Select Different Model"
            )
            ;;
        "downloading")
            echo "${COLOR_YELLOW}⟳ This model is currently downloading...${COLOR_RESET}"
            actions=(
                "status:Check Download Status"
                "back:Select Different Model"
            )
            ;;
        "not_installed")
            echo "${COLOR_DIM}○ This model is not installed${COLOR_RESET}"
            actions=(
                "download:Download Model"
                "info:View More Info"
                "back:Select Different Model"
            )
            ;;
    esac
    
    echo ""
    local action=$(show_menu "What would you like to do?" "${actions[@]##*:}")
    
    if [[ -n "$action" ]]; then
        local action_key="${actions[$action]%%:*}"
        
        case "$action_key" in
            "load")
                load_model "$model_id"
                ;;
            "download")
                if download_model "$model_id"; then
                    echo ""
                    echo "${COLOR_GREEN}Model ready to use!${COLOR_RESET}"
                    read -p "Press Enter to continue..."
                    show_model_details_and_actions "$model_id"
                fi
                ;;
            "export")
                echo ""
                local export_path=$(show_input_dialog "Export path:" "$PWD")
                if [[ -n "$export_path" ]]; then
                    export_model "$model_id" "$export_path"
                    read -p "Press Enter to continue..."
                fi
                ;;
            "delete")
                if delete_model "$model_id"; then
                    echo ""
                    read -p "Press Enter to continue..."
                    interactive_model_selector
                else
                    show_model_details_and_actions "$model_id"
                fi
                ;;
            "info")
                clear
                get_model_info "$model_id"
                echo ""
                echo "${COLOR_DIM}Download URL:${COLOR_RESET}"
                echo "$(get_model_metadata "$model_id" "url")"
                echo ""
                read -p "Press Enter to continue..."
                show_model_details_and_actions "$model_id"
                ;;
            "status")
                # TODO: Show download progress
                echo "Download status check not yet implemented"
                read -p "Press Enter to continue..."
                show_model_details_and_actions "$model_id"
                ;;
            "back")
                interactive_model_selector
                ;;
        esac
    fi
}

# Model comparison tool
compare_models() {
    local model1="$1"
    local model2="$2"
    
    if [[ -z "$model1" ]] || [[ -z "$model2" ]]; then
        # Interactive selection
        echo "${COLOR_CYAN}Model Comparison Tool${COLOR_RESET}"
        echo ""
        
        echo "Select first model:"
        model1=$(model_selection_menu)
        [[ -z "$model1" ]] && return 1
        
        echo "Select second model:"
        model2=$(model_selection_menu)
        [[ -z "$model2" ]] && return 1
    fi
    
    # Validate models exist
    if [[ -z "${LEONARDO_MODEL_REGISTRY[$model1]:-}" ]] || [[ -z "${LEONARDO_MODEL_REGISTRY[$model2]:-}" ]]; then
        log_message "ERROR" "Invalid model IDs"
        return 1
    fi
    
    clear
    echo "${COLOR_CYAN}Model Comparison${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%80s' | tr ' ' '=')${COLOR_RESET}"
    
    # Header
    printf "${COLOR_GREEN}%-25s${COLOR_RESET} | ${COLOR_YELLOW}%-25s${COLOR_RESET} | ${COLOR_CYAN}%-25s${COLOR_RESET}\n" \
        "Attribute" "$(get_model_metadata "$model1" "name")" "$(get_model_metadata "$model2" "name")"
    echo "${COLOR_DIM}$(printf '%80s' | tr ' ' '-')${COLOR_RESET}"
    
    # Compare attributes
    local attributes=("size" "format" "quantization" "family" "license")
    
    for attr in "${attributes[@]}"; do
        local val1=$(get_model_metadata "$model1" "$attr")
        local val2=$(get_model_metadata "$model2" "$attr")
        
        printf "%-25s | %-25s | %-25s\n" "$attr" "$val1" "$val2"
    done
    
    # Status
    echo "${COLOR_DIM}$(printf '%80s' | tr ' ' '-')${COLOR_RESET}"
    local status1=$(get_model_status "$model1")
    local status2=$(get_model_status "$model2")
    printf "%-25s | ${COLOR_GREEN}%-25s${COLOR_RESET} | ${COLOR_GREEN}%-25s${COLOR_RESET}\n" \
        "Status" "$status1" "$status2"
    
    echo ""
}

# Model preference configuration
configure_model_preferences() {
    clear
    echo "${COLOR_CYAN}Model Preferences${COLOR_RESET}"
    echo "${COLOR_DIM}Configure your model selection preferences${COLOR_RESET}"
    echo ""
    
    # Preference options
    local preferences=(
        "max_size:Maximum model size"
        "quantization:Preferred quantization"
        "auto_download:Auto-download models"
        "verify_checksums:Verify checksums"
        "default_model:Default model"
    )
    
    local selected=$(show_checklist "Select preferences to configure:" "${preferences[@]##*:}")
    
    if [[ -n "$selected" ]]; then
        for idx in $selected; do
            local pref="${preferences[$idx]%%:*}"
            
            case "$pref" in
                "max_size")
                    local size=$(show_menu "Maximum model size:" "2GB" "5GB" "10GB" "20GB" "50GB" "No Limit")
                    [[ -n "$size" ]] && LEONARDO_MODEL_PREFERENCES["max_size"]="${size}"
                    ;;
                "quantization")
                    local quant=$(show_menu "Preferred quantization:" "Q4_K_M" "Q5_K_M" "Q8_0" "f16")
                    [[ -n "$quant" ]] && LEONARDO_MODEL_PREFERENCES["quantization"]="${quant}"
                    ;;
                "auto_download")
                    local auto=$(show_menu "Auto-download models:" "Yes" "No")
                    [[ -n "$auto" ]] && LEONARDO_MODEL_PREFERENCES["auto_download"]="${auto}"
                    ;;
                "verify_checksums")
                    local verify=$(show_menu "Verify checksums:" "Always" "Never" "Ask")
                    [[ -n "$verify" ]] && LEONARDO_MODEL_PREFERENCES["verify_checksums"]="${verify}"
                    ;;
                "default_model")
                    local model=$(model_selection_menu)
                    [[ -n "$model" ]] && LEONARDO_MODEL_PREFERENCES["default_model"]="${model}"
                    ;;
            esac
        done
        
        echo ""
        show_status "success" "Preferences updated"
        
        # Save preferences
        save_model_preferences
    fi
}

# Save model preferences
save_model_preferences() {
    local pref_file="$LEONARDO_CONFIG_DIR/model_preferences.conf"
    
    mkdir -p "$(dirname "$pref_file")"
    
    {
        echo "# Leonardo Model Preferences"
        echo "# Generated: $(date)"
        echo ""
        
        for key in "${!LEONARDO_MODEL_PREFERENCES[@]}"; do
            echo "${key}=${LEONARDO_MODEL_PREFERENCES[$key]}"
        done
    } > "$pref_file"
}

# Load model preferences
load_model_preferences() {
    local pref_file="$LEONARDO_CONFIG_DIR/model_preferences.conf"
    
    if [[ -f "$pref_file" ]]; then
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^#.*$ ]] && continue
            [[ -z "$key" ]] && continue
            LEONARDO_MODEL_PREFERENCES["$key"]="$value"
        done < "$pref_file"
    fi
}

# Quick model installer
quick_install_model() {
    local use_case="${1:-general}"
    
    echo "${COLOR_CYAN}Quick Model Installation${COLOR_RESET}"
    echo ""
    
    # Get recommended model for use case
    local recommended=($(get_recommended_models "$use_case"))
    
    if [[ ${#recommended[@]} -eq 0 ]]; then
        log_message "ERROR" "No recommendations for use case: $use_case"
        return 1
    fi
    
    # Find first non-installed model
    local model_to_install=""
    for model_id in "${recommended[@]}"; do
        if [[ "$(get_model_status "$model_id")" == "not_installed" ]]; then
            model_to_install="$model_id"
            break
        fi
    done
    
    if [[ -z "$model_to_install" ]]; then
        echo "${COLOR_GREEN}All recommended models are already installed!${COLOR_RESET}"
        return 0
    fi
    
    # Download the model
    download_model "$model_to_install"
}

# Export model selector functions
export -f interactive_model_selector custom_model_selection compare_models
export -f configure_model_preferences quick_install_model
