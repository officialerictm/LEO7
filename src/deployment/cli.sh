#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Deployment CLI Module
# ==============================================================================
# Description: Command-line interface for deployment operations
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, usb_deploy.sh, local_deploy.sh
# ==============================================================================

# Main deployment CLI handler
deployment_cli() {
    local command="${1:-help}"
    shift
    
    case "$command" in
        "usb")
            deployment_usb_command "$@"
            ;;
        "local")
            deployment_local_command "$@"
            ;;
        "status")
            deployment_status_command "$@"
            ;;
        "verify")
            deployment_verify_command "$@"
            ;;
        "help"|"-h"|"--help")
            show_deployment_help
            ;;
        *)
            echo "${COLOR_RED}Unknown deployment command: $command${COLOR_RESET}"
            echo ""
            show_deployment_help
            return 1
            ;;
    esac
}

# USB deployment command handler
deployment_usb_command() {
    local device="${1:-}"
    local options="${2:-}"
    
    echo "${COLOR_CYAN}╭─────────────────────────────────────╮${COLOR_RESET}"
    echo "${COLOR_CYAN}│     Leonardo USB Deployment         │${COLOR_RESET}"
    echo "${COLOR_CYAN}╰─────────────────────────────────────╯${COLOR_RESET}"
    echo ""
    
    # Check if running from USB already
    if [[ "${LEONARDO_DEPLOYMENT_TYPE:-}" == "usb" ]]; then
        echo "${COLOR_YELLOW}Warning: Already running from USB${COLOR_RESET}"
        echo "Cannot deploy to USB while running from USB."
        return 1
    fi
    
    # Deploy to USB
    deploy_to_usb "$device" "$options"
}

# Local deployment command handler
deployment_local_command() {
    local install_path="${1:-}"
    local options="${2:-}"
    
    echo "${COLOR_CYAN}╭─────────────────────────────────────╮${COLOR_RESET}"
    echo "${COLOR_CYAN}│    Leonardo Local Installation      │${COLOR_RESET}"
    echo "${COLOR_CYAN}╰─────────────────────────────────────╯${COLOR_RESET}"
    echo ""
    
    # Check if already installed
    if command -v leonardo >/dev/null 2>&1; then
        local existing_path=$(which leonardo | xargs readlink -f | xargs dirname)
        echo "${COLOR_YELLOW}Leonardo is already installed${COLOR_RESET}"
        echo "Location: $existing_path"
        echo ""
    fi
    
    # Deploy locally
    deploy_to_local "$install_path" "$options"
}

# Deployment status command
deployment_status_command() {
    local target="${1:-all}"
    
    echo "${COLOR_CYAN}Leonardo Deployment Status${COLOR_RESET}"
    echo "========================="
    echo ""
    
    # Check current deployment
    echo "Current Deployment Status:"
    echo "${COLOR_YELLOW}─────────────────────────${COLOR_RESET}"
    
    if [[ -n "${LEONARDO_DEPLOYMENT_TYPE:-}" ]]; then
        echo "Type: ${LEONARDO_DEPLOYMENT_TYPE:-}"
        echo "Base: ${LEONARDO_BASE_DIR:-unknown}"
        echo "Version: ${LEONARDO_VERSION:-}"
    else
        echo "Running in development mode"
    fi
    echo ""
    
    # Check local installation
    if [[ "$target" == "all" ]] || [[ "$target" == "local" ]]; then
        echo "${COLOR_YELLOW}Local Installation:${COLOR_RESET}"
        
        if command -v leonardo >/dev/null 2>&1; then
            local leonardo_path=$(which leonardo)
            local install_dir=$(readlink -f "$leonardo_path" | xargs dirname | xargs dirname)
            
            echo "✓ Installed at: $install_dir"
            
            if [[ -f "$install_dir/VERSION" ]]; then
                echo "  Version: $(cat "$install_dir/VERSION")"
            fi
            
            # Count models
            if [[ -d "$install_dir/models" ]]; then
                local model_count=$(find "$install_dir/models" -name "*.gguf" 2>/dev/null | wc -l)
                echo "  Models: $model_count installed"
            fi
        else
            echo "✗ Not installed"
        fi
        echo ""
    fi
    
    # Check USB deployments
    if [[ "$target" == "all" ]] || [[ "$target" == "usb" ]]; then
        echo "${COLOR_YELLOW}USB Deployments:${COLOR_RESET}"
        
        local usb_found=false
        local devices=$(detect_usb_drives 2>/dev/null)
        
        if [[ -n "$devices" ]]; then
            while IFS='|' read -r device label size fs; do
                # Check if Leonardo is on this USB
                local mount_point=$(get_mount_point "$device" 2>/dev/null)
                
                if [[ -n "$mount_point" ]] && [[ -f "$mount_point/leonardo.sh" ]]; then
                    usb_found=true
                    echo "✓ $device - $label ($size)"
                    
                    if [[ -f "$mount_point/leonardo/VERSION" ]]; then
                        echo "  Version: $(cat "$mount_point/leonardo/VERSION")"
                    fi
                fi
            done <<< "$devices"
        fi
        
        if [[ "$usb_found" == "false" ]]; then
            echo "✗ No Leonardo USB drives detected"
        fi
        echo ""
    fi
}

# Deployment verification command
deployment_verify_command() {
    local target="${1:-current}"
    
    echo "${COLOR_CYAN}Deployment Verification${COLOR_RESET}"
    echo "======================"
    echo ""
    
    case "$target" in
        "current")
            # Verify current deployment
            if [[ -n "${LEONARDO_BASE_DIR:-}" ]]; then
                echo "Verifying: ${LEONARDO_BASE_DIR:-}"
                echo ""
                
                if [[ "${LEONARDO_DEPLOYMENT_TYPE:-}" == "usb" ]]; then
                    verify_usb_deployment
                else
                    verify_local_deployment "${LEONARDO_BASE_DIR:-}"
                fi
            else
                echo "No active deployment to verify"
            fi
            ;;
        "local")
            # Verify local installation
            if command -v leonardo >/dev/null 2>&1; then
                local install_dir=$(which leonardo | xargs readlink -f | xargs dirname | xargs dirname)
                verify_local_deployment "$install_dir"
            else
                echo "No local installation found"
            fi
            ;;
        "usb")
            # Verify USB deployment
            local device="${2:-}"
            if [[ -z "$device" ]]; then
                echo "Please specify USB device"
                return 1
            fi
            
            init_usb_device "$device" >/dev/null 2>&1
            verify_usb_deployment
            ;;
        *)
            echo "Unknown target: $target"
            echo "Valid targets: current, local, usb"
            ;;
    esac
}

# Show deployment help
show_deployment_help() {
    cat << EOF
${COLOR_CYAN}Leonardo Deployment Commands${COLOR_RESET}

Usage: leonardo deploy <command> [options]

Commands:
  ${COLOR_GREEN}usb [device] [options]${COLOR_RESET}
    Deploy Leonardo to a USB drive
    Options:
      format      - Format USB before deployment
      no-models   - Skip model installation
      autorun     - Create autorun files
    
  ${COLOR_GREEN}local [path] [options]${COLOR_RESET}
    Install Leonardo on local system
    Default path: \$HOME/.leonardo
    Options:
      auto        - Use defaults without prompts
      no-models   - Skip model installation
      no-shell    - Don't update shell config
    
  ${COLOR_GREEN}status [target]${COLOR_RESET}
    Check deployment status
    Targets: all, local, usb (default: all)
    
  ${COLOR_GREEN}verify [target] [device]${COLOR_RESET}
    Verify deployment integrity
    Targets: current, local, usb

Examples:
  leonardo deploy usb                # Interactive USB deployment
  leonardo deploy usb /dev/sdb format # Format and deploy to specific USB
  leonardo deploy local              # Install locally with defaults
  leonardo deploy local ~/leonardo   # Install to custom location
  leonardo deploy status             # Check all deployments
  leonardo deploy verify local       # Verify local installation

Quick Deploy:
  leonardo deploy usb --quick        # Auto-detect and deploy to USB
  leonardo deploy local --quick      # Quick local installation

EOF
}

# Export deployment functions
export -f deployment_cli deployment_usb_command deployment_local_command
export -f deployment_status_command deployment_verify_command
