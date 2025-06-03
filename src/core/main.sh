#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Main Application Entry Point
# ==============================================================================
# Description: Main application logic and orchestration
# Version: 7.0.0
# Dependencies: all components
# ==============================================================================

# Show application banner
show_banner() {
    echo "${COLOR_CYAN}╭─────────────────────────────────────╮${COLOR_RESET}"
    echo "${COLOR_CYAN}│    Leonardo AI Universal v$LEONARDO_VERSION    │${COLOR_RESET}"
    echo "${COLOR_CYAN}│       Deploy AI Anywhere™           │${COLOR_RESET}"
    echo "${COLOR_CYAN}╰─────────────────────────────────────╯${COLOR_RESET}"
    echo ""
}

# Show help information
show_help() {
    cat << EOF
${COLOR_CYAN}$LEONARDO_NAME v$LEONARDO_VERSION${COLOR_RESET}
${COLOR_DIM}$LEONARDO_DESCRIPTION${COLOR_RESET}

${COLOR_GREEN}Usage:${COLOR_RESET}
  leonardo [options] [command] [args]

${COLOR_GREEN}Options:${COLOR_RESET}
  -h, --help        Show this help message
  -v, --verbose     Enable verbose output
  -q, --quiet       Suppress non-essential output
  --version         Show version information
  --no-color        Disable colored output

${COLOR_GREEN}Commands:${COLOR_RESET}
  model <cmd>       Model management (list, download, delete, etc.)
  usb <cmd>         USB drive management
  dashboard         Show system dashboard
  web [port]        Start web UI
  test              Run system tests

${COLOR_GREEN}Interactive Mode:${COLOR_RESET}
  Run without commands to enter interactive mode

${COLOR_GREEN}Examples:${COLOR_RESET}
  leonardo                      # Interactive mode
  leonardo model list           # List available models
  leonardo model download llama3-8b
  leonardo dashboard            # Show system status
  leonardo web                  # Start web interface

For more help on specific commands:
  leonardo model help
  leonardo usb help

EOF
}

# Main function - entry point for Leonardo
main() {
    # Mark that main has been called
    LEONARDO_MAIN_CALLED=true
    
    # Initialize components (colors are already initialized by sourcing colors.sh)
    init_logging
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Handle direct commands
    if [[ -n "$LEONARDO_COMMAND" ]]; then
        handle_direct_command
        return $?
    fi
    
    # Show banner unless quiet mode
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        clear
        show_banner
        echo
    fi
    
    # Initialize model manager
    init_model_manager
    
    # Check system requirements
    if ! check_system_requirements; then
        log_message "ERROR" "System requirements not met"
        exit 1
    fi
    
    # Main interactive menu
    interactive_main_menu
}

# Parse command line arguments
parse_arguments() {
    LEONARDO_COMMAND=""
    LEONARDO_SUBCOMMAND=""
    LEONARDO_ARGS=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                export LEONARDO_VERBOSE=true
                shift
                ;;
            -q|--quiet)
                export LEONARDO_QUIET=true
                shift
                ;;
            --version)
                echo "$LEONARDO_NAME v$LEONARDO_VERSION"
                exit 0
                ;;
            --no-color)
                export LEONARDO_NO_COLOR=true
                shift
                ;;
            model|models)
                LEONARDO_COMMAND="model"
                shift
                LEONARDO_SUBCOMMAND="$1"
                shift
                LEONARDO_ARGS=("$@")
                break
                ;;
            usb|drive)
                LEONARDO_COMMAND="usb"
                shift
                LEONARDO_SUBCOMMAND="$1"
                shift
                LEONARDO_ARGS=("$@")
                break
                ;;
            deploy|deployment)
                LEONARDO_COMMAND="deploy"
                shift
                LEONARDO_SUBCOMMAND="$1"
                shift
                LEONARDO_ARGS=("$@")
                break
                ;;
            dashboard|status)
                LEONARDO_COMMAND="dashboard"
                shift
                break
                ;;
            web|webui)
                LEONARDO_COMMAND="web"
                shift
                LEONARDO_ARGS=("$@")
                break
                ;;
            test|check)
                LEONARDO_COMMAND="test"
                shift
                break
                ;;
            *)
                LEONARDO_ARGS+=("$1")
                shift
                ;;
        esac
    done
}

# Handle direct commands
handle_direct_command() {
    case "$LEONARDO_COMMAND" in
        "model")
            handle_model_command "$LEONARDO_SUBCOMMAND" "${LEONARDO_ARGS[@]}"
            ;;
        "usb")
            handle_usb_command "$LEONARDO_SUBCOMMAND" "${LEONARDO_ARGS[@]}"
            ;;
        "deploy"|"deployment")
            deployment_cli "$LEONARDO_SUBCOMMAND" "${LEONARDO_ARGS[@]}"
            ;;
        "dashboard")
            show_system_dashboard
            ;;
        "web")
            start_web_ui "${LEONARDO_ARGS[@]}"
            ;;
        "test")
            run_system_tests
            ;;
        *)
            echo "${COLOR_RED}Unknown command: $LEONARDO_COMMAND${COLOR_RESET}"
            show_help
            return 1
            ;;
    esac
}

# Interactive main menu
interactive_main_menu() {
    while true; do
        clear
        show_banner
        echo ""
        
        local options=(
            "models:AI Model Management"
            "usb:Create/Manage USB Drive"
            "dashboard:System Dashboard"
            "web:Launch Web Interface"
            "settings:Settings & Preferences"
            "test:Run System Tests"
            "about:About Leonardo"
            "exit:Exit"
        )
        
        local selected=$(show_menu "Main Menu" "${options[@]##*:}")
        
        if [[ -z "$selected" ]]; then
            continue
        fi
        
        local choice="${options[$selected]%%:*}"
        
        case "$choice" in
            "models")
                model_management_menu
                ;;
            "usb")
                usb_management_menu
                ;;
            "dashboard")
                show_system_dashboard
                read -p "Press Enter to continue..."
                ;;
            "web")
                echo ""
                echo "${COLOR_CYAN}Starting web interface...${COLOR_RESET}"
                start_web_ui
                ;;
            "settings")
                settings_menu
                ;;
            "test")
                run_system_tests
                read -p "Press Enter to continue..."
                ;;
            "about")
                show_about
                read -p "Press Enter to continue..."
                ;;
            "exit")
                handle_exit
                break
                ;;
        esac
    done
}

# Model management menu
model_management_menu() {
    while true; do
        clear
        echo "${COLOR_CYAN}Model Management${COLOR_RESET}"
        echo "${COLOR_DIM}Manage AI models for Leonardo${COLOR_RESET}"
        echo ""
        
        # Show model stats
        local installed_count=${#LEONARDO_INSTALLED_MODELS[@]}
        local total_count=${#LEONARDO_MODEL_REGISTRY[@]}
        echo "Models installed: ${COLOR_GREEN}$installed_count${COLOR_RESET} / $total_count"
        echo ""
        
        local options=(
            "browse:Browse Available Models"
            "installed:View Installed Models"
            "download:Download New Model"
            "select:Interactive Model Selector"
            "import:Import Model from File"
            "export:Export Model to File"
            "delete:Delete Installed Model"
            "update:Update Model Registry"
            "back:Back to Main Menu"
        )
        
        local selected=$(show_menu "Model Options" "${options[@]##*:}")
        
        [[ -z "$selected" ]] && continue
        
        local choice="${options[$selected]%%:*}"
        
        case "$choice" in
            "browse")
                clear
                list_models
                read -p "Press Enter to continue..."
                ;;
            "installed")
                clear
                list_installed_models
                read -p "Press Enter to continue..."
                ;;
            "download")
                clear
                handle_model_download
                read -p "Press Enter to continue..."
                ;;
            "select")
                interactive_model_selector
                ;;
            "import")
                clear
                local file=$(show_input_dialog "Model file path:")
                [[ -n "$file" ]] && import_model "$file"
                read -p "Press Enter to continue..."
                ;;
            "export")
                clear
                list_installed_models
                echo ""
                local model=$(show_input_dialog "Model ID to export:")
                [[ -n "$model" ]] && export_model "$model"
                read -p "Press Enter to continue..."
                ;;
            "delete")
                clear
                handle_model_delete
                read -p "Press Enter to continue..."
                ;;
            "update")
                clear
                update_model_registry
                read -p "Press Enter to continue..."
                ;;
            "back")
                break
                ;;
        esac
    done
}

# USB management menu (placeholder)
usb_management_menu() {
    clear
    echo "${COLOR_CYAN}USB Drive Management${COLOR_RESET}"
    echo "${COLOR_DIM}This feature is coming soon...${COLOR_RESET}"
    echo ""
    echo "USB drive creation and management functionality will include:"
    echo "  • Create bootable Leonardo USB drives"
    echo "  • Verify USB integrity"
    echo "  • Repair corrupted USBs"
    echo "  • Track USB health and write cycles"
    echo ""
    read -p "Press Enter to return..."
}

# Settings menu
settings_menu() {
    while true; do
        clear
        echo "${COLOR_CYAN}Settings & Preferences${COLOR_RESET}"
        echo ""
        
        local options=(
            "model_prefs:Model Preferences"
            "security:Security Settings"
            "network:Network Settings"
            "ui:UI Preferences"
            "back:Back to Main Menu"
        )
        
        local selected=$(show_menu "Settings" "${options[@]##*:}")
        
        [[ -z "$selected" ]] && break
        
        local choice="${options[$selected]%%:*}"
        
        case "$choice" in
            "model_prefs")
                configure_model_preferences
                ;;
            "security")
                security_settings_menu
                ;;
            "network")
                network_settings_menu
                ;;
            "ui")
                ui_preferences_menu
                ;;
            "back")
                break
                ;;
        esac
    done
}

# Security settings menu
security_settings_menu() {
    clear
    echo "${COLOR_CYAN}Security Settings${COLOR_RESET}"
    echo ""
    echo "Current settings:"
    echo "  Paranoid Mode: ${LEONARDO_PARANOID_MODE}"
    echo "  Secure Delete: ${LEONARDO_SECURE_DELETE}"
    echo "  Verify Checksums: ${LEONARDO_VERIFY_CHECKSUMS}"
    echo ""
    # TODO: Implement security settings configuration
    read -p "Press Enter to continue..."
}

# Network settings menu
network_settings_menu() {
    clear
    echo "${COLOR_CYAN}Network Settings${COLOR_RESET}"
    echo ""
    echo "Current settings:"
    echo "  Download Retries: ${LEONARDO_DOWNLOAD_RETRIES}"
    echo "  Connection Timeout: ${LEONARDO_TIMEOUT}s"
    echo ""
    # TODO: Implement network settings configuration
    read -p "Press Enter to continue..."
}

# UI preferences menu
ui_preferences_menu() {
    clear
    echo "${COLOR_CYAN}UI Preferences${COLOR_RESET}"
    echo ""
    echo "Current settings:"
    echo "  Color Output: ${LEONARDO_NO_COLOR:-enabled}"
    echo "  Verbose Mode: ${LEONARDO_VERBOSE}"
    echo ""
    # TODO: Implement UI preferences configuration
    read -p "Press Enter to continue..."
}

# System tests
run_system_tests() {
    clear
    echo "${COLOR_CYAN}Running System Tests${COLOR_RESET}"
    echo ""
    
    # Component tests
    local tests=(
        "Environment:check_environment"
        "File System:test_filesystem"
        "Network:test_network_connectivity"
        "Model Registry:test_model_registry"
        "UI Components:test_ui_components"
    )
    
    for test in "${tests[@]}"; do
        local name="${test%%:*}"
        local func="${test##*:}"
        
        echo -n "Testing $name... "
        if $func 2>/dev/null; then
            echo "${COLOR_GREEN}✓ PASS${COLOR_RESET}"
        else
            echo "${COLOR_RED}✗ FAIL${COLOR_RESET}"
        fi
    done
    
    echo ""
}

# Test functions
check_environment() {
    [[ -n "$LEONARDO_VERSION" ]] && [[ -n "$LEONARDO_BASE_DIR" ]]
}

test_filesystem() {
    local test_file="$LEONARDO_TEMP_DIR/.test_$$"
    echo "test" > "$test_file" && rm -f "$test_file"
}

test_network_connectivity() {
    check_connectivity >/dev/null 2>&1
}

test_model_registry() {
    [[ ${#LEONARDO_MODEL_REGISTRY[@]} -gt 0 ]]
}

test_ui_components() {
    type show_menu >/dev/null 2>&1 && type show_progress_bar >/dev/null 2>&1
}

# About screen
show_about() {
    clear
    show_banner
    echo ""
    echo "${COLOR_CYAN}About Leonardo AI Universal${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%60s' | tr ' ' '-')${COLOR_RESET}"
    echo ""
    echo "Version: ${COLOR_GREEN}$LEONARDO_VERSION${COLOR_RESET} ($LEONARDO_CODENAME)"
    echo "Build Date: $LEONARDO_BUILD_DATE"
    echo ""
    echo "Leonardo AI Universal is a cross-platform solution for deploying"
    echo "AI models on USB drives. It enables you to carry powerful language"
    echo "models anywhere and run them on any compatible computer without"
    echo "installation or leaving traces."
    echo ""
    echo "${COLOR_GREEN}Key Features:${COLOR_RESET}"
    echo "  • Portable AI models on USB drives"
    echo "  • Support for multiple LLM families"
    echo "  • Cross-platform compatibility"
    echo "  • Zero installation required"
    echo "  • Privacy-focused design"
    echo ""
    echo "${COLOR_GREEN}Authors:${COLOR_RESET} $LEONARDO_AUTHORS"
    echo "${COLOR_GREEN}License:${COLOR_RESET} $LEONARDO_LICENSE"
    echo "${COLOR_GREEN}Repository:${COLOR_RESET} $LEONARDO_REPOSITORY"
    echo ""
}

# Exit handler
handle_exit() {
    echo ""
    echo "${COLOR_CYAN}Thank you for using Leonardo AI Universal!${COLOR_RESET}"
    echo "${COLOR_DIM}Stay curious, stay creative.${COLOR_RESET}"
    echo ""
    
    # Cleanup
    cleanup_temp_files 2>/dev/null || true
    
    # Save session state if needed
    # TODO: Implement session persistence
    
    exit 0
}

# Handle model commands
handle_model_command() {
    model_cli "$@"
}

# Handle USB commands
handle_usb_command() {
    usb_cli "$@"
}

# Run system tests
run_system_tests() {
    clear
    echo "${COLOR_CYAN}Running System Tests${COLOR_RESET}"
    echo ""
    
    # Component tests
    local tests=(
        "Environment:check_environment"
        "File System:test_filesystem"
        "Network:test_network_connectivity"
        "Model Registry:test_model_registry"
        "UI Components:test_ui_components"
    )
    
    for test in "${tests[@]}"; do
        local name="${test%%:*}"
        local func="${test##*:}"
        
        echo -n "Testing $name... "
        if $func 2>/dev/null; then
            echo "${COLOR_GREEN}✓ PASS${COLOR_RESET}"
        else
            echo "${COLOR_RED}✗ FAIL${COLOR_RESET}"
        fi
    done
    
    echo ""
}

# Test functions
check_environment() {
    [[ -n "$LEONARDO_VERSION" ]] && [[ -n "$LEONARDO_BASE_DIR" ]]
}

test_filesystem() {
    local test_file="$LEONARDO_TEMP_DIR/.test_$$"
    echo "test" > "$test_file" && rm -f "$test_file"
}

test_network_connectivity() {
    check_connectivity >/dev/null 2>&1
}

test_model_registry() {
    [[ ${#LEONARDO_MODEL_REGISTRY[@]} -gt 0 ]]
}

test_ui_components() {
    type show_menu >/dev/null 2>&1 && type show_progress_bar >/dev/null 2>&1
}
