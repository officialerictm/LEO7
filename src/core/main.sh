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
        # Show appropriate menu
        show_main_menu
        
        # Read user choice
        read -p "Enter your choice: " choice
        
        # Process the choice
        if ! process_choice "$choice"; then
            keep_running=false
        fi
        
        # Pause before returning to menu (unless exiting)
        if [[ "$keep_running" == "true" ]]; then
            echo
            read -p "Press Enter to continue..."
        fi
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
    
    # Get list of USB drives and separate recommended devices
    local -a recommended_devices=()
    local -a recommended_info=()
    local -a other_devices=()
    local -a other_info=()

    while IFS='|' read -r device name size mount; do
        local info="${name:-Unknown} (${size:-N/A})"
        if [[ -n "$mount" ]] && [[ "$mount" != "Not Mounted" ]]; then
            info="$info - $mount"
        fi

        if check_leonardo_usb "$device" >/dev/null 2>&1; then
            recommended_devices+=("$device")
            recommended_info+=("$info")
        else
            other_devices+=("$device")
            other_info+=("$info")
        fi
    done < <(detect_usb_drives)
    
    local total_devices=$(( ${#recommended_devices[@]} + ${#other_devices[@]} ))
    if [[ $total_devices -eq 0 ]]; then
        echo -e "${YELLOW}No USB drives detected${COLOR_RESET}"
        echo -e "${DIM}Please insert a USB drive and try again${COLOR_RESET}"
        echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
        read -r
        return
    fi

    # Build menu options
    local menu_options=()
    for i in "${!recommended_devices[@]}"; do
        menu_options+=("${GREEN}${recommended_devices[$i]} - ${recommended_info[$i]} [Leonardo USB]${COLOR_RESET}")
    done
    for i in "${!other_devices[@]}"; do
        menu_options+=("${YELLOW}${other_devices[$i]} - ${other_info[$i]}${COLOR_RESET}")
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
    
    # Get list of USB drives and categorize
    local -a recommended_devices=()
    local -a recommended_info=()
    local -a other_devices=()
    local -a other_info=()

    while IFS='|' read -r device name size mount; do
        local info="${name:-Unknown} (${size:-N/A})"
        if [[ -n "$mount" ]] && [[ "$mount" != "Not Mounted" ]]; then
            info="$info - $mount"
        fi

        if check_leonardo_usb "$device" >/dev/null 2>&1; then
            recommended_devices+=("$device")
            recommended_info+=("$info")
        else
            other_devices+=("$device")
            other_info+=("$info")
        fi
    done < <(detect_usb_drives)
    
    local total_devices=$(( ${#recommended_devices[@]} + ${#other_devices[@]} ))
    if [[ $total_devices -eq 0 ]]; then
        echo -e "${YELLOW}No USB drives detected${COLOR_RESET}"
        echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
        read -r
        return
    fi

    # Build menu options with recommended first
    local menu_options=()
    for i in "${!recommended_devices[@]}"; do
        menu_options+=("${GREEN}${recommended_devices[$i]} - ${recommended_info[$i]} [Leonardo USB]${COLOR_RESET}")
    done
    for i in "${!other_devices[@]}"; do
        menu_options+=("${YELLOW}${other_devices[$i]} - ${other_info[$i]}${COLOR_RESET}")
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

# Function to check if running from USB
is_usb_deployment() {
    # Check environment variable first
    if [[ "${LEONARDO_USB_MODE:-}" == "true" ]]; then
        return 0
    fi
    
    # Check if script path indicates USB location
    local script_path="${BASH_SOURCE[0]:-$0}"
    local real_path=$(readlink -f "$script_path" 2>/dev/null || realpath "$script_path" 2>/dev/null || echo "$script_path")
    
    if echo "$real_path" | grep -iE '/(media|mnt|run/media|Volumes)/[^/]+/(leonardo|LEONARDO)' >/dev/null; then
        return 0
    fi
    
    return 1
}

# Show USB-specific main menu
show_usb_main_menu() {
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}          🔌 Leonardo AI Universal - USB Mode${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo
    echo -e "${GREEN}USB Location: ${LEONARDO_USB_MOUNT:-Detected}${COLOR_RESET}"
    echo
    echo -e "${CYAN}Main Menu:${COLOR_RESET}"
    echo
    echo "  1) 💬 Chat With AI              - Start AI conversation"
    echo "  2) 🔧 System Management         - Configure Leonardo"
    echo "  3) 📦 Model Management          - Download/manage AI models"
    echo "  4) 💾 USB Management            - Format/prepare USB drives"
    echo "  5) 🚀 Deployment Options        - Setup AI environments"
    echo "  6) 📊 Dashboard                 - System overview"
    echo "  7) 🌐 Web Interface             - Browser-based UI"
    echo "  8) 📋 System Info               - Show system details"
    echo "  9) ❓ Help                      - Show documentation"
    echo "  0) 🚪 Exit                      - Exit Leonardo"
    echo
    echo -e "${DIM}────────────────────────────────────────────────────────────────${COLOR_RESET}"
    echo
}

# Show main menu
show_main_menu() {
    # Check if USB deployment and show appropriate menu
    if is_usb_deployment; then
        show_usb_main_menu
        return
    fi
    
    # Original host menu
    clear
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}               🤖 Leonardo AI Universal v${LEONARDO_VERSION}${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo
    echo -e "${CYAN}Main Menu:${COLOR_RESET}"
    echo
    echo "  1) 🔧 System Management         - Configure Leonardo"
    echo "  2) 📦 Model Management          - Download/manage AI models"
    echo "  3) 💬 Chat With AI              - Start AI conversation"
    echo "  4) 💾 USB Management            - Format/prepare USB drives"
    echo "  5) 🚀 Deployment Options        - Setup AI environments"
    echo "  6) 📊 Dashboard                 - System overview"
    echo "  7) 🌐 Web Interface             - Browser-based UI"
    echo "  8) 📋 System Info               - Show system details"
    echo "  9) ❓ Help                      - Show documentation"
    echo "  0) 🚪 Exit                      - Exit Leonardo"
    echo
    echo -e "${DIM}────────────────────────────────────────────────────────────────${COLOR_RESET}"
    echo
}

# Process user choice
process_choice() {
    local choice="$1"
    
    # Handle choices differently for USB mode
    if is_usb_deployment; then
        case "$choice" in
            1) handle_chat_command ;;
            2) handle_system_menu ;;
            3) handle_model_menu ;;
            4) handle_usb_menu ;;
            5) handle_deployment_menu ;;
            6) handle_dashboard_command ;;
            7) handle_web_command ;;
            8) handle_info_command ;;
            9) handle_help_command ;;
            0|q|Q) return 1 ;;
            *) echo -e "${RED}Invalid choice. Please try again.${COLOR_RESET}" ;;
        esac
    else
        # Original host mode choices
        case "$choice" in
            1) handle_system_menu ;;
            2) handle_model_menu ;;
            3) handle_chat_command ;;
            4) handle_usb_menu ;;
            5) handle_deployment_menu ;;
            6) handle_dashboard_command ;;
            7) handle_web_command ;;
            8) handle_info_command ;;
            9) handle_help_command ;;
            0|q|Q) return 1 ;;
            *) echo -e "${RED}Invalid choice. Please try again.${COLOR_RESET}" ;;
        esac
    fi
    
    return 0
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
    echo -e "${COLOR_CYAN}Thank you for using Leonardo AI Universal!${COLOR_RESET}"
    echo -e "${COLOR_DIM}Stay curious, stay creative.${COLOR_RESET}"
    echo ""
    
    # Cleanup
    cleanup_temp_files 2>/dev/null || true
    
    # Save session state if needed
    # TODO: Implement session persistence
    
    exit 0
}

# Handle chat command
handle_chat_command() {
    log_message "INFO" "Starting chat interface"
    
    # Auto-detect by default, no prompt needed
    start_location_aware_chat "" "auto"
}

# Check if running from USB deployment
is_usb_deployment() {
    # Check multiple indicators
    [[ "${LEONARDO_USB_MODE:-}" == "true" ]] && return 0
    [[ -n "${LEONARDO_USB_MOUNT:-}" ]] && return 0
    [[ -f "/leonardo_usb_marker" ]] && return 0
    
    # Check if script path contains common USB mount patterns
    local script_path="${BASH_SOURCE[0]:-$0}"
    local real_path=$(readlink -f "$script_path" 2>/dev/null || realpath "$script_path" 2>/dev/null || echo "$script_path")
    
    # Check for common USB mount patterns (case-insensitive for macOS)
    if echo "$real_path" | grep -iE '/(Volumes|media|mnt|run/media|usb|removable)/' >/dev/null 2>&1; then
        return 0
    fi
    
    # Check if we're in a leonardo directory on a removable device
    if [[ -d "${script_path%/*}/models" ]] && [[ -f "${script_path%/*}/leonardo.sh" ]]; then
        # Likely a portable installation
        return 0
    fi
    
    return 1
}

# Check if any models are installed
check_installed_models() {
    # For USB deployment, always show chat option
    if is_usb_deployment; then
        return 0  # Always allow chat on USB - models should be there
    fi
    
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
    
    # Also check common model locations
    local common_dirs=(
        "$LEONARDO_BASE_DIR/models"
        "$HOME/.leonardo/models"
        "/opt/leonardo/models"
        "./models"
    )
    
    for dir in "${common_dirs[@]}"; do
        if [[ -d "$dir" ]] && [[ -n "$(find "$dir" -name "*.gguf" 2>/dev/null | head -1)" ]]; then
            return 0
        fi
    done
    
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

# Deploy to USB interactively
deploy_to_usb_interactive() {
    # Source USB deployment if not already
    if [[ -f "${LEONARDO_DIR}/src/deployment/usb_deploy.sh" ]]; then
        source "${LEONARDO_DIR}/src/deployment/usb_deploy.sh"
    else
        echo -e "${RED}Error: USB deployment module not found${COLOR_RESET}"
        return 1
    fi
    
    # Run the USB deployment command
    handle_deploy_usb_command
}

# Initialize Leonardo
initialize_leonardo() {
    log_message "INFO" "Initializing Leonardo AI Universal v${LEONARDO_VERSION}"
    
    # Check if we're already running from USB
    local running_from_usb=false
    local script_path="${BASH_SOURCE[0]:-$0}"
    local real_path=$(readlink -f "$script_path" 2>/dev/null || realpath "$script_path" 2>/dev/null || echo "$script_path")
    
    if echo "$real_path" | grep -iE '/(Volumes|media|mnt|run/media|usb|removable)/' >/dev/null 2>&1; then
        running_from_usb=true
        export LEONARDO_USB_MOUNT="${real_path%/leonardo/*}"
    fi
    
    # Check for deployment configuration
    if [[ -f "${LEONARDO_DIR}/src/core/deployment_mode.sh" ]]; then
        source "${LEONARDO_DIR}/src/core/deployment_mode.sh"
    fi
    
    # If not already deployed to USB and no config exists, prompt for USB deployment
    if ! load_deployment_config && [[ "$running_from_usb" != "true" ]]; then
        clear
        echo -e "${CYAN}${LEONARDO_BANNERS[0]}${COLOR_RESET}"
        echo
        echo -e "${YELLOW}Welcome to Leonardo AI Universal - AI on a Stick!${COLOR_RESET}"
        echo
        echo -e "${GREEN}Leonardo is designed to run entirely from a USB drive.${COLOR_RESET}"
        echo "This provides:"
        echo "  • Complete portability between computers"
        echo "  • No installation on host systems"
        echo "  • Privacy - your AI stays with you"
        echo "  • Easy backup - just copy your USB"
        echo
        echo -e "${CYAN}Would you like to deploy Leonardo to a USB drive now?${COLOR_RESET}"
        echo
        echo "1) Yes, deploy to USB (recommended)"
        echo "2) No, I'll run from current location"
        echo
        
        local choice
        read -p "Select option (1-2): " choice
        
        case "$choice" in
            1)
                echo
                echo -e "${GREEN}Great! Let's set up your AI stick.${COLOR_RESET}"
                echo
                # Run USB deployment
                deploy_to_usb_interactive
                exit 0  # Exit after deployment
                ;;
            2)
                echo
                echo -e "${YELLOW}Running from current location.${COLOR_RESET}"
                echo "Note: For the full Leonardo experience, consider USB deployment later."
                echo "Run: leonardo deploy-usb"
                echo
                
                # Still need to select deployment mode
                local mode=$(select_deployment_mode)
                configure_deployment "$mode"
                ;;
            *)
                echo -e "${RED}Invalid choice. Defaulting to USB deployment prompt.${COLOR_RESET}"
                deploy_to_usb_interactive
                exit 0
                ;;
        esac
    elif [[ "$running_from_usb" == "true" ]] && ! load_deployment_config; then
        # Already on USB, just configure
        echo -e "${GREEN}Detected Leonardo running from USB!${COLOR_RESET}"
        echo
        configure_deployment "usb"
    fi
    
    # Create necessary directories
    ensure_directory "$LEONARDO_BASE_DIR"
    ensure_directory "$LEONARDO_CONFIG_DIR" 
    ensure_directory "$LEONARDO_MODEL_DIR"
    ensure_directory "$LEONARDO_LOG_DIR"
    ensure_directory "$LEONARDO_TEMP_DIR"
    
    # Load configuration
    load_config
    
    # Initialize components based on deployment mode
    if [[ "${LEONARDO_USB_MODE:-false}" == "true" ]]; then
        log_message "INFO" "Running in USB mode (${LEONARDO_DEPLOYMENT_MODE})"
    fi
    
    # Check system requirements
    check_requirements
    
    # Show welcome message
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        show_banner
    fi
    
    log_message "INFO" "Leonardo initialized successfully"
}

# Handle help command
handle_help_command() {
    show_help
    return 0
}

# Handle info command  
handle_info_command() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}               Leonardo AI Universal - System Info${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    echo -e "${GREEN}Version:${COLOR_RESET} $LEONARDO_VERSION ($LEONARDO_BUILD)"
    echo -e "${GREEN}Location:${COLOR_RESET} ${LEONARDO_DIR:-Not set}"
    
    if is_usb_deployment; then
        echo -e "${GREEN}Deployment:${COLOR_RESET} USB Mode"
        echo -e "${GREEN}USB Mount:${COLOR_RESET} ${LEONARDO_USB_MOUNT:-Detected}"
        echo -e "${GREEN}Model Directory:${COLOR_RESET} ${LEONARDO_MODEL_DIR:-Not set}"
    else
        echo -e "${GREEN}Deployment:${COLOR_RESET} Host Mode"
    fi
    
    echo -e "${GREEN}Config Directory:${COLOR_RESET} ${LEONARDO_CONFIG_DIR:-Not set}"
    echo -e "${GREEN}Data Directory:${COLOR_RESET} ${LEONARDO_DATA_DIR:-Not set}"
    
    # Check Ollama status
    if command -v ollama >/dev/null 2>&1; then
        echo -e "${GREEN}Ollama:${COLOR_RESET} Installed"
        if pgrep -x "ollama" >/dev/null 2>&1; then
            echo -e "${GREEN}Ollama Service:${COLOR_RESET} Running"
        else
            echo -e "${YELLOW}Ollama Service:${COLOR_RESET} Not running"
        fi
    else
        echo -e "${YELLOW}Ollama:${COLOR_RESET} Not installed"
    fi
    
    # Show model count
    local model_count=0
    if [[ -d "${LEONARDO_MODEL_DIR:-}" ]]; then
        model_count=$(find "${LEONARDO_MODEL_DIR}" -name "*.gguf" 2>/dev/null | wc -l)
    fi
    echo -e "${GREEN}GGUF Models:${COLOR_RESET} $model_count installed"
    
    return 0
}

# Handle dashboard command
handle_dashboard_command() {
    if type show_dashboard >/dev/null 2>&1; then
        show_dashboard
    else
        echo -e "${YELLOW}Dashboard not available${COLOR_RESET}"
    fi
    return 0
}

# Handle web command
handle_web_command() {
    echo -e "${YELLOW}Web interface coming soon!${COLOR_RESET}"
    return 0
}
