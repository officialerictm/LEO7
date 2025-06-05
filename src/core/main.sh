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
    echo -e "${COLOR_CYAN}╭─────────────────────────────────────╮${COLOR_RESET}"
    echo -e "${COLOR_CYAN}│    Leonardo AI Universal v$LEONARDO_VERSION    │${COLOR_RESET}"
    echo -e "${COLOR_CYAN}│       Deploy AI Anywhere™           │${COLOR_RESET}"
    echo -e "${COLOR_CYAN}╰─────────────────────────────────────╯${COLOR_RESET}"
    echo ""
}

# Show banner
show_banner() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${CYAN}║${COLOR_RESET}            ${BOLD}Leonardo AI Universal v$LEONARDO_VERSION${COLOR_RESET}              ${CYAN}║${COLOR_RESET}"
    echo -e "${CYAN}║${COLOR_RESET}              ${DIM}Portable AI Assistant${COLOR_RESET}                         ${CYAN}║${COLOR_RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
}

# Settings menu
settings_menu() {
    while true; do
        local selection
        selection=$(show_menu "Settings & Preferences" \
            "Default Model Path" \
            "Color Theme" \
            "Auto-Update" \
            "Network Proxy" \
            "Back to Main Menu") || break
        
        case "$selection" in
            "Default Model Path")
                echo -e "${YELLOW}Current model path:${COLOR_RESET} $LEONARDO_MODEL_DIR"
                pause
                ;;
            "Color Theme")
                echo -e "${YELLOW}Color theme settings coming soon!${COLOR_RESET}"
                pause
                ;;
            "Auto-Update")
                echo -e "${YELLOW}Auto-update settings coming soon!${COLOR_RESET}"
                pause
                ;;
            "Network Proxy")
                echo -e "${YELLOW}Proxy settings coming soon!${COLOR_RESET}"
                pause
                ;;
            "Back to Main Menu"|"")
                break
                ;;
        esac
    done
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
  chat              Chat with a model

${COLOR_GREEN}Interactive Mode:${COLOR_RESET}
  Run without commands to enter interactive mode

${COLOR_GREEN}Examples:${COLOR_RESET}
  leonardo                      # Interactive mode
  leonardo model list           # List available models
  leonardo model download llama3-8b
  leonardo dashboard            # Show system status
  leonardo web                  # Start web interface
  leonardo chat                 # Chat with a model

For more help on specific commands:
  leonardo model help
  leonardo usb help

EOF
}

# Error handler
handle_error() {
    local exit_code="$1"
    local line_no="$2"
    log_message "ERROR" "Command failed with exit code $exit_code at line $line_no"
}

# Main function - entry point for Leonardo
main() {
    # Set up error handling
    set -euo pipefail
    trap 'handle_error $? $LINENO' ERR
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Handle help/version first
    if [[ "$LEONARDO_HELP" == "true" ]]; then
        show_help
        exit 0
    fi
    
    if [[ "$LEONARDO_VERSION_ONLY" == "true" ]]; then
        echo "Leonardo AI Universal v$LEONARDO_VERSION ($LEONARDO_BUILD)"
        exit 0
    fi
    
    # Handle commands if provided
    if [[ -n "$LEONARDO_COMMAND" ]]; then
        handle_command
        exit $?
    fi
    
    # Show banner unless quiet mode
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        clear
        show_banner
        echo
    fi
    
    # Initialize model system
    if ! init_model_system; then
        log_message "ERROR" "Failed to initialize model system"
        exit 1
    fi
    
    # Check system requirements
    if ! check_system_requirements; then
        log_message "ERROR" "System requirements not met"
        exit 1
    fi
    
    # Main interactive menu
    local keep_running=true
    while [[ "$keep_running" == "true" ]]; do
        clear
        show_banner
        
        # Build menu options dynamically
        local menu_options=()
        
        # Always show deployment option first for MVP
        menu_options+=("🚀 Deploy to USB")
        
        # Show chat option if models are installed
        if check_installed_models; then
            menu_options+=("💬 Chat with AI")
        fi
        
        # System management options
        menu_options+=("📦 Model Manager")
        menu_options+=("🔧 System Utilities")
        menu_options+=("📊 System Dashboard")
        menu_options+=("⚙️  Settings")
        menu_options+=("📖 Help")
        menu_options+=("🚪 Exit")
        
        local selection
        selection=$(show_menu "Leonardo AI Universal - Main Menu" "${menu_options[@]}")
        local menu_exit_code=$?
        
        # Debug: Show menu exit code and selection
        echo -e "${YELLOW}DEBUG: Menu exit code: $menu_exit_code${COLOR_RESET}" >&2
        echo -e "${YELLOW}DEBUG: Raw selection: '$selection'${COLOR_RESET}" >&2
        sleep 2
        
        # If show_menu returned error (user pressed q), exit
        if [[ $menu_exit_code -ne 0 ]]; then
            keep_running=false
            continue
        fi
        
        # Debug: Show what was selected
        if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
            echo "DEBUG: Selected: '$selection'" >&2
            sleep 1
        fi
        
        # Extra debug: Show hex dump of selection to see any hidden characters
        echo -e "${YELLOW}DEBUG: Hex dump of selection:${COLOR_RESET}" >&2
        echo -n "$selection" | od -An -tx1 >&2
        echo -e "${YELLOW}DEBUG: Length: ${#selection}${COLOR_RESET}" >&2
        
        # Test exact match
        if [[ "$selection" == "🚀 Deploy to USB" ]]; then
            echo -e "${GREEN}DEBUG: Exact match found!${COLOR_RESET}" >&2
        else
            echo -e "${RED}DEBUG: No exact match${COLOR_RESET}" >&2
        fi
        sleep 2
        
        case "$selection" in
            "🚀 Deploy to USB")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling deploy_to_usb" >&2
                fi
                deploy_to_usb
                # Don't exit on failure, just return to menu
                ;;
            "💬 Chat with AI")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling handle_chat_command" >&2
                fi
                handle_chat_command
                ;;
            "📦 Model Manager")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling handle_model_command menu" >&2
                fi
                handle_model_command "menu"
                ;;
            "🔧 System Utilities")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling system_utilities_menu" >&2
                fi
                system_utilities_menu
                ;;
            "📊 System Dashboard")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling show_dashboard" >&2
                fi
                show_dashboard
                pause
                ;;
            "⚙️  Settings")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling settings_menu" >&2
                fi
                settings_menu
                ;;
            "📖 Help")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling show_help" >&2
                fi
                show_help
                pause
                ;;
            "🚪 Exit"|"")
                handle_exit
                keep_running=false
                ;;
            *)
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Unknown selection: '$selection'" >&2
                fi
                ;;
        esac
    done
}

# Parse command line arguments
parse_arguments() {
    # Initialize command line variables
    LEONARDO_COMMAND=""
    LEONARDO_SUBCOMMAND=""
    LEONARDO_ARGS=()
    LEONARDO_HELP=false
    LEONARDO_VERSION_ONLY=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                LEONARDO_HELP=true
                shift
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
                LEONARDO_VERSION_ONLY=true
                shift
                ;;
            --no-color)
                export LEONARDO_NO_COLOR=true
                shift
                ;;
            model|models)
                LEONARDO_COMMAND="model"
                shift
                LEONARDO_SUBCOMMAND="${1:-}"
                shift || true
                LEONARDO_ARGS=("$@")
                break
                ;;
            usb|drive)
                LEONARDO_COMMAND="usb"
                shift
                LEONARDO_SUBCOMMAND="${1:-}"
                shift || true
                LEONARDO_ARGS=("$@")
                break
                ;;
            deploy|deployment)
                LEONARDO_COMMAND="deploy"
                shift
                LEONARDO_SUBCOMMAND="${1:-}"
                shift || true
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
            chat)
                LEONARDO_COMMAND="chat"
                shift
                LEONARDO_SUBCOMMAND="${1:-}"
                if [[ "$LEONARDO_SUBCOMMAND" =~ ^(web|api|status|stop|help|--web|--help|-h)$ ]]; then
                    shift || true
                fi
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
handle_command() {
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
            show_dashboard
            ;;
        "web")
            start_web_ui "${LEONARDO_ARGS[@]}"
            ;;
        "test")
            run_system_tests
            ;;
        "chat")
            handle_chat_command "${LEONARDO_SUBCOMMAND}" "${LEONARDO_ARGS[@]}"
            ;;
        *)
            echo "${COLOR_RED}Unknown command: $LEONARDO_COMMAND${COLOR_RESET}"
            show_help
            return 1
            ;;
    esac
}

# Model management menu
model_management_menu() {
    while true; do
        # Clear screen properly
        echo -e "\033[H\033[2J" >/dev/tty
        
        echo -e "${CYAN}Model Management${COLOR_RESET}"
        echo -e "${DIM}Manage AI models for Leonardo${COLOR_RESET}"
        echo ""
        
        # Show model stats
        local installed_count=${#LEONARDO_INSTALLED_MODELS[@]}
        local total_count=${#LEONARDO_MODEL_REGISTRY[@]}
        echo -e "Models installed: ${GREEN}$installed_count${COLOR_RESET} / $total_count"
        echo ""
        
        show_menu "Model Options" \
            "List Available Models" \
            "Download Model" \
            "Search Models" \
            "Model Information" \
            "Import Custom Model" \
            "Remove Model" \
            "Back to Main Menu"
        
        case "$MENU_SELECTION" in
            "List Available Models")
                echo -e "\n${CYAN}Available Models:${COLOR_RESET}\n"
                list_models
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Download Model")
                echo -e "\n${CYAN}Download Model${COLOR_RESET}"
                echo -e "${DIM}Examples: llama3:8b, mistral:7b, codellama:7b${COLOR_RESET}"
                echo -e "${DIM}Type 'llama' to see all Llama models, or 'list' for all models${COLOR_RESET}"
                echo ""
                echo -n "Enter model name or ID: "
                read -r model_id
                
                # If user types 'list', show all models
                if [[ "$model_id" == "list" ]]; then
                    echo ""
                    list_models
                elif [[ -n "$model_id" ]]; then
                    # Check if it's a partial match and show options
                    if ! get_model_by_id "$model_id" >/dev/null 2>&1; then
                        echo ""
                        search_models "$model_id"
                    else
                        download_model "$model_id"
                    fi
                fi
                
                # Single press enter prompt for all cases
                if [[ -n "$model_id" ]]; then
                    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                    read -r
                fi
                ;;
            "Search Models")
                echo -e "\n${CYAN}Search Models${COLOR_RESET}"
                echo -e "${DIM}Search by: name (llama, mistral), use case (code, chat), or size (tiny, small)${COLOR_RESET}"
                echo ""
                echo -n "Enter search query: "
                read -r query
                if [[ -n "$query" ]]; then
                    echo ""
                    search_models "$query"
                fi
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Model Information")
                echo -e "\n${CYAN}Model Information${COLOR_RESET}"
                
                # Check if we have any installed models
                local installed_models=()
                # TODO: Get actual installed models
                
                if [[ ${#installed_models[@]} -eq 0 ]]; then
                    echo -e "${DIM}No models currently installed${COLOR_RESET}"
                    echo -e "${DIM}Examples to try: llama3:8b, mistral:7b, codellama:7b${COLOR_RESET}"
                elif [[ ${#installed_models[@]} -eq 1 ]]; then
                    # Auto-show the single installed model
                    echo -e "${DIM}Showing info for: ${installed_models[0]}${COLOR_RESET}"
                    echo ""
                    show_model_info "${installed_models[0]}"
                else
                    # Show menu of installed models
                    echo -e "${DIM}Select an installed model:${COLOR_RESET}"
                    for i in "${!installed_models[@]}"; do
                        echo "$((i+1)). ${installed_models[$i]}"
                    done
                fi
                
                echo ""
                echo -n "Enter model name or ID: "
                read -r model_id
                show_model_info "$model_id"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Import Custom Model")
                echo -e "\n${YELLOW}Custom model import coming soon!${COLOR_RESET}"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Remove Model")
                echo -e "\n${YELLOW}Model removal coming soon!${COLOR_RESET}"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

# USB management menu (placeholder)
usb_management_menu() {
    while true; do
        # Clear screen properly
        echo -e "\033[H\033[2J" >/dev/tty
        
        echo -e "${CYAN}USB Drive Management${COLOR_RESET}"
        echo -e "${DIM}Manage USB drives for Leonardo${COLOR_RESET}"
        echo ""
        
        show_menu "USB Options" \
            "List USB Drives" \
            "Deploy Leonardo to USB" \
            "Check USB Health" \
            "Backup USB Data" \
            "Back to Main Menu"
        
        case "$MENU_SELECTION" in
            "List USB Drives")
                echo -e "\n${CYAN}Detected USB Drives:${COLOR_RESET}\n"
                handle_usb_command "list"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Deploy Leonardo to USB")
                select_and_deploy_usb
                ;;
            "Check USB Health")
                echo -e "\n${CYAN}USB Health Check${COLOR_RESET}"
                select_usb_for_health_check
                ;;
            "Backup USB Data")
                echo -e "\n${YELLOW}USB backup coming soon!${COLOR_RESET}"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

# Interactive USB selection and deployment
select_and_deploy_usb() {
    echo -e "\n${CYAN}Deploy Leonardo to USB${COLOR_RESET}\n"
    
    # Get list of USB drives
    local devices=()
    local device_info=()
    
    while IFS='|' read -r device name size mount; do
        devices+=("$device")
        local info="${name:-Unknown} (${size:-N/A})"
        if [[ -n "$mount" ]] && [[ "$mount" != "Not Mounted" ]]; then
            info="$info - $mount"
        fi
        device_info+=("$info")
    done < <(detect_usb_drives)
    
    if [[ ${#devices[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No USB drives detected${COLOR_RESET}"
        echo -e "${DIM}Please insert a USB drive and try again${COLOR_RESET}"
        echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
        read -r
        return
    fi
    
    # Build menu options
    local menu_options=()
    for i in "${!devices[@]}"; do
        local color=""
        # Check if it's already a Leonardo drive
        if check_leonardo_usb "${devices[$i]}" >/dev/null 2>&1; then
            color="${GREEN}"
            menu_options+=("${color}${devices[$i]} - ${device_info[$i]} [Leonardo USB]${COLOR_RESET}")
        else
            menu_options+=("${devices[$i]} - ${device_info[$i]}")
        fi
    done
    menu_options+=("Cancel")
    
    # Show interactive menu
    show_menu "Select USB Drive" "${menu_options[@]}"
    
    if [[ "$MENU_SELECTION" == "Cancel" ]]; then
        return
    fi
    
    # Extract device from selection
    local selected_device
    selected_device=$(echo "$MENU_SELECTION" | awk '{print $1}')
    
    echo -e "\n${CYAN}Selected: $selected_device${COLOR_RESET}"
    echo -e "${YELLOW}WARNING: This will initialize the USB drive for Leonardo AI${COLOR_RESET}"
    echo -e "${DIM}All existing data will be preserved in a backup folder${COLOR_RESET}"
    echo ""
    echo -n "Continue? (y/N): "
    read -r confirm
    
    if [[ "${confirm,,}" == "y" ]]; then
        echo ""
        # Deploy directly - initialization happens inside deploy_to_usb
        handle_deployment_command "usb" "$selected_device"
    else
        echo -e "\n${YELLOW}Deployment cancelled${COLOR_RESET}"
    fi
    
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Interactive USB selection for health check
select_usb_for_health_check() {
    echo ""
    
    # Get list of USB drives
    local devices=()
    local device_info=()
    
    while IFS='|' read -r device name size mount; do
        devices+=("$device")
        local info="${name:-Unknown} (${size:-N/A})"
        if [[ -n "$mount" ]] && [[ "$mount" != "Not Mounted" ]]; then
            info="$info - $mount"
        fi
        device_info+=("$info")
    done < <(detect_usb_drives)
    
    if [[ ${#devices[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No USB drives detected${COLOR_RESET}"
        echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
        read -r
        return
    fi
    
    # Build menu options with Leonardo status
    local menu_options=()
    for i in "${!devices[@]}"; do
        if check_leonardo_usb "${devices[$i]}" >/dev/null 2>&1; then
            menu_options+=("${GREEN}${devices[$i]} - ${device_info[$i]} [Leonardo USB]${COLOR_RESET}")
        else
            menu_options+=("${DIM}${devices[$i]} - ${device_info[$i]} [Not Leonardo USB]${COLOR_RESET}")
        fi
    done
    menu_options+=("Cancel")
    
    # Show interactive menu
    show_menu "Select USB Drive for Health Check" "${menu_options[@]}"
    
    if [[ "$MENU_SELECTION" == "Cancel" ]]; then
        return
    fi
    
    # Extract device from selection
    local selected_device
    selected_device=$(echo "$MENU_SELECTION" | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')
    
    echo ""
    handle_usb_command "health" "$selected_device"
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Add missing deployment command handler
handle_deployment_command() {
    local command="$1"
    shift
    
    case "$command" in
        "usb")
            local device="$1"
            if [[ -z "$device" ]]; then
                echo -e "${RED}Error: No device specified${COLOR_RESET}"
                return 1
            fi
            
            # Use the actual USB deployment function
            deploy_to_usb "$device"
            ;;
        "local")
            echo -e "${CYAN}Local deployment...${COLOR_RESET}"
            # TODO: Implement local deployment
            echo -e "${YELLOW}Local deployment coming soon!${COLOR_RESET}"
            ;;
        *)
            echo -e "${RED}Unknown deployment command: $command${COLOR_RESET}"
            return 1
            ;;
    esac
}

# Joey Bagodonuts menu
handle_joey_menu() {
    # Source menu system and new features
    source "${LEONARDO_BASE_DIR}/src/ui/menu.sh"
    source "${LEONARDO_BASE_DIR}/src/models/dynamic_models.sh" 2>/dev/null
    source "${LEONARDO_BASE_DIR}/src/models/usb_model_check.sh" 2>/dev/null
    source "${LEONARDO_BASE_DIR}/src/models/portable_ollama.sh" 2>/dev/null
    
    while true; do
        MENU_POSITION=1
        local choice=$(show_menu "Leonardo AI - Joey's Easy Menu 🍕" \
            "💬 Chat with AI" \
            "🌐 Web Chat Interface" \
            "📊 Model Management" \
            "🔐 Stealth Mode (Portable)" \
            "💾 USB Deployment" \
            "🔧 System Tools" \
            "📚 Help & Docs" \
            "❌ Exit")
        
        case "$choice" in
            "💬 Chat with AI")
                handle_chat_menu
                ;;
            "🌐 Web Chat Interface")
                handle_web_chat_menu
                ;;
            "📊 Model Management")
                handle_model_management_menu
                ;;
            "🔐 Stealth Mode (Portable)")
                handle_stealth_mode_menu
                ;;
            "💾 USB Deployment")
                handle_usb_menu
                ;;
            "🔧 System Tools")
                handle_tools_menu
                ;;
            "📚 Help & Docs")
                handle_docs_menu
                ;;
            "❌ Exit"|"")
                echo -e "${GREEN}Thanks for using Leonardo AI! 👋${COLOR_RESET}"
                exit 0
                ;;
        esac
    done
}

# Chat submenu
handle_chat_menu() {
    while true; do
        MENU_POSITION=1
        local choice=$(show_menu "Chat Options" \
            "🚀 Start CLI Chat" \
            "🤖 Select AI Model" \
            "💾 View Chat History" \
            "🔙 Back to Main Menu")
        
        case "$choice" in
            "🚀 Start CLI Chat")
                handle_chat_command
                read -p "Press Enter to continue..."
                ;;
            "🤖 Select AI Model")
                handle_model_selection_menu
                ;;
            "💾 View Chat History")
                view_chat_history
                read -p "Press Enter to continue..."
                ;;
            "🔙 Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Web chat menu
handle_web_chat_menu() {
    while true; do
        MENU_POSITION=1
        local choice=$(show_menu "Web Chat Interface" \
            "🚀 Start Web Chat Server" \
            "🛑 Stop Web Chat Server" \
            "📊 Check Server Status" \
            "🔙 Back to Main Menu")
        
        case "$choice" in
            "🚀 Start Web Chat Server")
                echo -e "${CYAN}Starting web chat server...${COLOR_RESET}"
                handle_chat_command "web"
                echo -e "${GREEN}Web chat available at: http://localhost:8080${COLOR_RESET}"
                read -p "Press Enter to continue..."
                ;;
            "🛑 Stop Web Chat Server")
                handle_chat_command "stop"
                read -p "Press Enter to continue..."
                ;;
            "📊 Check Server Status")
                handle_chat_command "status"
                read -p "Press Enter to continue..."
                ;;
            "🔙 Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Model management menu
handle_model_management_menu() {
    while true; do
        MENU_POSITION=1
        local choice=$(show_menu "Model Management" \
            "📥 Download New Model" \
            "📋 View Available Models (Live List)" \
            "🔍 Check Model Status (USB vs Local)" \
            "🌐 Use Custom Model Registry" \
            "🗑️  Remove Model" \
            "🔙 Back to Main Menu")
        
        case "$choice" in
            "📥 Download New Model")
                handle_model_download_menu
                ;;
            "📋 View Available Models (Live List)")
                echo -e "${CYAN}Fetching latest models...${COLOR_RESET}"
                local models_json=$(get_dynamic_models "ollama" 2>/dev/null)
                if command -v jq &>/dev/null && [[ -n "$models_json" ]]; then
                    echo "$models_json" | jq -r '.models[] | "• \(.name) - \(.size) - \(.description // "")"' 2>/dev/null
                else
                    echo -e "${YELLOW}Live model list unavailable. Showing defaults:${COLOR_RESET}"
                    echo "• llama3.2:1b - 1GB - Compact Llama model"
                    echo "• qwen2.5:3b - 2GB - Alibaba's Qwen 2.5"
                    echo "• mistral:7b - 4GB - Mistral 7B"
                fi
                read -p "Press Enter to continue..."
                ;;
            "🔍 Check Model Status (USB vs Local)")
                if command -v check_usb_models &>/dev/null; then
                    check_usb_models
                else
                    echo -e "${YELLOW}Checking model locations...${COLOR_RESET}"
                    echo
                    echo "Local models (Ollama):"
                    ollama list 2>/dev/null || echo "  No local models or Ollama not installed"
                    echo
                    echo "USB models:"
                    if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ -d "$LEONARDO_USB_MOUNT/leonardo/models" ]]; then
                        echo -e "${GREEN}✓ Installed on USB${COLOR_RESET}"
                        echo "  Location: $LEONARDO_USB_MOUNT/leonardo/models"
                        if [[ -x "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/bin/ollama" ]]; then
                            echo -e "${GREEN}✓ Ollama binary present and executable${COLOR_RESET}"
                        fi
                        if [[ -d "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/models" ]]; then
                            local model_count=$(ls "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/models" 2>/dev/null | wc -l)
                            echo "  Models stored: $model_count"
                        fi
                    else
                        echo -e "${YELLOW}⚠ Not installed${COLOR_RESET}"
                        echo "  Use 'Install Portable Ollama to USB' to set up"
                    fi
                fi
                read -p "Press Enter to continue..."
                ;;
            "🌐 Use Custom Model Registry")
                echo -e "${CYAN}Custom Model Registry${COLOR_RESET}"
                echo "Enter a URL to your custom model registry JSON file."
                echo "Leave blank to cancel."
                echo
                read -p "Registry URL: " url
                if [[ -n "$url" ]]; then
                    export LEONARDO_MODEL_REGISTRY="$url"
                    echo -e "${GREEN}✓ Custom registry set: $url${COLOR_RESET}"
                fi
                read -p "Press Enter to continue..."
                ;;
            "🗑️  Remove Model")
                handle_model_removal_menu
                ;;
            "🔙 Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Model download with dynamic list
handle_model_download_menu() {
    if command -v select_model_dynamic &>/dev/null; then
        local selected_model=$(select_model_dynamic "Select a model to download:")
        if [[ -n "$selected_model" ]] && [[ "$selected_model" != "⏭️  Skip" ]]; then
            echo -e "${CYAN}Selected model: $selected_model${COLOR_RESET}"
            echo
            
            # Ask where to download
            MENU_POSITION=1
            local location=$(show_menu "Download Location" \
                "💻 Local (this computer only)" \
                "💾 USB (portable)" \
                "🔙 Cancel")
            
            case "$location" in
                "💻 Local (this computer only)")
                    if command -v ollama &>/dev/null; then
                        echo -e "${CYAN}Downloading to local system...${COLOR_RESET}"
                        ollama pull "$selected_model"
                    else
                        echo -e "${RED}Ollama not installed${COLOR_RESET}"
                        echo "Install Ollama first: curl -fsSL https://ollama.com/install.sh | sh"
                    fi
                    ;;
                "💾 USB (portable)")
                    if [[ -n "$LEONARDO_USB_MOUNT" ]]; then
                        source "${LEONARDO_BASE_DIR}/src/deployment/usb_deploy.sh"
                        download_model_to_usb "$selected_model" "$LEONARDO_USB_MOUNT/leonardo/models"
                    else
                        echo -e "${YELLOW}No USB mounted. Use USB Deployment menu first.${COLOR_RESET}"
                    fi
                    ;;
            esac
            read -p "Press Enter to continue..."
        fi
    else
        # Fallback to simple selection
        echo -e "${YELLOW}Dynamic selection unavailable. Using default list.${COLOR_RESET}"
        MENU_POSITION=1
        local model=$(show_menu "Select Model" \
            "llama3.2:1b" \
            "qwen2.5:3b" \
            "mistral:7b" \
            "Cancel")
        
        if [[ "$model" != "Cancel" ]] && [[ -n "$model" ]]; then
            ollama pull "$model" 2>/dev/null || echo -e "${RED}Failed to download${COLOR_RESET}"
        fi
        read -p "Press Enter to continue..."
    fi
}

# Stealth mode menu
handle_stealth_mode_menu() {
    while true; do
        MENU_POSITION=1
        local choice=$(show_menu "🔐 Stealth Mode (Leave No Traces)" \
            "🚀 Quick Stealth Chat" \
            "💾 Install Portable Ollama to USB" \
            "🔒 Run Portable Ollama Server" \
            "📊 Check Portable Status" \
            "📚 What is Stealth Mode?" \
            "🔙 Back to Main Menu")
        
        case "$choice" in
            "🚀 Quick Stealth Chat")
                if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ -x "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/stealth-chat.sh" ]]; then
                    echo -e "${CYAN}Starting stealth chat session...${COLOR_RESET}"
                    echo -e "${DIM}This leaves no traces on the host computer${COLOR_RESET}"
                    "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/stealth-chat.sh"
                else
                    echo -e "${YELLOW}Portable Ollama not installed on USB.${COLOR_RESET}"
                    echo "Install it first using 'Install Portable Ollama to USB'"
                fi
                read -p "Press Enter to continue..."
                ;;
            "💾 Install Portable Ollama to USB")
                if [[ -n "$LEONARDO_USB_MOUNT" ]]; then
                    echo -e "${CYAN}Installing Portable Ollama...${COLOR_RESET}"
                    if command -v install_ollama_portable &>/dev/null; then
                        install_ollama_portable "$LEONARDO_USB_MOUNT"
                    else
                        echo -e "${RED}Portable installer not available${COLOR_RESET}"
                    fi
                else
                    echo -e "${YELLOW}No USB mounted. Use USB Deployment menu first.${COLOR_RESET}"
                fi
                read -p "Press Enter to continue..."
                ;;
            "🔒 Run Portable Ollama Server")
                if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ -x "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/run-ollama.sh" ]]; then
                    echo -e "${CYAN}Starting portable Ollama server...${COLOR_RESET}"
                    echo -e "${DIM}Press Ctrl+C to stop${COLOR_RESET}"
                    "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/run-ollama.sh" serve
                else
                    echo -e "${YELLOW}Portable Ollama not found on USB${COLOR_RESET}"
                fi
                ;;
            "📊 Check Portable Status")
                echo -e "${CYAN}Portable Ollama Status:${COLOR_RESET}"
                echo
                if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ -d "$LEONARDO_USB_MOUNT/leonardo/tools/ollama" ]]; then
                    echo -e "${GREEN}✓ Installed on USB${COLOR_RESET}"
                    echo "  Location: $LEONARDO_USB_MOUNT/leonardo/tools/ollama"
                    if [[ -x "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/bin/ollama" ]]; then
                        echo -e "${GREEN}✓ Ollama binary present and executable${COLOR_RESET}"
                    fi
                    if [[ -d "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/models" ]]; then
                        local model_count=$(ls "$LEONARDO_USB_MOUNT/leonardo/tools/ollama/models" 2>/dev/null | wc -l)
                        echo "  Models stored: $model_count"
                    fi
                else
                    echo -e "${YELLOW}⚠ Not installed${COLOR_RESET}"
                    echo "  Use 'Install Portable Ollama to USB' to set up"
                fi
                read -p "Press Enter to continue..."
                ;;
            "📚 What is Stealth Mode?")
                echo -e "${CYAN}═══ About Stealth Mode ═══${COLOR_RESET}"
                echo
                echo -e "${BOLD}What is it?${COLOR_RESET}"
                echo "Stealth mode runs AI entirely from your USB drive without:"
                echo "• Installing anything on the host computer"
                echo "• Leaving any files, logs, or traces behind"
                echo "• Requiring administrator/sudo privileges"
                echo
                echo -e "${BOLD}Perfect for:${COLOR_RESET}"
                echo "• Public computers (libraries, internet cafes)"
                echo "• Work computers with restrictions"
                echo "• Privacy-conscious users"
                echo "• Testing without commitment"
                echo
                echo -e "${BOLD}How it works:${COLOR_RESET}"
                echo "1. Ollama and models are stored on your USB"
                echo "2. All data stays in USB's temporary folders"
                echo "3. Nothing touches the host computer's storage"
                echo "4. Remove USB = remove all traces"
                echo
                read -p "Press Enter to continue..."
                ;;
            "🔙 Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# USB deployment menu
handle_usb_menu() {
    while true; do
        MENU_POSITION=1
        local choice=$(show_menu "USB Deployment" \
            "🚀 Deploy Leonardo to USB" \
            "📊 Check USB Status" \
            "🔐 Setup Portable Mode" \
            "📦 Backup to USB" \
            "🔙 Back to Main Menu")
        
        case "$choice" in
            "🚀 Deploy Leonardo to USB")
                echo -e "${CYAN}Starting USB deployment...${COLOR_RESET}"
                leonardo deploy usb
                read -p "Press Enter to continue..."
                ;;
            "📊 Check USB Status")
                if [[ -n "$LEONARDO_USB_MOUNT" ]]; then
                    echo -e "${GREEN}USB Mounted: $LEONARDO_USB_MOUNT${COLOR_RESET}"
                    echo
                    if [[ -d "$LEONARDO_USB_MOUNT/leonardo" ]]; then
                        echo "Leonardo installation found:"
                        du -sh "$LEONARDO_USB_MOUNT/leonardo"
                        echo
                        echo "Contents:"
                        ls -la "$LEONARDO_USB_MOUNT/leonardo/"
                    else
                        echo -e "${YELLOW}Leonardo not installed on USB${COLOR_RESET}"
                    fi
                else
                    echo -e "${YELLOW}No USB currently mounted${COLOR_RESET}"
                    echo "Mount a USB first using 'Deploy Leonardo to USB'"
                fi
                read -p "Press Enter to continue..."
                ;;
            "🔐 Setup Portable Mode")
                if [[ -n "$LEONARDO_USB_MOUNT" ]]; then
                    echo -e "${CYAN}Setting up portable mode...${COLOR_RESET}"
                    source "${LEONARDO_BASE_DIR}/src/models/portable_ollama.sh" 2>/dev/null
                    if command -v install_ollama_portable &>/dev/null; then
                        install_ollama_portable "$LEONARDO_USB_MOUNT"
                    fi
                else
                    echo -e "${YELLOW}Mount a USB first${COLOR_RESET}"
                fi
                read -p "Press Enter to continue..."
                ;;
            "📦 Backup to USB")
                echo -e "${CYAN}Backup feature coming soon!${COLOR_RESET}"
                read -p "Press Enter to continue..."
                ;;
            "🔙 Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Tools menu
handle_tools_menu() {
    while true; do
        MENU_POSITION=1
        local choice=$(show_menu "System Tools" \
            "🔍 System Check" \
            "📊 Resource Monitor" \
            "🛠️  Install Dependencies" \
            "🔙 Back to Main Menu")
        
        case "$choice" in
            "🔍 System Check")
                leonardo doctor
                read -p "Press Enter to continue..."
                ;;
            "📊 Resource Monitor")
                echo -e "${CYAN}System Resources:${COLOR_RESET}"
                echo
                echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)% used"
                echo "Memory: $(free -h | awk '/^Mem:/ {print $3 " / " $2}')"
                echo "Disk: $(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 " used)"}')"
                read -p "Press Enter to continue..."
                ;;
            "🛠️  Install Dependencies")
                leonardo doctor --fix
                read -p "Press Enter to continue..."
                ;;
            "🔙 Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Help menu
handle_docs_menu() {
    while true; do
        MENU_POSITION=1
        local choice=$(show_menu "Help & Documentation" \
            "📖 Quick Start Guide" \
            "💡 Tips & Tricks" \
            "🆘 Troubleshooting" \
            "📧 Contact Support" \
            "🔙 Back to Main Menu")
        
        case "$choice" in
            "📖 Quick Start Guide")
                echo -e "${CYAN}═══ Quick Start Guide ═══${COLOR_RESET}"
                echo
                echo "1. ${BOLD}Chat with AI:${COLOR_RESET}"
                echo "   Select 'Chat with AI' from the main menu"
                echo
                echo "2. ${BOLD}Download Models:${COLOR_RESET}"
                echo "   Go to 'Model Management' > 'Download New Model'"
                echo
                echo "3. ${BOLD}Use Stealth Mode:${COLOR_RESET}"
                echo "   Perfect for using AI without installing anything"
                echo
                echo "4. ${BOLD}Deploy to USB:${COLOR_RESET}"
                echo "   Take Leonardo anywhere with USB deployment"
                read -p "Press Enter to continue..."
                ;;
            "💡 Tips & Tricks")
                echo -e "${CYAN}═══ Tips & Tricks ═══${COLOR_RESET}"
                echo
                echo "• Use smaller models (1b-3b) for faster responses"
                echo "• Portable mode leaves no traces on the computer"
                echo "• Custom registries let you use private models"
                echo "• USB deployment works on any Linux/Mac system"
                echo "• Web chat interface works on phones/tablets too"
                read -p "Press Enter to continue..."
                ;;
            "🆘 Troubleshooting")
                echo -e "${CYAN}═══ Common Issues ═══${COLOR_RESET}"
                echo
                echo "Q: Models not downloading?"
                echo "A: Check internet connection and try again"
                echo
                echo "Q: USB not detected?"
                echo "A: Make sure USB is formatted as FAT32 or ext4"
                echo
                echo "Q: Chat not working?"
                echo "A: Run 'System Check' to verify dependencies"
                read -p "Press Enter to continue..."
                ;;
            "📧 Contact Support")
                echo -e "${CYAN}Support Information:${COLOR_RESET}"
                echo
                echo "GitHub: https://github.com/leonardo-ai/leonardo"
                echo "Email: support@leonardo-ai.com"
                echo "Discord: https://discord.gg/leonardo-ai"
                read -p "Press Enter to continue..."
                ;;
            "🔙 Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Helper function for model removal
handle_model_removal_menu() {
    echo -e "${CYAN}Model Removal${COLOR_RESET}"
    echo -e "${YELLOW}This feature is coming soon!${COLOR_RESET}"
    read -p "Press Enter to continue..."
}

# Helper function for model selection
handle_model_selection_menu() {
    if command -v select_model_dynamic &>/dev/null; then
        local selected=$(select_model_dynamic "Select default chat model:")
        if [[ -n "$selected" ]] && [[ "$selected" != "⏭️  Skip" ]]; then
            echo -e "${GREEN}Default model set to: $selected${COLOR_RESET}"
            export LEONARDO_DEFAULT_MODEL="$selected"
        fi
    else
        echo -e "${YELLOW}Model selection unavailable${COLOR_RESET}"
    fi
    read -p "Press Enter to continue..."
}

# Helper to view chat history
view_chat_history() {
    local history_dir="${LEONARDO_BASE_DIR}/chat_history"
    if [[ -d "$history_dir" ]]; then
        echo -e "${CYAN}Recent Chat Sessions:${COLOR_RESET}"
        ls -lt "$history_dir"/*.txt 2>/dev/null | head -10 | while read -r line; do
            echo "  $line"
        done
    else
        echo -e "${YELLOW}No chat history found${COLOR_RESET}"
    fi
}

# Run system tests
run_system_tests() {
    echo -e "${CYAN}Running System Tests...${COLOR_RESET}"
    echo ""
    
    local tests_passed=0
    local tests_failed=0
    
    # Test 1: Check shell environment
    echo -n "1. Shell Environment... "
    if [[ -n "$BASH_VERSION" ]]; then
        echo -e "${GREEN}✓ Bash $BASH_VERSION${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${RED}✗ Bash not detected${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 2: Check terminal support
    echo -n "2. Terminal Support... "
    if [[ -n "$TERM" ]] && command -v tput >/dev/null 2>&1; then
        echo -e "${GREEN}✓ $TERM ($(tput colors) colors)${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${RED}✗ Terminal not properly configured${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 3: Check Python
    echo -n "3. Python Installation... "
    if command -v python3 >/dev/null 2>&1; then
        local py_version=$(python3 --version 2>&1 | awk '{print $2}')
        echo -e "${GREEN}✓ Python $py_version${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ Python 3 not found (needed for web interface)${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 4: Check disk space
    echo -n "4. Disk Space... "
    local free_space=$(df -h "$HOME" | awk 'NR==2 {print $4}')
    local free_gb=$(df -BG "$HOME" | awk 'NR==2 {gsub(/G/,"",$4); print $4}')
    if [[ $free_gb -gt 10 ]]; then
        echo -e "${GREEN}✓ $free_space available${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ Only $free_space available (recommend >10GB)${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 5: Check memory
    echo -n "5. System Memory... "
    local total_mem=$(free -h | awk '/^Mem:/ {print $2}')
    local avail_mem=$(free -h | awk '/^Mem:/ {print $7}')
    echo -e "${GREEN}✓ $avail_mem available of $total_mem${COLOR_RESET}"
    ((tests_passed++))
    
    # Test 6: Check USB support
    echo -n "6. USB Detection... "
    if command -v lsblk >/dev/null 2>&1; then
        local usb_count=$(lsblk -d -o NAME,TRAN | grep -c "usb" || echo 0)
        if [[ $usb_count -gt 0 ]]; then
            echo -e "${GREEN}✓ $usb_count USB device(s) detected${COLOR_RESET}"
        else
            echo -e "${YELLOW}⚠ No USB devices detected${COLOR_RESET}"
        fi
        ((tests_passed++))
    else
        echo -e "${RED}✗ lsblk not available${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 7: Check network
    echo -n "7. Network Connection... "
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Internet connected${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ No internet connection${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 8: Check Leonardo directories
    echo -n "8. Leonardo Directories... "
    if [[ -d "$LEONARDO_BASE_DIR" ]]; then
        echo -e "${GREEN}✓ Base directory exists${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ Base directory not initialized${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 9: Check model providers
    echo -n "9. Model Providers... "
    if command -v ollama >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Ollama installed${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ Ollama not installed (needed for models)${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 10: Check permissions
    echo -n "10. File Permissions... "
    if [[ -w "$HOME" ]]; then
        echo -e "${GREEN}✓ Write access to home directory${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${RED}✗ No write access to home directory${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Summary
    echo ""
    echo "════════════════════════════════════════════"
    echo -e "Tests Passed: ${GREEN}$tests_passed${COLOR_RESET}"
    echo -e "Tests Failed: ${RED}$tests_failed${COLOR_RESET}"
    
    if [[ $tests_failed -eq 0 ]]; then
        echo -e "\n${GREEN}✓ All systems ready!${COLOR_RESET}"
    elif [[ $tests_failed -lt 3 ]]; then
        echo -e "\n${YELLOW}⚠ System mostly ready with minor issues${COLOR_RESET}"
    else
        echo -e "\n${RED}✗ Multiple issues detected, please review${COLOR_RESET}"
    fi
    
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Launch web interface
launch_web_interface() {
    echo -e "\n${CYAN}Launching Web Interface...${COLOR_RESET}"
    start_web_server
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

# Check if any models are installed
check_installed_models() {
    # Check Ollama models
    if command_exists ollama && ollama list 2>/dev/null | grep -q "^[a-zA-Z]"; then
        return 0
    fi
    
    # Check local models
    if [[ -d "$LEONARDO_MODEL_DIR" ]]; then
        local local_models=$(find "$LEONARDO_MODEL_DIR" -name "*.gguf" 2>/dev/null | wc -l)
        [[ $local_models -gt 0 ]] && return 0
    fi
    
    return 1
}

# Get list of available models for chat
get_chat_models() {
    local models=()
    
    # Get Ollama models
    if command_exists ollama; then
        while IFS= read -r line; do
            if [[ -n "$line" && ! "$line" =~ ^NAME ]]; then
                local model_name=$(echo "$line" | awk '{print $1}')
                models+=("$model_name")
            fi
        done < <(ollama list 2>/dev/null)
    fi
    
    # Get local GGUF models
    if [[ -d "$LEONARDO_MODEL_DIR" ]]; then
        for model_file in "$LEONARDO_MODEL_DIR"/*.gguf; do
            if [[ -f "$model_file" ]]; then
                local model_name=$(basename "$model_file" .gguf)
                models+=("$model_name")
            fi
        done
    fi
    
    printf '%s\n' "${models[@]}"
}

# Handle chat command
handle_chat_command() {
    # Get available models  
    local models=()
    if command_exists ollama; then
        mapfile -t models < <(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')
    fi
    
    # Check for local models in LEONARDO_MODEL_DIR
    if [[ -d "$LEONARDO_MODEL_DIR" ]]; then
        while IFS= read -r -d '' model_file; do
            models+=("local:$(basename "$model_file")")
        done < <(find "$LEONARDO_MODEL_DIR" -name "*.gguf" -print0 2>/dev/null)
    fi
    
    if [[ ${#models[@]} -eq 0 ]]; then
        echo -e "${RED}No AI models installed!${COLOR_RESET}"
        echo -e "${YELLOW}Install a model first using Model Manager.${COLOR_RESET}"
        pause
        return
    fi
    
    # Select model if multiple available
    local selected_model
    if [[ ${#models[@]} -eq 1 ]]; then
        selected_model="${models[0]}"
    else
        selected_model=$(show_menu "Select AI Model" "${models[@]}") || return
    fi
    
    # Launch chat interface
    start_chat_interface "$selected_model"
}

# Start chat interface with selected model
start_chat_interface() {
    local model="$1"
    
    # Start chat
    start_chat "$model"
}

# Check if any models are installed
check_installed_models() {
    # Check Ollama models
    if command_exists ollama; then
        local ollama_models=$(ollama list 2>/dev/null | tail -n +2 | wc -l)
        [[ $ollama_models -gt 0 ]] && return 0
    fi
    
    # Check local models
    if [[ -d "$LEONARDO_MODEL_DIR" ]]; then
        local local_models=$(find "$LEONARDO_MODEL_DIR" -name "*.gguf" 2>/dev/null | wc -l)
        [[ $local_models -gt 0 ]] && return 0
    fi
    
    return 1
}

# System utilities menu
system_utilities_menu() {
    while true; do
        local selection
        selection=$(show_menu "System Utilities" \
            "Run System Tests" \
            "Clean Cache" \
            "Update Leonardo" \
            "View Logs" \
            "Back to Main Menu") || break
        
        case "$selection" in
            "Run System Tests")
                run_system_tests
                pause
                ;;
            "Clean Cache")
                echo -e "${YELLOW}Cleaning cache...${COLOR_RESET}"
                # TODO: Implement cache cleaning
                pause
                ;;
            "Update Leonardo")
                echo -e "${YELLOW}Checking for updates...${COLOR_RESET}"
                # TODO: Implement update check
                pause
                ;;
            "View Logs")
                if [[ -f "$LEONARDO_LOG_FILE" ]]; then
                    less "$LEONARDO_LOG_FILE"
                else
                    echo -e "${YELLOW}No logs found${COLOR_RESET}"
                    pause
                fi
                ;;
            "Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Show about information
show_about() {
    clear
    show_banner
    echo
    echo -e "${BOLD}About Leonardo AI Universal${COLOR_RESET}"
    echo -e "${DIM}────────────────────────────────────────────────${COLOR_RESET}"
    echo
    echo "Leonardo is a portable AI assistant that can run from USB drives"
    echo "and provides easy access to various AI models."
    echo
    echo -e "${CYAN}Version:${COLOR_RESET} $LEONARDO_VERSION ($LEONARDO_BUILD)"
    echo -e "${CYAN}License:${COLOR_RESET} MIT"
    echo -e "${CYAN}Website:${COLOR_RESET} https://github.com/leonardo-ai/leonardo"
    echo
    echo -e "${BOLD}Features:${COLOR_RESET}"
    echo "  • Portable USB deployment"
    echo "  • Multiple AI model support"
    echo "  • Offline model management"
    echo "  • Cross-platform compatibility"
    echo "  • Web interface"
    echo
}

# Chat with a model
chat_with_model() {
    local model="$1"
    
    # Start chat
    start_chat "$model"
}
