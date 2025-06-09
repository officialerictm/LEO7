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
                echo -e "\n${CYAN}Select USB device for deployment:${COLOR_RESET}"
                if command -v usb_cli >/dev/null 2>&1; then
                    # Show USB devices
                    usb_cli list
                    echo ""
                    echo -n "Enter device path (e.g., /dev/sdc): "
                    read -r device
                    if [[ -n "$device" ]]; then
                        handle_deployment_command "usb" "$device"
                    else
                        echo -e "${RED}No device selected${COLOR_RESET}"
                    fi
                else
                    echo -e "${RED}USB CLI not available${COLOR_RESET}"
                fi
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
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
    
    if echo "$real_path" | grep -iE '/(media|mnt|run/media|Volumes)/[^/]+/(leonardo|LEONARDO)' >/dev/null 2>&1; then
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

# Handle help command - show comprehensive documentation
handle_help_command() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}               ❓ Leonardo AI Universal Help                ${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    
    echo -e "\n${BOLD}🎯 Quick Start Guide:${COLOR_RESET}"
    echo "1. ${BOLD}First Time Setup:${COLOR_RESET}"
    echo "   • Insert a USB drive (8GB+ recommended)"
    echo "   • Select '💾 USB Management' → 'Deploy to USB'"
    echo "   • Leonardo will install everything on the USB"
    echo ""
    echo "2. ${BOLD}Download AI Models:${COLOR_RESET}"
    echo "   • Select '📦 Model Management'"
    echo "   • Choose models based on your hardware"
    echo "   • Models are stored on your USB for portability"
    echo ""
    echo "3. ${BOLD}Start Chatting:${COLOR_RESET}"
    echo "   • Select '💬 Chat With AI'"
    echo "   • Choose a model and start conversing"
    echo ""
    
    echo -e "\n${BOLD}📚 Key Concepts:${COLOR_RESET}"
    echo "• ${BOLD}USB-First:${COLOR_RESET} Leonardo runs entirely from USB by default"
    echo "• ${BOLD}Zero-Trace:${COLOR_RESET} Leaves no data on host computers"
    echo "• ${BOLD}Portable AI:${COLOR_RESET} Take your AI anywhere, use on any computer"
    echo "• ${BOLD}Privacy-First:${COLOR_RESET} Your data stays on your USB"
    
    echo -e "\n${BOLD}⌨️  Command Line Usage:${COLOR_RESET}"
    echo "• leonardo chat          - Start AI chat"
    echo "• leonardo model list    - List available models"
    echo "• leonardo usb list      - Show USB drives"
    echo "• leonardo deploy usb    - Deploy to USB"
    echo "• leonardo help          - Show this help"
    
    echo -e "\n${BOLD}🔧 Troubleshooting:${COLOR_RESET}"
    echo "• ${BOLD}No models found:${COLOR_RESET} Run Model Management to download"
    echo "• ${BOLD}USB not detected:${COLOR_RESET} Check USB is properly inserted"
    echo "• ${BOLD}Slow performance:${COLOR_RESET} Use smaller models or better hardware"
    echo "• ${BOLD}Can't write to USB:${COLOR_RESET} Check USB isn't write-protected"
    
    echo -e "\n${BOLD}📖 Documentation:${COLOR_RESET}"
    echo "• GitHub: https://github.com/officialerictm/leonardo-ai"
    echo "• Wiki: https://github.com/officialerictm/leonardo-ai/wiki"
    echo "• Issues: https://github.com/officialerictm/leonardo-ai/issues"
    
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Show system information with enhanced details
handle_info_command() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}               📋 System Information                ${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    
    # Leonardo Information
    echo -e "\n${BOLD}Leonardo AI Universal:${COLOR_RESET}"
    echo "├─ Version: v7.0.0"
    echo "├─ Build Date: $(date -r "$0" 2>/dev/null || echo "Unknown")"
    echo "├─ Script Path: $(realpath "$0" 2>/dev/null || echo "$0")"
    echo "└─ PID: $$"
    
    # Deployment Information
    echo -e "\n${BOLD}Deployment:${COLOR_RESET}"
    if is_usb_deployment; then
        echo "├─ Mode: USB Drive (Portable)"
        echo "├─ USB Mount: ${LEONARDO_USB_MOUNT:-Unknown}"
        echo "└─ USB Free: $(df -h "${LEONARDO_USB_MOUNT}" 2>/dev/null | awk 'NR==2 {print $4}' || echo "Unknown")"
    else
        echo "├─ Mode: Host System"
        echo "└─ Base Dir: ${LEONARDO_BASE_DIR}"
    fi
    
    # System Information
    echo -e "\n${BOLD}Host System:${COLOR_RESET}"
    echo "├─ OS: $(uname -s) $(uname -r)"
    echo "├─ Architecture: $(uname -m)"
    echo "├─ Hostname: $(hostname 2>/dev/null || echo "Unknown")"
    echo "├─ User: ${USER}"
    echo "└─ Shell: ${SHELL} (${BASH_VERSION})"
    
    # Hardware Information
    echo -e "\n${BOLD}Hardware:${COLOR_RESET}"
    echo "├─ CPU Model: $(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs || echo "Unknown")"
    echo "├─ CPU Cores: $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")"
    echo "├─ Total RAM: $(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "Unknown")"
    echo "├─ Available RAM: $(free -h 2>/dev/null | awk '/^Mem:/ {print $7}' || echo "Unknown")"
    
    # GPU Detection
    if command -v nvidia-smi >/dev/null 2>&1; then
        local gpu_info=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null | head -1)
        echo "└─ GPU: ${gpu_info:-NVIDIA GPU detected}"
    elif command -v rocm-smi >/dev/null 2>&1; then
        echo "└─ GPU: AMD GPU detected (ROCm)"
    elif [[ -d /sys/class/drm/card0 ]]; then
        echo "└─ GPU: Integrated graphics detected"
    else
        echo "└─ GPU: No dedicated GPU detected"
    fi
    
    # Software Dependencies
    echo -e "\n${BOLD}Dependencies:${COLOR_RESET}"
    echo -n "├─ Python: "
    if command -v python3 >/dev/null 2>&1; then
        echo "$(python3 --version 2>&1 | awk '{print $2}')"
    else
        echo "${RED}Not installed${COLOR_RESET}"
    fi
    
    echo -n "├─ Ollama: "
    if command -v ollama >/dev/null 2>&1; then
        echo "${GREEN}Installed${COLOR_RESET} ($(ollama -v 2>&1 | head -1))"
    else
        echo "${YELLOW}Not installed${COLOR_RESET}"
    fi
    
    echo -n "├─ Git: "
    if command -v git >/dev/null 2>&1; then
        echo "$(git --version | awk '{print $3}')"
    else
        echo "${YELLOW}Not installed${COLOR_RESET}"
    fi
    
    echo -n "└─ Curl: "
    if command -v curl >/dev/null 2>&1; then
        echo "$(curl --version | head -1 | awk '{print $2}')"
    else
        echo "${RED}Not installed${COLOR_RESET}"
    fi
    
    # Environment Variables
    echo -e "\n${BOLD}Environment:${COLOR_RESET}"
    echo "├─ LEONARDO_BASE_DIR: ${LEONARDO_BASE_DIR:-Not set}"
    echo "├─ LEONARDO_MODELS_DIR: ${LEONARDO_MODELS_DIR:-Not set}"
    echo "├─ LEONARDO_CONFIG_DIR: ${LEONARDO_CONFIG_DIR:-Not set}"
    echo "├─ LEONARDO_LOG_LEVEL: ${LEONARDO_LOG_LEVEL:-INFO}"
    echo "└─ TERM: ${TERM:-Not set}"
    
    # Run basic system tests
    echo -e "\n${BOLD}Quick System Check:${COLOR_RESET}"
    echo -n "├─ Internet: "
    if check_internet_connection; then
        echo "${GREEN}✓ Connected${COLOR_RESET}"
    else
        echo "${RED}✗ Offline${COLOR_RESET}"
    fi
    
    echo -n "├─ Disk Space: "
    local free_space=$(df -h . 2>/dev/null | awk 'NR==2 {print $4}')
    if [[ -n "$free_space" ]]; then
        echo "$free_space available"
    else
        echo "Unknown"
    fi
    
    echo -n "└─ Write Permission: "
    if touch .leonardo_test 2>/dev/null && rm .leonardo_test 2>/dev/null; then
        echo "${GREEN}✓ Writable${COLOR_RESET}"
    else
        echo "${RED}✗ Read-only${COLOR_RESET}"
    fi
    
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# ==============================================================================
# MENU HANDLER FUNCTIONS
# ==============================================================================

# Handle system management menu
handle_system_menu() {
    echo -e "\n${CYAN}🔧 System Management${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    local options=(
        "🔍 Run System Tests"
        "⚙️  Configure Leonardo"
        "🔐 Security Settings"
        "📊 Performance Tuning"
        "🔄 Update Leonardo"
        "🔙 Back to Main Menu"
    )
    
    while true; do
        echo ""
        for i in "${!options[@]}"; do
            echo "$((i+1)). ${options[$i]}"
        done
        echo ""
        echo -n "Select option: "
        read -r choice
        
        case "$choice" in
            1) run_system_tests ;;
            2) configure_leonardo ;;
            3) configure_security ;;
            4) configure_performance ;;
            5) update_leonardo ;;
            6) break ;;
            *) echo -e "${RED}Invalid choice${COLOR_RESET}" ;;
        esac
    done
}

# Handle model management menu
handle_model_menu() {
    echo -e "\n${CYAN}📦 Model Management${COLOR_RESET}"
    
    # Use the model manager CLI
    if command -v handle_model_command >/dev/null 2>&1; then
        handle_model_command
    else
        echo -e "${RED}Model manager not available${COLOR_RESET}"
        echo "Please ensure model management modules are properly installed."
        echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
        read -r
    fi
}

# Handle USB management interactive menu
handle_usb_menu() {
    echo -e "\n${CYAN}💾 USB Management${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    local options=(
        "📋 List USB Drives"
        "🚀 Deploy Leonardo to USB"
        "💿 Format USB Drive"
        "🏥 Check USB Health"
        "📊 Monitor USB Performance"
        "💾 Backup USB Data"
        "🔙 Back to Main Menu"
    )
    
    while true; do
        echo ""
        for i in "${!options[@]}"; do
            echo "$((i+1)). ${options[$i]}"
        done
        echo ""
        echo -n "Select option: "
        read -r choice
        
        case "$choice" in
            1) 
                if command -v usb_cli >/dev/null 2>&1; then
                    usb_cli list
                else
                    echo -e "${RED}USB CLI not available${COLOR_RESET}"
                fi
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            2) 
                # USB deployment - prompt for device
                echo -e "\n${CYAN}Select USB device for deployment:${COLOR_RESET}"
                if command -v usb_cli >/dev/null 2>&1; then
                    usb_cli list
                    echo ""
                    echo -n "Enter device path (e.g., /dev/sdc): "
                    read -r device
                    if [[ -n "$device" ]]; then
                        handle_deployment_command "usb" "$device"
                    else
                        echo -e "${RED}No device selected${COLOR_RESET}"
                    fi
                else
                    echo -e "${RED}USB CLI not available${COLOR_RESET}"
                fi
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            3) 
                if command -v usb_cli >/dev/null 2>&1; then
                    echo "Select USB drive to format:"
                    usb_cli format
                else
                    echo -e "${RED}USB CLI not available${COLOR_RESET}"
                fi
                ;;
            4) 
                if command -v usb_cli >/dev/null 2>&1; then
                    usb_cli health
                else
                    echo -e "${RED}USB CLI not available${COLOR_RESET}"
                fi
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            5) 
                if command -v usb_cli >/dev/null 2>&1; then
                    usb_cli monitor
                else
                    echo -e "${RED}USB CLI not available${COLOR_RESET}"
                fi
                ;;
            6) 
                if command -v usb_cli >/dev/null 2>&1; then
                    usb_cli backup
                else
                    echo -e "${RED}USB CLI not available${COLOR_RESET}"
                fi
                ;;
            7) break ;;
            *) echo -e "${RED}Invalid choice${COLOR_RESET}" ;;
        esac
    done
}

# Handle deployment menu
handle_deployment_menu() {
    echo -e "\n${CYAN}🚀 Deployment Options${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    local options=(
        "💾 Deploy to USB Drive"
        "💻 Local Installation"
        "🐳 Container Deployment"
        "☁️  Cloud Deployment"
        "🔒 Air-Gap Setup"
        "🔙 Back to Main Menu"
    )
    
    while true; do
        echo ""
        for i in "${!options[@]}"; do
            echo "$((i+1)). ${options[$i]}"
        done
        echo ""
        echo -n "Select deployment option: "
        read -r choice
        
        case "$choice" in
            1) 
                # USB deployment - prompt for device
                echo -e "\n${CYAN}Select USB device for deployment:${COLOR_RESET}"
                if command -v usb_cli >/dev/null 2>&1; then
                    usb_cli list
                    echo ""
                    echo -n "Enter device path (e.g., /dev/sdc): "
                    read -r device
                    if [[ -n "$device" ]]; then
                        handle_deployment_command "usb" "$device"
                    else
                        echo -e "${RED}No device selected${COLOR_RESET}"
                    fi
                else
                    echo -e "${RED}USB CLI not available${COLOR_RESET}"
                fi
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            2) handle_local_deployment ;;
            3) handle_container_deployment ;;
            4) handle_cloud_deployment ;;
            5) handle_airgap_deployment ;;
            6) break ;;
            *) echo -e "${RED}Invalid choice${COLOR_RESET}" ;;
        esac
    done
}

# Configure Leonardo settings
configure_leonardo() {
    echo -e "\n${CYAN}⚙️  Leonardo Configuration${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    # Show current configuration
    echo -e "\n${BOLD}Current Configuration:${COLOR_RESET}"
    echo "Base Directory: ${LEONARDO_BASE_DIR:-Not set}"
    echo "Model Directory: ${LEONARDO_MODELS_DIR:-Not set}"
    echo "Config Directory: ${LEONARDO_CONFIG_DIR:-Not set}"
    echo "Log Level: ${LEONARDO_LOG_LEVEL:-INFO}"
    
    echo -e "\n${YELLOW}Configuration options coming soon...${COLOR_RESET}"
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Configure security settings
configure_security() {
    echo -e "\n${CYAN}🔐 Security Settings${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    echo "1. Enable encryption at rest"
    echo "2. Configure access control"
    echo "3. Set up audit logging"
    echo "4. Enable stealth mode"
    echo "5. Back to System Menu"
    
    echo -e "\n${YELLOW}Security features coming soon...${COLOR_RESET}"
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Configure performance settings
configure_performance() {
    echo -e "\n${CYAN}📊 Performance Tuning${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    # Show current system resources
    echo -e "\n${BOLD}System Resources:${COLOR_RESET}"
    echo "CPU Cores: $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "Unknown")"
    echo "Total RAM: $(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo "Unknown")"
    
    if command -v nvidia-smi >/dev/null 2>&1; then
        echo "GPU: NVIDIA GPU detected"
    else
        echo "GPU: No NVIDIA GPU detected"
    fi
    
    echo -e "\n${YELLOW}Performance tuning options coming soon...${COLOR_RESET}"
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Update Leonardo
update_leonardo() {
    echo -e "\n${CYAN}🔄 Updating Leonardo${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    echo "Checking for updates..."
    
    # Check if we're in a git repository
    if [[ -d .git ]]; then
        echo "Pulling latest changes from git..."
        git pull origin main 2>/dev/null || {
            echo -e "${YELLOW}Could not update from git${COLOR_RESET}"
        }
    else
        echo -e "${YELLOW}Not in a git repository${COLOR_RESET}"
        echo "Please download the latest version from GitHub"
    fi
    
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Handle local deployment
handle_local_deployment() {
    echo -e "\n${CYAN}💻 Local Installation${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    echo -e "${YELLOW}⚠️  Warning: Local installation defeats the portable nature of Leonardo${COLOR_RESET}"
    echo ""
    echo "Leonardo is designed to run from USB for maximum portability and security."
    echo "Local installation is only recommended for development or permanent workstations."
    echo ""
    echo -n "Continue with local installation? (y/N): "
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "\n${YELLOW}Local installation feature coming soon...${COLOR_RESET}"
    fi
    
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Handle container deployment
handle_container_deployment() {
    echo -e "\n${CYAN}🐳 Container Deployment${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    echo "Checking for container runtimes..."
    
    if command -v docker >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Docker detected${COLOR_RESET}"
    elif command -v podman >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Podman detected${COLOR_RESET}"
    else
        echo -e "${RED}✗ No container runtime found${COLOR_RESET}"
        echo "Please install Docker or Podman to use container deployment"
    fi
    
    echo -e "\n${YELLOW}Container deployment coming soon...${COLOR_RESET}"
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Handle cloud deployment
handle_cloud_deployment() {
    echo -e "\n${CYAN}☁️  Cloud Deployment${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    echo "Supported cloud platforms:"
    echo "• Amazon Web Services (AWS)"
    echo "• Google Cloud Platform (GCP)"
    echo "• Microsoft Azure"
    echo "• DigitalOcean"
    echo ""
    echo -e "${YELLOW}Cloud deployment templates coming soon...${COLOR_RESET}"
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Handle air-gap deployment
handle_airgap_deployment() {
    echo -e "\n${CYAN}🔒 Air-Gap Setup${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    echo "Air-gap deployment creates a completely offline AI environment."
    echo ""
    echo "Features:"
    echo "• No internet connectivity required"
    echo "• Pre-downloaded models and dependencies"
    echo "• Enhanced security for sensitive environments"
    echo "• Compliance with strict security policies"
    echo ""
    echo -e "${YELLOW}Air-gap deployment coming soon...${COLOR_RESET}"
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Handle dashboard command
handle_dashboard_command() {
    log_message "INFO" "Showing dashboard"
    
    # Display comprehensive system dashboard
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}               📊 Leonardo AI Dashboard                ${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    
    # System Overview
    echo -e "\n${BOLD}System Overview:${COLOR_RESET}"
    echo "├─ Leonardo Version: v7.0.0"
    echo "├─ Deployment Mode: $(is_usb_deployment && echo "USB Drive" || echo "Host System")"
    echo "├─ Base Directory: ${LEONARDO_BASE_DIR}"
    echo "└─ Uptime: $(uptime -p 2>/dev/null || echo "N/A")"
    
    # Hardware Resources
    echo -e "\n${BOLD}Hardware Resources:${COLOR_RESET}"
    echo "├─ CPU: $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "Unknown") cores"
    echo "├─ RAM: $(free -h 2>/dev/null | awk '/^Mem:/ {print $2 " total, " $3 " used"}' || echo "Unknown")"
    if command -v nvidia-smi >/dev/null 2>&1; then
        local gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)
        echo "├─ GPU: ${gpu_name:-NVIDIA GPU detected}"
    else
        echo "├─ GPU: No NVIDIA GPU detected"
    fi
    echo "└─ Storage: $(df -h "${LEONARDO_BASE_DIR}" 2>/dev/null | awk 'NR==2 {print $4}' || echo "Unknown")"
    
    # Model Status
    echo -e "\n${BOLD}Model Status:${COLOR_RESET}"
    local model_count=0
    if [[ -d "${LEONARDO_MODELS_DIR}" ]]; then
        model_count=$(find "${LEONARDO_MODELS_DIR}" -name "*.gguf" 2>/dev/null | wc -l)
    fi
    echo "├─ Local GGUF Models: ${model_count}"
    if command -v ollama >/dev/null 2>&1; then
        echo "├─ Ollama Status: ${GREEN}✓ Installed${COLOR_RESET}"
        local ollama_models=$(ollama list 2>/dev/null | tail -n +2 | wc -l)
        echo "└─ Ollama Models: ${ollama_models:-0}"
    else
        echo "└─ Ollama Status: ${YELLOW}⚠ Not installed${COLOR_RESET}"
    fi
    
    # Network Status
    echo -e "\n${BOLD}Network Status:${COLOR_RESET}"
    if check_internet_connection; then
        echo "├─ Internet: ${GREEN}✓ Connected${COLOR_RESET}"
        echo "└─ Model Downloads: Available"
    else
        echo "├─ Internet: ${RED}✗ Offline${COLOR_RESET}"
        echo "└─ Model Downloads: Unavailable"
    fi
    
    # Quick Actions
    echo -e "\n${BOLD}Quick Actions:${COLOR_RESET}"
    echo "1. Start Chat → Main Menu → Option 3"
    echo "2. Download Models → Main Menu → Option 2"
    echo "3. USB Setup → Main Menu → Option 4"
    
    if show_dashboard 2>/dev/null; then
        # Extended dashboard from dashboard.sh if available
        :
    fi
    
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Handle web interface command
handle_web_command() {
    log_message "INFO" "Starting web interface"
    
    echo -e "\n${CYAN}🌐 Leonardo Web Interface${COLOR_RESET}"
    echo "════════════════════════════════════════════"
    
    # Check if web server module is available
    if command -v start_web_server >/dev/null 2>&1; then
        echo "Starting web server..."
        
        # Set default port
        local port="${LEONARDO_WEB_PORT:-8080}"
        
        echo -e "\n${BOLD}Web Interface will be available at:${COLOR_RESET}"
        echo "• Local: http://localhost:${port}"
        
        # Get local IP addresses
        if command -v ip >/dev/null 2>&1; then
            local ips=$(ip addr show | grep -Eo 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '127.0.0.1' | awk '{print $2}')
            if [[ -n "$ips" ]]; then
                echo "• Network:"
                while IFS= read -r ip; do
                    echo "  - http://${ip}:${port}"
                done <<< "$ips"
            fi
        fi
        
        echo -e "\n${YELLOW}Press Ctrl+C to stop the web server${COLOR_RESET}"
        echo ""
        
        # Start the web server
        start_web_server
    else
        echo -e "${YELLOW}Web interface module not available${COLOR_RESET}"
        echo ""
        echo "The web interface provides:"
        echo "• Browser-based chat interface"
        echo "• Model management dashboard"
        echo "• System monitoring"
        echo "• Remote access capabilities"
        echo ""
        echo -e "${DIM}Coming soon in future updates...${COLOR_RESET}"
        echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
        read -r
    fi
}
