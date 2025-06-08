#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Deployment Mode Selection
# ==============================================================================
# Description: Functions for selecting and configuring deployment mode
# Dependencies: ui/menus.sh, utils/filesystem.sh
# ==============================================================================

# Select deployment mode
select_deployment_mode() {
    clear
    echo -e "${CYAN}${LEONARDO_BANNERS[0]}${COLOR_RESET}"
    echo
    echo -e "${YELLOW}=== AI on a Stick - Deployment Mode ===${COLOR_RESET}"
    echo
    echo "How would you like Leonardo to operate?"
    echo
    echo -e "${GREEN}1) Standard USB Mode (Recommended)${COLOR_RESET}"
    echo "   • All AI models stored on USB drive"
    echo "   • Can leverage host GPU via Ollama if available"
    echo "   • Best balance of portability and performance"
    echo "   • Leaves minimal trace on host"
    echo
    echo -e "${BLUE}2) Stealth USB Mode${COLOR_RESET}"
    echo "   • Completely isolated to USB drive"
    echo "   • Ignores all host resources"
    echo "   • Maximum privacy and security"
    echo "   • Zero trace on host system"
    echo
    echo -e "${DIM}3) Legacy Host Mode${COLOR_RESET}"
    echo "   ${DIM}• Traditional installation (not recommended)"
    echo "   • Installs on host computer"
    echo "   • Not portable${COLOR_RESET}"
    echo
    
    local mode=""
    while [[ -z "$mode" ]]; do
        echo -n "Select mode (1-3) [1]: "
        read -r choice
        
        # Default to USB mode if just Enter pressed
        [[ -z "$choice" ]] && choice="1"
        
        case "$choice" in
            1)
                mode="usb"
                echo -e "${GREEN}✓ Standard USB Mode selected${COLOR_RESET}"
                ;;
            2)
                mode="usb-only" 
                echo -e "${BLUE}✓ Stealth USB Mode selected${COLOR_RESET}"
                ;;
            3)
                echo -e "${YELLOW}Warning: Host mode defeats the purpose of 'AI on a Stick'${COLOR_RESET}"
                echo -n "Are you sure? (y/N): "
                read -r confirm
                if [[ "${confirm,,}" == "y" ]]; then
                    mode="host"
                    echo -e "${DIM}✓ Legacy Host Mode selected${COLOR_RESET}"
                fi
                ;;
            *)
                echo -e "${RED}Invalid choice. Please select 1, 2, or 3.${COLOR_RESET}"
                ;;
        esac
    done
    
    echo "$mode"
}

# Configure deployment based on mode
configure_deployment() {
    local mode="$1"
    
    case "$mode" in
        usb)
            export LEONARDO_USB_MODE="true"
            export LEONARDO_USB_ONLY="false"
            export LEONARDO_DEPLOYMENT_MODE="usb"
            echo -e "${GREEN}Configured for USB deployment with host access${COLOR_RESET}"
            ;;
        usb-only)
            export LEONARDO_USB_MODE="true"
            export LEONARDO_USB_ONLY="true"
            export LEONARDO_DEPLOYMENT_MODE="usb-only"
            echo -e "${BLUE}Configured for USB-only deployment${COLOR_RESET}"
            ;;
        host)
            export LEONARDO_USB_MODE="false"
            export LEONARDO_USB_ONLY="false"
            export LEONARDO_DEPLOYMENT_MODE="host"
            echo -e "${PURPLE}Configured for host deployment${COLOR_RESET}"
            ;;
        *)
            echo -e "${RED}Unknown deployment mode: $mode${COLOR_RESET}"
            return 1
            ;;
    esac
    
    # Save configuration
    save_deployment_config "$mode"
}

# Save deployment configuration
save_deployment_config() {
    local mode="$1"
    local config_file="${LEONARDO_CONFIG_DIR}/deployment.conf"
    
    ensure_directory "$(dirname "$config_file")"
    
    cat > "$config_file" <<EOF
# Leonardo Deployment Configuration
# Generated: $(date)
LEONARDO_DEPLOYMENT_MODE="$mode"
LEONARDO_USB_MODE="${LEONARDO_USB_MODE}"
LEONARDO_USB_ONLY="${LEONARDO_USB_ONLY}"
EOF
    
    echo -e "${DIM}Configuration saved to: $config_file${COLOR_RESET}"
}

# Load deployment configuration
load_deployment_config() {
    local config_file="${LEONARDO_CONFIG_DIR}/deployment.conf"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        return 0
    fi
    
    return 1
}

# Check if deployment mode is configured
is_deployment_configured() {
    [[ -n "${LEONARDO_DEPLOYMENT_MODE:-}" ]]
}

# Get deployment mode description
get_deployment_mode_desc() {
    local mode="${LEONARDO_DEPLOYMENT_MODE:-unknown}"
    
    case "$mode" in
        usb)
            echo "USB Mode (with host access)"
            ;;
        usb-only)
            echo "USB-Only Mode (isolated)"
            ;;
        host)
            echo "Host Mode (traditional)"
            ;;
        *)
            echo "Not configured"
            ;;
    esac
}

# Export functions
export -f select_deployment_mode configure_deployment load_deployment_config
export -f is_deployment_configured get_deployment_mode_desc save_deployment_config
