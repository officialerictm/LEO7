#!/usr/bin/env bash

# System Status Module - Track where services are running
# Part of Leonardo AI Universal

# Ensure color variables are defined
: "${GREEN:=\033[32m}"
: "${CYAN:=\033[36m}"
: "${YELLOW:=\033[33m}"
: "${RED:=\033[31m}"
: "${DIM:=\033[2m}"
: "${COLOR_RESET:=\033[0m}"

# Detect Ollama location (host vs USB)
detect_ollama_location() {
    local location="none"
    local ollama_pid=""
    local ollama_path=""
    
    # Check if Ollama is running
    if command -v pgrep >/dev/null 2>&1; then
        ollama_pid=$(pgrep -f "ollama serve" 2>/dev/null | head -1)
    fi
    
    if [[ -n "$ollama_pid" ]]; then
        # Get the path of the running Ollama process
        if command -v pwdx >/dev/null 2>&1; then
            ollama_path=$(pwdx "$ollama_pid" 2>/dev/null | cut -d: -f2- | xargs)
        elif [[ -e "/proc/$ollama_pid/cwd" ]]; then
            ollama_path=$(readlink "/proc/$ollama_pid/cwd" 2>/dev/null)
        fi
        
        # Check if running from USB
        if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ "$ollama_path" =~ "$LEONARDO_USB_MOUNT" ]]; then
            location="USB"
        elif [[ -n "$ollama_path" ]]; then
            location="Host"
        else
            # Fallback: check if standard Ollama is responding
            if ollama list >/dev/null 2>&1; then
                location="Host"
            fi
        fi
    else
        # Ollama not running, check if it's available
        if command -v ollama >/dev/null 2>&1; then
            # Check if it's the USB version
            local ollama_bin=$(which ollama)
            if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ "$ollama_bin" =~ "$LEONARDO_USB_MOUNT" ]]; then
                location="USB (not running)"
            else
                location="Host (not running)"
            fi
        fi
    fi
    
    echo "$location"
}

# Detect Leonardo location (where the script is running from)
detect_leonardo_location() {
    local script_path="${BASH_SOURCE[0]}"
    local real_path=$(readlink -f "$script_path" 2>/dev/null || realpath "$script_path" 2>/dev/null)
    
    if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ "$real_path" =~ "$LEONARDO_USB_MOUNT" ]]; then
        echo "USB"
    else
        echo "Host"
    fi
}

# Get Ollama endpoint based on location preference
get_ollama_endpoint() {
    local preference="${1:-auto}"  # auto, host, usb
    local host_endpoint="http://localhost:11434"
    local usb_endpoint="http://localhost:11435"  # Different port for USB instance
    
    case "$preference" in
        host)
            echo "$host_endpoint"
            ;;
        usb)
            echo "$usb_endpoint"
            ;;
        auto)
            # Check which one is available
            if curl -s "$usb_endpoint/api/tags" >/dev/null 2>&1; then
                echo "$usb_endpoint"
            elif curl -s "$host_endpoint/api/tags" >/dev/null 2>&1; then
                echo "$host_endpoint"
            else
                echo "$host_endpoint"  # Default
            fi
            ;;
    esac
}

# Format system status for display
format_system_status() {
    local ollama_loc=$(detect_ollama_location)
    local leonardo_loc=$(detect_leonardo_location)
    local status=""
    
    # Ollama status with color
    case "$ollama_loc" in
        Host)
            status="${GREEN}Ollama: Host${COLOR_RESET}"
            ;;
        USB)
            status="${CYAN}Ollama: USB${COLOR_RESET}"
            ;;
        "Host (not running)")
            status="${YELLOW}Ollama: Host (offline)${COLOR_RESET}"
            ;;
        "USB (not running)")
            status="${YELLOW}Ollama: USB (offline)${COLOR_RESET}"
            ;;
        none)
            status="${RED}Ollama: Not found${COLOR_RESET}"
            ;;
    esac
    
    # Add Leonardo location
    if [[ "$leonardo_loc" == "USB" ]]; then
        status="$status | ${CYAN}Leonardo: USB${COLOR_RESET}"
    else
        status="$status | ${GREEN}Leonardo: Host${COLOR_RESET}"
    fi
    
    echo -e "$status"
}

# Get location prefix for chat prompt
get_chat_location_prefix() {
    local ollama_endpoint="${1:-}"
    local model="${2:-unknown}"
    local location="Host"
    
    if [[ "$ollama_endpoint" =~ ":11435" ]]; then
        location="USB"
    fi
    
    echo "[${location}:${model}]"
}

# Export functions
export -f detect_ollama_location
export -f detect_leonardo_location
export -f get_ollama_endpoint
export -f format_system_status
export -f get_chat_location_prefix
