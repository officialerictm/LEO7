#!/usr/bin/env bash

# Minimal Leonardo test - directly show menu after banner

# Get the leonardo.sh file and extract just what we need
source ./leonardo.sh --no-main 2>/dev/null || true

# Override main to skip initialization
main() {
    # Show banner
    clear
    show_banner
    echo
    
    echo "DEBUG: About to show menu..."
    
    # Directly show menu
    while true; do
        local options=(
            "AI Model Management"
            "Create/Manage USB Drive"
            "System Dashboard"
            "Launch Web Interface"
            "Settings & Preferences"
            "Run System Tests"
            "About Leonardo"
            "Exit"
        )
        
        local selected=$(show_menu "Main Menu" "${options[@]}")
        
        if [[ "$selected" == "Exit" ]]; then
            echo "Exiting..."
            exit 0
        fi
        
        echo "You selected: $selected"
        sleep 2
    done
}

# Run main
main "$@"
