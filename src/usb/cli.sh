#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - USB CLI Module
# ==============================================================================
# Description: Command-line interface for USB operations
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, detector.sh, manager.sh, health.sh
# ==============================================================================

# USB CLI help
usb_cli_help() {
    cat << EOF
${COLOR_CYAN}Leonardo USB Management${COLOR_RESET}

Usage:
  leonardo usb <command> [options]

Commands:
  list              List available USB drives
  info <device>     Show USB drive information
  init <device>     Initialize USB drive for Leonardo
  install [device]  Install Leonardo to USB drive
  format <device>   Format USB drive
  mount <device>    Mount USB drive
  unmount <device>  Unmount USB drive
  health [device]   Check USB drive health
  monitor [device]  Monitor USB health continuously
  backup [device]   Backup Leonardo data from USB
  restore <file>    Restore Leonardo data to USB
  clean [device]    Clean temporary files on USB
  test [device]     Test USB drive performance

Options:
  -f, --format <fs>   File system type (exfat, fat32, ntfs, ext4)
  -l, --label <name>  Volume label
  -b, --backup <file> Backup file path
  -i, --interval <s>  Monitoring interval in seconds

Examples:
  leonardo usb list
  leonardo usb init /dev/sdb
  leonardo usb install
  leonardo usb health /dev/sdb
  leonardo usb format /dev/sdb --format exfat --label LEONARDO
  leonardo usb backup --backup ~/leonardo_backup.tar.gz
  leonardo usb monitor --interval 60

Quick Start:
  leonardo usb list        # Find your USB drive
  leonardo usb init <dev>  # Initialize for Leonardo
  leonardo usb install     # Install Leonardo to USB

EOF
}

# USB CLI main handler
usb_cli() {
    local command="${1:-help}"
    shift
    
    case "$command" in
        "list")
            usb_cli_list "$@"
            ;;
        "info")
            usb_cli_info "$@"
            ;;
        "init")
            usb_cli_init "$@"
            ;;
        "install")
            usb_cli_install "$@"
            ;;
        "format")
            usb_cli_format "$@"
            ;;
        "mount")
            usb_cli_mount "$@"
            ;;
        "unmount"|"umount")
            usb_cli_unmount "$@"
            ;;
        "health")
            usb_cli_health "$@"
            ;;
        "monitor")
            usb_cli_monitor "$@"
            ;;
        "backup")
            usb_cli_backup "$@"
            ;;
        "restore")
            usb_cli_restore "$@"
            ;;
        "clean")
            usb_cli_clean "$@"
            ;;
        "test")
            usb_cli_test "$@"
            ;;
        "help"|"--help"|"-h")
            usb_cli_help
            ;;
        *)
            echo -e "${COLOR_RED}Unknown command: $command${COLOR_RESET}"
            echo "Use 'leonardo usb help' for usage information"
            return 1
            ;;
    esac
}

# List USB drives
usb_cli_list() {
    local format="table"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --json)
                format="json"
                shift
                ;;
            --simple)
                format="simple"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    list_usb_drives "$format"
}

# Show USB info
usb_cli_info() {
    local device="$1"
    
    if [[ -z "$device" ]]; then
        echo -e "${COLOR_RED}Error: No device specified${COLOR_RESET}"
        echo "Usage: leonardo usb info <device>"
        return 1
    fi
    
    if ! is_usb_device "$device"; then
        echo -e "${COLOR_RED}Error: Not a USB device: $device${COLOR_RESET}"
        return 1
    fi
    
    echo ""
    get_usb_drive_info "$device"
    echo ""
    echo "USB Speed: $(get_usb_speed "$device")"
    
    # Check if Leonardo is installed
    local mount_point
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            mount_point=$(diskutil info "$device" 2>/dev/null | grep "Mount Point:" | cut -d: -f2- | xargs)
            if [[ -z "$mount_point" || "$mount_point" =~ [Nn]ot\ mounted ]]; then
                local part="$device"
                [[ ! "$device" =~ s[0-9]+$ ]] && part="${device}s1"
                mount_point=$(diskutil info "$part" 2>/dev/null | grep "Mount Point:" | cut -d: -f2- | xargs)
            fi
            ;;
        "linux")
            mount_point=$(lsblk -no MOUNTPOINT "$device" 2>/dev/null | head -1)
            ;;
        "windows")
            mount_point="$device\\"
            ;;
    esac
    
    if [[ -n "$mount_point" ]] && [[ -f "$mount_point/leonardo.sh" ]]; then
        echo ""
        echo -e "${COLOR_GREEN}Leonardo Status: Installed${COLOR_RESET}"
        if [[ -f "$mount_point/leonardo/VERSION" ]]; then
            echo "Leonardo Version: $(cat "$mount_point/leonardo/VERSION")"
        fi
    else
        echo ""
        echo -e "${COLOR_YELLOW}Leonardo Status: Not Installed${COLOR_RESET}"
    fi
}

# Initialize USB for Leonardo
usb_cli_init() {
    local device="$1"
    
    if [[ -z "$device" ]]; then
        echo -e "${COLOR_RED}Error: No device specified${COLOR_RESET}"
        echo "Usage: leonardo usb init <device>"
        return 1
    fi
    
    # Initialize device
    if ! init_usb_device "$device"; then
        return 1
    fi
    
    # Check if already has Leonardo structure
    if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ -d "$LEONARDO_USB_MOUNT/leonardo" ]]; then
        echo -e "${COLOR_YELLOW}Leonardo structure already exists on USB${COLOR_RESET}"
        if ! confirm_action "Reinitialize USB"; then
            return 0
        fi
    fi
    
    # Create Leonardo structure
    if ! create_leonardo_structure; then
        return 1
    fi
    
    echo ""
    echo -e "${COLOR_GREEN}USB drive initialized for Leonardo!${COLOR_RESET}"
    echo "Next step: leonardo usb install"
}

# Install Leonardo to USB
usb_cli_install() {
    local device="$1"
    local leonardo_script="./leonardo.sh"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --script)
                leonardo_script="$2"
                shift 2
                ;;
            *)
                device="$1"
                shift
                ;;
        esac
    done
    
    # Auto-detect if no device specified
    if [[ -z "$device" ]]; then
        echo -e "${COLOR_CYAN}Auto-detecting USB device...${COLOR_RESET}"
        device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
        
        if [[ -z "$device" ]]; then
            echo -e "${COLOR_RED}No USB device detected${COLOR_RESET}"
            return 1
        fi
        
        echo "Found: $device"
        if ! confirm_action "Use this device"; then
            return 1
        fi
    fi
    
    # Check if Leonardo script exists
    if [[ ! -f "$leonardo_script" ]]; then
        echo -e "${COLOR_RED}Leonardo script not found: $leonardo_script${COLOR_RESET}"
        return 1
    fi
    
    # Initialize device
    if ! init_usb_device "$device"; then
        return 1
    fi
    
    # Install Leonardo
    install_leonardo_to_usb "$LEONARDO_USB_MOUNT" "$leonardo_script"
}

# Format USB drive
usb_cli_format() {
    local device=""
    local filesystem="exfat"
    local label="LEONARDO"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--format)
                filesystem="$2"
                shift 2
                ;;
            -l|--label)
                label="$2"
                shift 2
                ;;
            *)
                device="$1"
                shift
                ;;
        esac
    done
    
    if [[ -z "$device" ]]; then
        echo -e "${COLOR_RED}Error: No device specified${COLOR_RESET}"
        echo "Usage: leonardo usb format <device> [--format <fs>] [--label <name>]"
        return 1
    fi
    
    # Validate filesystem
    case "$filesystem" in
        exfat|fat32|ntfs|ext4)
            ;;
        *)
            echo -e "${COLOR_RED}Error: Unsupported filesystem: $filesystem${COLOR_RESET}"
            echo "Supported: exfat, fat32, ntfs, ext4"
            return 1
            ;;
    esac
    
    format_usb_drive "$device" "$filesystem" "$label"
}

# Mount USB drive
usb_cli_mount() {
    local device="$1"
    local mount_point="$2"
    
    if [[ -z "$device" ]]; then
        echo -e "${COLOR_RED}Error: No device specified${COLOR_RESET}"
        echo "Usage: leonardo usb mount <device> [mount_point]"
        return 1
    fi
    
    mount_usb_drive "$device" "$mount_point"
}

# Unmount USB drive
usb_cli_unmount() {
    local device="$1"
    
    if [[ -z "$device" ]]; then
        echo -e "${COLOR_RED}Error: No device specified${COLOR_RESET}"
        echo "Usage: leonardo usb unmount <device>"
        return 1
    fi
    
    unmount_usb_drive "$device"
}

# Check USB health
usb_cli_health() {
    local device="$1"
    local report=false
    local output_file=""
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --report)
                report=true
                output_file="${2:-}"
                shift
                [[ -n "$output_file" ]] && shift
                ;;
            *)
                device="$1"
                shift
                ;;
        esac
    done
    
    # Auto-detect if no device specified
    if [[ -z "$device" ]]; then
        if [[ -n "$LEONARDO_USB_DEVICE" ]]; then
            device="$LEONARDO_USB_DEVICE"
        else
            device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
            if [[ -z "$device" ]]; then
                echo -e "${COLOR_RED}No USB device detected${COLOR_RESET}"
                return 1
            fi
        fi
    fi
    
    # Initialize device
    init_usb_device "$device" >/dev/null 2>&1
    
    # Initialize health monitoring
    init_usb_health
    
    if [[ "$report" == "true" ]]; then
        generate_health_report "$output_file" "$device"
    else
        perform_health_check "$device"
    fi
}

# Monitor USB health
usb_cli_monitor() {
    local device=""
    local interval=300
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -i|--interval)
                interval="$2"
                shift 2
                ;;
            --stop)
                stop_health_monitoring
                return 0
                ;;
            *)
                device="$1"
                shift
                ;;
        esac
    done
    
    # Auto-detect if no device specified
    if [[ -z "$device" ]]; then
        if [[ -n "$LEONARDO_USB_DEVICE" ]]; then
            device="$LEONARDO_USB_DEVICE"
        else
            device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
            if [[ -z "$device" ]]; then
                echo -e "${COLOR_RED}No USB device detected${COLOR_RESET}"
                return 1
            fi
        fi
    fi
    
    # Initialize device
    init_usb_device "$device" >/dev/null 2>&1
    
    # Initialize health monitoring
    init_usb_health
    
    # Start monitoring
    monitor_usb_health "$interval" "$device"
}

# Backup USB data
usb_cli_backup() {
    local device=""
    local backup_file=""
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -b|--backup)
                backup_file="$2"
                shift 2
                ;;
            *)
                device="$1"
                shift
                ;;
        esac
    done
    
    # Auto-detect if no device specified
    if [[ -z "$device" ]]; then
        if [[ -n "$LEONARDO_USB_DEVICE" ]]; then
            device="$LEONARDO_USB_DEVICE"
        else
            device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
            if [[ -z "$device" ]]; then
                echo -e "${COLOR_RED}No USB device detected${COLOR_RESET}"
                return 1
            fi
        fi
    fi
    
    # Initialize device
    if ! init_usb_device "$device"; then
        return 1
    fi
    
    # Check if Leonardo exists
    if [[ ! -d "$LEONARDO_USB_MOUNT/leonardo" ]]; then
        echo -e "${COLOR_RED}Leonardo not found on USB device${COLOR_RESET}"
        return 1
    fi
    
    backup_usb_data "$LEONARDO_USB_MOUNT" "$backup_file"
}

# Restore USB data
usb_cli_restore() {
    local backup_file="$1"
    local device="$2"
    
    if [[ -z "$backup_file" ]]; then
        echo -e "${COLOR_RED}Error: No backup file specified${COLOR_RESET}"
        echo "Usage: leonardo usb restore <backup_file> [device]"
        return 1
    fi
    
    if [[ ! -f "$backup_file" ]]; then
        echo -e "${COLOR_RED}Error: Backup file not found: $backup_file${COLOR_RESET}"
        return 1
    fi
    
    # Auto-detect if no device specified
    if [[ -z "$device" ]]; then
        if [[ -n "$LEONARDO_USB_DEVICE" ]]; then
            device="$LEONARDO_USB_DEVICE"
        else
            device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
            if [[ -z "$device" ]]; then
                echo -e "${COLOR_RED}No USB device detected${COLOR_RESET}"
                return 1
            fi
            
            echo "Found: $device"
            if ! confirm_action "Restore to this device"; then
                return 1
            fi
        fi
    fi
    
    # Initialize device
    if ! init_usb_device "$device"; then
        return 1
    fi
    
    restore_usb_data "$LEONARDO_USB_MOUNT" "$backup_file"
}

# Clean USB temp files
usb_cli_clean() {
    local device="$1"
    
    # Auto-detect if no device specified
    if [[ -z "$device" ]]; then
        if [[ -n "$LEONARDO_USB_DEVICE" ]]; then
            device="$LEONARDO_USB_DEVICE"
        else
            device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
            if [[ -z "$device" ]]; then
                echo -e "${COLOR_RED}No USB device detected${COLOR_RESET}"
                return 1
            fi
        fi
    fi
    
    # Initialize device
    if ! init_usb_device "$device"; then
        return 1
    fi
    
    # Check if Leonardo exists
    if [[ ! -d "$LEONARDO_USB_MOUNT/leonardo" ]]; then
        echo -e "${COLOR_RED}Leonardo not found on USB device${COLOR_RESET}"
        return 1
    fi
    
    # Show current usage
    echo "Current disk usage:"
    du -sh "$LEONARDO_USB_MOUNT/leonardo"/* 2>/dev/null | sort -h
    echo ""
    
    if confirm_action "Clean temporary files"; then
        clean_usb_temp "$LEONARDO_USB_MOUNT"
        
        # Show new usage
        echo ""
        echo "Disk usage after cleanup:"
        du -sh "$LEONARDO_USB_MOUNT/leonardo"/* 2>/dev/null | sort -h
    fi
}

# Test USB performance
usb_cli_test() {
    local device="$1"
    
    # Auto-detect if no device specified
    if [[ -z "$device" ]]; then
        if [[ -n "$LEONARDO_USB_DEVICE" ]]; then
            device="$LEONARDO_USB_DEVICE"
        else
            device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
            if [[ -z "$device" ]]; then
                echo -e "${COLOR_RED}No USB device detected${COLOR_RESET}"
                return 1
            fi
        fi
    fi
    
    # Initialize device
    if ! init_usb_device "$device"; then
        return 1
    fi
    
    echo -e "${COLOR_CYAN}USB Performance Test${COLOR_RESET}"
    echo "===================="
    echo "Device: $device"
    echo "Mount: $LEONARDO_USB_MOUNT"
    echo ""
    
    # Test write speed
    test_usb_write_speed "$device"
    
    # Additional performance metrics
    echo ""
    echo "USB Interface: $(get_usb_speed "$device")"
    
    # Check free space
    if check_usb_free_space "$LEONARDO_USB_MOUNT" 100; then
        echo "Free Space: $LEONARDO_USB_FREE"
    fi
    
    # Quick health check
    echo ""
    echo "Quick Health Check:"
    local temp=$(check_usb_temperature "$device")
    echo "  Temperature: $temp"
    echo "  Write Cycles: $(estimate_write_cycles)"
}

# Register USB commands
register_usb_commands() {
    # This function is called during Leonardo initialization
    # to register USB commands with the main command handler
    log_message "INFO" "USB commands registered"
}

# Main USB command handler
handle_usb_command() {
    local subcommand="${1:-help}"
    shift || true
    
    case "$subcommand" in
        list)
            usb_cli_list "$@"
            ;;
        info)
            usb_cli_info "$@"
            ;;
        init|initialize)
            usb_cli_init "$@"
            ;;
        install)
            usb_cli_install "$@"
            ;;
        format)
            usb_cli_format "$@"
            ;;
        mount)
            usb_cli_mount "$@"
            ;;
        unmount|umount)
            usb_cli_unmount "$@"
            ;;
        health)
            usb_cli_health "$@"
            ;;
        monitor)
            usb_cli_monitor "$@"
            ;;
        backup)
            usb_cli_backup "$@"
            ;;
        restore)
            usb_cli_restore "$@"
            ;;
        clean)
            usb_cli_clean "$@"
            ;;
        test)
            usb_cli_test "$@"
            ;;
        help|--help|-h)
            usb_cli_help
            ;;
        *)
            echo -e "${COLOR_RED}Unknown USB command: $subcommand${COLOR_RESET}"
            echo "Run 'leonardo usb help' for available commands"
            return 1
            ;;
    esac
}

# Export functions
export -f handle_usb_command
export -f usb_cli usb_cli_help
export -f usb_cli_list usb_cli_info usb_cli_init usb_cli_install
export -f usb_cli_format usb_cli_mount usb_cli_unmount
export -f usb_cli_health usb_cli_monitor usb_cli_backup usb_cli_restore
export -f usb_cli_clean usb_cli_test register_usb_commands
