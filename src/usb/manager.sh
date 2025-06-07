#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - USB Management Module
# ==============================================================================
# Description: Manage USB drive lifecycle and operations
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh, validation.sh, detector.sh
# ==============================================================================

# USB manager state
declare -g LEONARDO_USB_DEVICE=""
declare -g LEONARDO_USB_MOUNT=""
declare -g LEONARDO_USB_SIZE=""
declare -g LEONARDO_USB_FREE=""
declare -g LEONARDO_USB_FREE_MB=""

# Initialize USB device
init_usb_device() {
    local device="${1:-}"
    
    if [[ -z "$device" ]]; then
        # Auto-detect USB device
        log_message "INFO" "Auto-detecting USB device..."
        
        local detected_device
        detected_device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
        
        if [[ -z "$detected_device" ]]; then
            log_message "ERROR" "No USB device detected"
            return 1
        fi
        
        device="$detected_device"
    fi
    
    # Validate device
    if ! is_usb_device "$device"; then
        log_message "ERROR" "Not a USB device: $device"
        return 1
    fi
    
    # Set global variables
    export LEONARDO_USB_DEVICE="$device"
    
    # Get mount point
    local platform=$(detect_platform)
    case "$platform" in
        "macos")
            LEONARDO_USB_MOUNT=$(diskutil info "$device" 2>/dev/null | grep "Mount Point:" | cut -d: -f2- | xargs)
            ;;
        "linux")
            # Try the device first
            LEONARDO_USB_MOUNT=$(lsblk -no MOUNTPOINT "$device" 2>/dev/null | grep -v "^$" | head -1)
            # If no mount point and device is like /dev/sdX, try first partition
            if [[ -z "$LEONARDO_USB_MOUNT" ]] && [[ "$device" =~ ^/dev/sd[a-z]$ ]]; then
                LEONARDO_USB_MOUNT=$(lsblk -no MOUNTPOINT "${device}1" 2>/dev/null | grep -v "^$" | head -1)
            fi
            ;;
        "windows")
            LEONARDO_USB_MOUNT="$device\\"
            ;;
    esac
    
    # Export the mount point so it's available to subshells
    export LEONARDO_USB_MOUNT
    
    log_message "INFO" "Initialized USB device: $LEONARDO_USB_DEVICE"
    [[ -n "$LEONARDO_USB_MOUNT" ]] && log_message "INFO" "Mount point: $LEONARDO_USB_MOUNT"
    
    return 0
}

# Format USB drive
format_usb_drive() {
    local device="${1:-$LEONARDO_USB_DEVICE}"
    local filesystem="${2:-exfat}"
    local label="${3:-LEONARDO}"
    
    if [[ -z "$device" ]]; then
        log_message "ERROR" "No device specified"
        return 1
    fi
    
    # Confirm formatting
    echo -e "${COLOR_YELLOW}WARNING: This will erase all data on $device${COLOR_RESET}"
    if ! confirm_action "Format USB drive"; then
        return 1
    fi
    
    local platform=$(detect_platform)
    
    show_progress "Formatting USB drive..."
    
    case "$platform" in
        "macos")
            if diskutil eraseDisk "$filesystem" "$label" "$device" >/dev/null 2>&1; then
                log_message "SUCCESS" "USB drive formatted successfully"
                return 0
            fi
            ;;
        "linux")
            # Unmount if mounted
            if mount | grep -q "^$device"; then
                umount "$device" 2>/dev/null
            fi
            
            # Create partition table
            if command_exists "parted"; then
                parted -s "$device" mklabel gpt >/dev/null 2>&1
                parted -s "$device" mkpart primary 0% 100% >/dev/null 2>&1
                parted -s "$device" set 1 msftdata on >/dev/null 2>&1
                if command_exists "partprobe"; then
                    partprobe "$device" >/dev/null 2>&1
                fi
            else
                log_message "ERROR" "parted is required to format USB drives"
                return 1
            fi
            
            # Wait a moment for partition to be ready
            sleep 1
            
            # Format partition
            local partition="${device}1"
            [[ -b "${device}p1" ]] && partition="${device}p1"
            
            case "$filesystem" in
                "exfat")
                    if command_exists "mkfs.exfat"; then
                        if ! mkfs.exfat -n "$label" "$partition"; then
                            echo -e "${RED}Failed to format USB drive as exFAT${COLOR_RESET}"
                            echo -e "${YELLOW}Error: mkfs.exfat failed${COLOR_RESET}"
                            return 1
                        fi
                    else
                        echo -e "${YELLOW}mkfs.exfat not found.${COLOR_RESET}"
                        if confirm_action "Install exfat-utils now?"; then
                            echo -e "${CYAN}Installing exfat-utils...${COLOR_RESET}"
                            local install_cmd=""
                            
                            # Detect package manager
                            if command_exists "apt-get"; then
                                install_cmd="sudo apt-get update && sudo apt-get install -y exfat-utils exfat-fuse"
                            elif command_exists "yum"; then
                                install_cmd="sudo yum install -y exfat-utils fuse-exfat"
                            elif command_exists "dnf"; then
                                install_cmd="sudo dnf install -y exfat-utils fuse-exfat"
                            elif command_exists "pacman"; then
                                install_cmd="sudo pacman -S --noconfirm exfat-utils"
                            elif command_exists "zypper"; then
                                install_cmd="sudo zypper install -y exfat-utils"
                            else
                                echo -e "${RED}Unable to detect package manager${COLOR_RESET}"
                                echo -e "${YELLOW}Please install exfat-utils manually${COLOR_RESET}"
                                return 1
                            fi
                            
                            echo -e "${DIM}Running: $install_cmd${COLOR_RESET}"
                            if eval "$install_cmd"; then
                                echo -e "${GREEN}✓ exfat-utils installed successfully${COLOR_RESET}"
                                # Try formatting again
                                if ! mkfs.exfat -n "$label" "$partition"; then
                                    echo -e "${RED}Format still failed after installation${COLOR_RESET}"
                                    return 1
                                fi
                            else
                                echo -e "${RED}Failed to install exfat-utils${COLOR_RESET}"
                                return 1
                            fi
                        else
                            echo -e "${YELLOW}Please install manually: sudo apt-get install exfat-utils exfat-fuse${COLOR_RESET}"
                            return 1
                        fi
                    fi
                    ;;
                "fat32")
                    if command_exists "mkfs.vfat"; then
                        mkfs.vfat -F 32 -n "$label" "$partition" >/dev/null 2>&1
                    else
                        echo -e "${YELLOW}mkfs.vfat not found.${COLOR_RESET}"
                        if confirm_action "Install dosfstools now?"; then
                            echo -e "${CYAN}Installing dosfstools...${COLOR_RESET}"
                            local install_cmd=""
                            
                            # Detect package manager
                            if command_exists "apt-get"; then
                                install_cmd="sudo apt-get update && sudo apt-get install -y dosfstools"
                            elif command_exists "yum"; then
                                install_cmd="sudo yum install -y dosfstools"
                            elif command_exists "dnf"; then
                                install_cmd="sudo dnf install -y dosfstools"
                            elif command_exists "pacman"; then
                                install_cmd="sudo pacman -S --noconfirm dosfstools"
                            elif command_exists "zypper"; then
                                install_cmd="sudo zypper install -y dosfstools"
                            else
                                echo -e "${RED}Unable to detect package manager${COLOR_RESET}"
                                return 1
                            fi
                            
                            echo -e "${DIM}Running: $install_cmd${COLOR_RESET}"
                            if eval "$install_cmd"; then
                                echo -e "${GREEN}✓ dosfstools installed successfully${COLOR_RESET}"
                                # Try formatting again
                                mkfs.vfat -F 32 -n "$label" "$partition" >/dev/null 2>&1
                            else
                                echo -e "${RED}Failed to install dosfstools${COLOR_RESET}"
                                return 1
                            fi
                        else
                            echo -e "${YELLOW}Please install manually: sudo apt-get install dosfstools${COLOR_RESET}"
                            return 1
                        fi
                    fi
                    ;;
                "ntfs")
                    if command_exists "mkfs.ntfs"; then
                        mkfs.ntfs -f -L "$label" "$partition" >/dev/null 2>&1
                    else
                        echo -e "${YELLOW}mkfs.ntfs not found.${COLOR_RESET}"
                        if confirm_action "Install ntfs-3g now?"; then
                            echo -e "${CYAN}Installing ntfs-3g...${COLOR_RESET}"
                            local install_cmd=""
                            
                            # Detect package manager
                            if command_exists "apt-get"; then
                                install_cmd="sudo apt-get update && sudo apt-get install -y ntfs-3g"
                            elif command_exists "yum"; then
                                install_cmd="sudo yum install -y ntfs-3g"
                            elif command_exists "dnf"; then
                                install_cmd="sudo dnf install -y ntfs-3g"
                            elif command_exists "pacman"; then
                                install_cmd="sudo pacman -S --noconfirm ntfs-3g"
                            elif command_exists "zypper"; then
                                install_cmd="sudo zypper install -y ntfs-3g"
                            else
                                echo -e "${RED}Unable to detect package manager${COLOR_RESET}"
                                return 1
                            fi
                            
                            echo -e "${DIM}Running: $install_cmd${COLOR_RESET}"
                            if eval "$install_cmd"; then
                                echo -e "${GREEN}✓ ntfs-3g installed successfully${COLOR_RESET}"
                                # Try formatting again
                                mkfs.ntfs -f -L "$label" "$partition" >/dev/null 2>&1
                            else
                                echo -e "${RED}Failed to install ntfs-3g${COLOR_RESET}"
                                return 1
                            fi
                        else
                            echo -e "${YELLOW}Please install manually: sudo apt-get install ntfs-3g${COLOR_RESET}"
                            return 1
                        fi
                    fi
                    ;;
                "ext4")
                    if command_exists "mkfs.ext4"; then
                        mkfs.ext4 -L "$label" "$partition" >/dev/null 2>&1
                    else
                        echo -e "${RED}mkfs.ext4 not found${COLOR_RESET}"
                        return 1
                    fi
                    ;;
            esac
            
            if [[ $? -eq 0 ]]; then
                log_message "SUCCESS" "USB drive formatted successfully"
                return 0
            fi
            ;;
        "windows")
            # Use diskpart
            if command_exists "diskpart"; then
                local script="select disk $device
clean
create partition primary
format fs=$filesystem label=$label quick
assign"
                echo "$script" | diskpart >/dev/null 2>&1
                
                if [[ $? -eq 0 ]]; then
                    log_message "SUCCESS" "USB drive formatted successfully"
                    return 0
                fi
            fi
            ;;
    esac
    
    log_message "ERROR" "Failed to format USB drive"
    return 1
}

# Mount USB drive
mount_usb_drive() {
    local device="${1:-$LEONARDO_USB_DEVICE}"
    local mount_point="${2:-}"
    
    if [[ -z "$device" ]]; then
        log_message "ERROR" "No device specified"
        return 1
    fi
    
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            # macOS auto-mounts, but we can force it
            if ! diskutil mount "$device" >/dev/null 2>&1; then
                log_message "ERROR" "Failed to mount device"
                return 1
            fi
            
            # Get actual mount point
            LEONARDO_USB_MOUNT=$(diskutil info "$device" 2>/dev/null | grep "Mount Point:" | cut -d: -f2- | xargs)
            export LEONARDO_USB_MOUNT
            ;;
        "linux")
            # Create mount point if not specified
            if [[ -z "$mount_point" ]]; then
                # Use a temporary mount point
                mount_point="/tmp/leonardo_mount_$(basename "$device")"
                mkdir -p "$mount_point" 2>/dev/null || {
                    # Try with sudo
                    echo -e "${YELLOW}Creating mount point requires root privileges${COLOR_RESET}"
                    sudo mkdir -p "$mount_point" || {
                        log_message "ERROR" "Cannot create mount point"
                        return 1
                    }
                }
            fi
            
            # Try different mount methods
            if mount "$device" "$mount_point" 2>/dev/null; then
                LEONARDO_USB_MOUNT="$mount_point"
                export LEONARDO_USB_MOUNT
            elif command -v udisksctl >/dev/null 2>&1; then
                # Try udisksctl for user mounting
                log_message "INFO" "Trying udisksctl mount..."
                echo -e "${DIM}Attempting to mount using udisksctl...${COLOR_RESET}"
                local mount_output=$(udisksctl mount -b "$device" 2>&1)
                if [[ $? -eq 0 ]]; then
                    # Extract mount point from output
                    LEONARDO_USB_MOUNT=$(echo "$mount_output" | grep -oP "Mounted .* at \K[^.]*" | tail -1)
                    if [[ -z "$LEONARDO_USB_MOUNT" ]]; then
                        # Alternative parsing for different udisksctl versions
                        LEONARDO_USB_MOUNT=$(echo "$mount_output" | sed -n 's/.*at \(.*\)\.$/\1/p' | tail -1)
                    fi
                    export LEONARDO_USB_MOUNT
                    log_message "INFO" "Mounted via udisksctl at: $LEONARDO_USB_MOUNT"
                    echo -e "${GREEN}✓ Mounted at: $LEONARDO_USB_MOUNT${COLOR_RESET}"
                    # Clean up our temporary mount point since udisksctl created its own
                    rmdir "$mount_point" 2>/dev/null || true
                else
                    echo -e "${RED}Failed to mount using udisksctl${COLOR_RESET}"
                    echo -e "${YELLOW}Error: $mount_output${COLOR_RESET}"
                    return 1
                fi
            else
                # No udisksctl, try sudo directly
                echo -e "${YELLOW}Mounting requires root privileges${COLOR_RESET}"
                echo -e "${BLUE}Please enter your password when prompted:${COLOR_RESET}"
                if sudo mount "$device" "$mount_point"; then
                    LEONARDO_USB_MOUNT="$mount_point"
                    export LEONARDO_USB_MOUNT
                    log_message "INFO" "Mounted with sudo at: $LEONARDO_USB_MOUNT"
                else
                    log_message "ERROR" "Failed to mount device"
                    rmdir "$mount_point" 2>/dev/null || true
                    return 1
                fi
            fi
            ;;
        "windows")
            # Windows auto-mounts with drive letters
            LEONARDO_USB_MOUNT="$device\\"
            export LEONARDO_USB_MOUNT
            ;;
    esac
    
    log_message "INFO" "USB drive mounted at: $LEONARDO_USB_MOUNT"
    return 0
}

# Unmount USB drive
unmount_usb_drive() {
    local device="${1:-$LEONARDO_USB_DEVICE}"
    
    if [[ -z "$device" ]]; then
        log_message "ERROR" "No device specified"
        return 1
    fi
    
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            if diskutil unmount "$device" >/dev/null 2>&1; then
                log_message "INFO" "USB drive unmounted"
                return 0
            fi
            ;;
        "linux")
            if umount "$device" 2>/dev/null || umount "$LEONARDO_USB_MOUNT" 2>/dev/null; then
                # Clean up mount point if it's our temporary one
                [[ "$LEONARDO_USB_MOUNT" =~ ^/tmp/leonardo_mount_ ]] && rmdir "$LEONARDO_USB_MOUNT" 2>/dev/null
                log_message "INFO" "USB drive unmounted"
                return 0
            fi
            ;;
        "windows")
            # Windows doesn't have a simple unmount command
            log_message "WARN" "Please use 'Safely Remove Hardware' for Windows"
            return 0
            ;;
    esac
    
    log_message "ERROR" "Failed to unmount USB drive"
    return 1
}

# Create Leonardo USB structure
create_leonardo_structure() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    
    if [[ -z "$mount_point" ]] || [[ ! -d "$mount_point" ]]; then
        log_message "ERROR" "Invalid mount point: $mount_point"
        return 1
    fi
    
    log_message "INFO" "Creating Leonardo directory structure..."
    
    # Create directory structure
    local dirs=(
        "leonardo"
        "leonardo/models"
        "leonardo/cache"
        "leonardo/config"
        "leonardo/logs"
        "leonardo/backups"
        "leonardo/scripts"
        "leonardo/data"
        "leonardo/temp"
    )
    
    for dir in "${dirs[@]}"; do
        if ! mkdir -p "$mount_point/$dir"; then
            log_message "ERROR" "Failed to create directory: $dir"
            return 1
        fi
    done
    
    # Create README
    cat > "$mount_point/leonardo/README.md" << 'EOF'
# Leonardo AI Universal

This USB drive contains Leonardo AI Universal - a portable AI deployment system.

## Directory Structure

- `models/` - AI model files
- `cache/` - Model cache and temporary files
- `config/` - Configuration files
- `logs/` - System logs
- `backups/` - Backup files
- `scripts/` - Utility scripts
- `data/` - User data
- `temp/` - Temporary files

## Usage

Run Leonardo from the USB drive root:
```bash
./leonardo.sh
```

## Security

This system is designed to leave no trace on the host computer.
All data remains on the USB drive.

## Support

Visit: https://github.com/officialerictm/LEO7
EOF
    
    # Create version file
    echo "7.0.0" > "$mount_point/leonardo/VERSION"
    
    # Create config file
    cat > "$mount_point/leonardo/config/leonardo.conf" << EOF
# Leonardo AI Universal Configuration
LEONARDO_VERSION="7.0.0"
LEONARDO_USB_PATH="$mount_point/leonardo"
LEONARDO_MODEL_DIR="$mount_point/leonardo/models"
LEONARDO_CACHE_DIR="$mount_point/leonardo/cache"
LEONARDO_LOG_DIR="$mount_point/leonardo/logs"
LEONARDO_PARANOID_MODE="true"
EOF
    
    log_message "SUCCESS" "Leonardo structure created successfully"
    return 0
}

# Install Leonardo to USB
install_leonardo_to_usb() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    local leonardo_script="${2:-./leonardo.sh}"
    
    if [[ -z "$mount_point" ]] || [[ ! -d "$mount_point" ]]; then
        log_message "ERROR" "Invalid mount point: $mount_point"
        return 1
    fi
    
    if [[ ! -f "$leonardo_script" ]]; then
        log_message "ERROR" "Leonardo script not found: $leonardo_script"
        return 1
    fi
    
    # Create structure first
    if ! create_leonardo_structure "$mount_point"; then
        return 1
    fi
    
    log_message "INFO" "Installing Leonardo to USB..."
    
    show_progress "Copying Leonardo executable..."
    
    # Copy Leonardo executable
    if cp "$leonardo_script" "$mount_point/leonardo.sh"; then
        chmod +x "$mount_point/leonardo.sh" 2>/dev/null || true
        
        # Create platform-specific launchers
        create_usb_launchers "$mount_point"
        
        log_message "SUCCESS" "Leonardo installed to USB successfully"
        
        # Show summary
        echo ""
        echo -e "${COLOR_GREEN}Installation complete!${COLOR_RESET}"
        echo ""
        echo "USB Drive: $LEONARDO_USB_DEVICE"
        echo "Mount Point: $mount_point"
        echo ""
        echo "To run Leonardo from USB:"
        echo "  ${COLOR_CYAN}cd $mount_point${COLOR_RESET}"
        echo "  ${COLOR_CYAN}./leonardo.sh${COLOR_RESET}"
        echo ""
        
        return 0
    else
        log_message "ERROR" "Failed to copy Leonardo to USB"
        return 1
    fi
}

# Create platform-specific launchers
create_usb_launchers() {
    local mount_point="$1"
    
    # Windows batch launcher
    cat > "$mount_point/leonardo.bat" << 'EOF'
@echo off
echo Leonardo AI Universal
echo.

REM Check if running from USB
if not exist "%~dp0leonardo.sh" (
    echo Error: leonardo.sh not found
    pause
    exit /b 1
)

REM Try to run with Git Bash
if exist "%PROGRAMFILES%\Git\bin\bash.exe" (
    "%PROGRAMFILES%\Git\bin\bash.exe" "%~dp0leonardo.sh" %*
) else if exist "%PROGRAMFILES(x86)%\Git\bin\bash.exe" (
    "%PROGRAMFILES(x86)%\Git\bin\bash.exe" "%~dp0leonardo.sh" %*
) else if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" (
    "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" "%~dp0leonardo.sh" %*
) else (
    echo Error: Git Bash not found. Please install Git for Windows.
    echo Download from: https://git-scm.com/download/win
    pause
    exit /b 1
)
EOF
    
    # macOS/Linux launcher script
    cat > "$mount_point/launch-leonardo.sh" << 'EOF'
#!/usr/bin/env bash
# Leonardo AI Universal Launcher

# Get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if leonardo.sh exists
if [[ ! -f "$DIR/leonardo.sh" ]]; then
    echo "Error: leonardo.sh not found"
    exit 1
fi

# Launch Leonardo
cd "$DIR"
exec ./leonardo.sh "$@"
EOF
    chmod +x "$mount_point/launch-leonardo.sh" 2>/dev/null || true
    
    # Create .desktop file for Linux
    cat > "$mount_point/leonardo.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Leonardo AI Universal
Comment=Portable AI Deployment System
Exec=$mount_point/launch-leonardo.sh
Icon=$mount_point/leonardo/icon.png
Terminal=true
Categories=Development;Science;
EOF
    chmod +x "$mount_point/leonardo.desktop" 2>/dev/null || true
}

# Backup USB Leonardo data
backup_usb_data() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    local backup_path="${2:-./leonardo_backup_$(date +%Y%m%d_%H%M%S).tar.gz}"
    
    if [[ -z "$mount_point" ]] || [[ ! -d "$mount_point/leonardo" ]]; then
        log_message "ERROR" "Leonardo not found on USB"
        return 1
    fi
    
    log_message "INFO" "Backing up Leonardo data..."
    
    show_progress "Creating backup..."
    
    # Create backup
    if tar -czf "$backup_path" -C "$mount_point" leonardo 2>/dev/null; then
        local backup_size=$(get_file_size "$backup_path")
        log_message "SUCCESS" "Backup created: $backup_path ($(format_bytes $backup_size))"
        return 0
    else
        log_message "ERROR" "Backup failed"
        rm -f "$backup_path"
        return 1
    fi
}

# Restore USB Leonardo data
restore_usb_data() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    local backup_path="$2"
    
    if [[ -z "$backup_path" ]] || [[ ! -f "$backup_path" ]]; then
        log_message "ERROR" "Backup file not found: $backup_path"
        return 1
    fi
    
    if [[ -z "$mount_point" ]] || [[ ! -d "$mount_point" ]]; then
        log_message "ERROR" "Invalid mount point: $mount_point"
        return 1
    fi
    
    # Confirm restore
    if [[ -d "$mount_point/leonardo" ]]; then
        echo -e "${COLOR_YELLOW}WARNING: This will overwrite existing Leonardo data${COLOR_RESET}"
        if ! confirm_action "Restore Leonardo data"; then
            return 1
        fi
    fi
    
    log_message "INFO" "Restoring Leonardo data..."
    
    show_progress "Extracting backup..."
    
    # Extract backup
    if tar -xzf "$backup_path" -C "$mount_point" 2>/dev/null; then
        log_message "SUCCESS" "Leonardo data restored successfully"
        return 0
    else
        log_message "ERROR" "Restore failed"
        return 1
    fi
}

# Check USB free space
check_usb_free_space() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    local required_mb="${2:-1000}"  # Default 1GB
    
    if [[ -z "$mount_point" ]] || [[ ! -d "$mount_point" ]]; then
        log_message "ERROR" "Invalid mount point: $mount_point"
        return 1
    fi
    
    local free_kb
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos"|"linux")
            free_kb=$(df -k "$mount_point" | tail -1 | awk '{print $4}')
            ;;
        "windows")
            if command_exists "wmic"; then
                local device="${mount_point%\\}"
                free_kb=$(wmic logicaldisk where "DeviceID='$device'" get FreeSpace /value | grep -oE '[0-9]+' | head -1)
                free_kb=$((free_kb / 1024))
            fi
            ;;
    esac
    
    local free_mb=$((free_kb / 1024))
    
    if [[ $free_mb -lt $required_mb ]]; then
        log_message "WARN" "Insufficient free space: ${free_mb}MB available, ${required_mb}MB required"
        return 1
    fi
    
    LEONARDO_USB_FREE="${free_mb}MB"
    LEONARDO_USB_FREE_MB=$free_mb
    return 0
}

# Clean USB temporary files
clean_usb_temp() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    
    if [[ -z "$mount_point" ]] || [[ ! -d "$mount_point/leonardo/temp" ]]; then
        log_message "WARN" "Temp directory not found"
        return 1
    fi
    
    log_message "INFO" "Cleaning temporary files..."
    
    # Remove old temp files (older than 7 days)
    find "$mount_point/leonardo/temp" -type f -mtime +7 -delete 2>/dev/null
    
    # Remove empty directories
    find "$mount_point/leonardo/temp" -type d -empty -delete 2>/dev/null
    
    # Clean cache if needed
    local cache_size=$(du -sm "$mount_point/leonardo/cache" 2>/dev/null | cut -f1)
    if [[ $cache_size -gt 1000 ]]; then  # More than 1GB
        log_message "INFO" "Cleaning old cache files..."
        find "$mount_point/leonardo/cache" -type f -mtime +30 -delete 2>/dev/null
    fi
    
    log_message "SUCCESS" "Cleanup complete"
    return 0
}

# Export USB manager functions
export -f init_usb_device format_usb_drive mount_usb_drive unmount_usb_drive
export -f create_leonardo_structure install_leonardo_to_usb
export -f backup_usb_data restore_usb_data check_usb_free_space clean_usb_temp
