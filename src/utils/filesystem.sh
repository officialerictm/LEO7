#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - File System Utilities
# ==============================================================================
# Description: File system operations, USB detection, and disk management
# Version: 7.0.0
# Dependencies: logging.sh, colors.sh, validation.sh
# ==============================================================================

# Create directory with proper permissions
create_directory() {
    local dir="$1"
    local mode="${2:-755}"
    
    if [[ -z "$dir" ]]; then
        log_error "create_directory: No directory specified"
        return 1
    fi
    
    if [[ -d "$dir" ]]; then
        log_debug "Directory already exists: $dir"
        return 0
    fi
    
    log_debug "Creating directory: $dir"
    if mkdir -p "$dir" 2>/dev/null; then
        chmod "$mode" "$dir" 2>/dev/null || true
        log_debug "Directory created successfully: $dir"
        return 0
    else
        log_error "Failed to create directory: $dir"
        return 1
    fi
}

# Create a directory (alias for compatibility)
ensure_directory() {
    create_directory "$@"
}

# Detect available USB devices
detect_usb_devices() {
    local devices=()
    local device_info
    
    log_message "INFO" "Detecting USB devices..."
    
    # Linux method
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        while IFS= read -r device; do
            if [[ -b "$device" ]]; then
                local size=$(lsblk -bno SIZE "$device" 2>/dev/null || echo "0")
                local model=$(lsblk -no MODEL "$device" 2>/dev/null || echo "Unknown")
                local removable=$(cat "/sys/block/$(basename "$device")/removable" 2>/dev/null || echo "0")
                
                if [[ "$removable" == "1" ]] && [[ "$size" -gt 0 ]]; then
                    device_info="${device}|${size}|${model}"
                    devices+=("$device_info")
                fi
            fi
        done < <(ls /dev/sd[a-z] /dev/mmcblk[0-9] 2>/dev/null)
        
    # macOS method
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        while IFS= read -r line; do
            if [[ "$line" =~ /dev/(disk[0-9]+) ]]; then
                local device="/dev/${BASH_REMATCH[1]}"
                local info=$(diskutil info "$device" 2>/dev/null)
                
                if echo "$info" | grep -q "Removable Media:.*Yes"; then
                    local size=$(echo "$info" | grep "Total Size:" | sed 's/.*(\([0-9]*\) Bytes).*/\1/')
                    local model=$(echo "$info" | grep "Device / Media Name:" | sed 's/.*://' | xargs)
                    
                    device_info="${device}|${size:-0}|${model:-Unknown}"
                    devices+=("$device_info")
                fi
            fi
        done < <(diskutil list | grep "/dev/disk")
    fi
    
    # Return devices array
    printf '%s\n' "${devices[@]}"
}

# Get USB device information
get_device_info() {
    local device="$1"
    local info=""
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        info=$(lsblk -no NAME,SIZE,MODEL,VENDOR,FSTYPE,MOUNTPOINT "$device" 2>/dev/null | head -1)
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        info=$(diskutil info "$device" 2>/dev/null)
    fi
    
    echo "$info"
}

# Format USB device
format_usb_device() {
    local device="$1"
    local filesystem="${2:-$LEONARDO_DEFAULT_FS}"
    local label="${3:-$LEONARDO_USB_LABEL}"

    log_message "INFO" "Formatting $device as $filesystem with label $label"
    echo -e "${CYAN}→ Starting format of $device as $filesystem${COLOR_RESET}"

    # Unmount if mounted
    unmount_device "$device"

    # Platform-specific formatting
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        local partition="$device"
        if [[ "$device" =~ ^/dev/(sd[a-z]|nvme[0-9]+n[0-9]+)$ ]]; then
            echo -e "${DIM}Creating partition table...${COLOR_RESET}"
            
            # Unmount any mounted partitions first
            echo -e "${DIM}Unmounting any existing partitions on $device...${COLOR_RESET}"
            
            # Get base device name
            local base_device=$(basename "$device")
            
            # First, try to unmount all mounted partitions
            for part in $(lsblk -lno NAME,MOUNTPOINT | grep "^${base_device}[0-9]" | awk '{if ($2) print $1}'); do
                local mount_point=$(lsblk -lno MOUNTPOINT "/dev/$part" 2>/dev/null || true)
                if [[ -n "$mount_point" ]]; then
                    echo -e "${DIM}  Unmounting /dev/$part from $mount_point...${COLOR_RESET}"
                    sudo umount "/dev/$part" 2>/dev/null || true
                fi
            done
            
            # Force unmount any remaining mounts
            for mount_point in $(mount | grep "$device" | awk '{print $3}'); do
                echo -e "${DIM}  Force unmounting $mount_point...${COLOR_RESET}"
                sudo umount -l "$mount_point" 2>/dev/null || true
            done
            
            # Ensure device isn't in use by any process
            if command -v lsof >/dev/null 2>&1; then
                local device_in_use=$(sudo lsof "$device" 2>/dev/null || true)
                if [[ -n "$device_in_use" ]]; then
                    echo -e "${YELLOW}Device $device is in use by processes${COLOR_RESET}"
                    echo -e "${DIM}  Attempting to close processes...${COLOR_RESET}"
                    sudo lsof -t "$device" 2>/dev/null | xargs -r sudo kill -9 2>/dev/null || true
                fi
            fi
            
            # Give the system a moment to process the unmounts
            sleep 2
            
            # Wipe existing filesystem signatures first
            if command -v wipefs >/dev/null 2>&1; then
                echo -e "${DIM}Wiping existing filesystem signatures...${COLOR_RESET}"
                if ! wipefs -a -f "$device" >/dev/null 2>&1; then
                    # Try with sudo if permission denied
                    sudo wipefs -a -f "$device" >/dev/null 2>&1 || true
                fi
                sync
                sleep 1
            fi
            
            if command -v parted >/dev/null 2>&1; then
                if ! parted -s "$device" mklabel gpt >/dev/null 2>&1; then
                    # Try with sudo if permission denied
                    sudo parted -s "$device" mklabel gpt >/dev/null 2>&1
                fi
                sudo parted -s "$device" mkpart primary 0% 100% >/dev/null 2>&1
                sudo parted -s "$device" set 1 msftdata on >/dev/null 2>&1
                
                # Force kernel to re-read partition table
                sync
                if command -v partprobe >/dev/null 2>&1; then
                    partprobe "$device" >/dev/null 2>&1
                fi
                
                # Wait for partition to appear
                sleep 2
            else
                log_message "ERROR" "parted is required to format USB drives"
                echo -e "${RED}Error: parted is required to format USB drives${COLOR_RESET}"
                return 1
            fi
            
            # Determine partition path based on device type
            if [[ "$device" == *"nvme"* ]] || [[ "$device" == *"mmcblk"* ]]; then
                partition="${device}p1"
            else
                partition="${device}1"
            fi
            
            echo -e "${GREEN}✓ Partition ready: $partition${COLOR_RESET}"
            
            case "$filesystem" in
                exfat)
                    # Force kernel to re-read partition table immediately
                    sudo partprobe "$device" 2>/dev/null || true
                    
                    # Check for mkfs.exfat
                    if ! command -v mkfs.exfat >/dev/null 2>&1; then
                        echo -e "${RED}mkfs.exfat not found.${COLOR_RESET}"
                        install_missing_filesystem_tool "exfat" || return 1
                        # Retry formatting after installation
                        format_usb_device "$device" "$filesystem" "$label"
                        return $?
                    fi
                    
                    # Try to format immediately without waiting
                    echo -e "${DIM}Using mkfs.exfat...${COLOR_RESET}"
                    echo -e "${YELLOW}Root privileges required for formatting.${COLOR_RESET}"
                    echo -e "${BLUE}Please enter your password when prompted:${COLOR_RESET}"
                    
                    if sudo mkfs.exfat -n "$label" "$partition"; then
                        echo -e "${GREEN}✓ Successfully formatted with exFAT${COLOR_RESET}"
                    else
                        # If immediate format fails, try a different approach
                        echo -e "${YELLOW}Initial format failed, trying alternative approach...${COLOR_RESET}"
                        
                        # First, aggressively unmount with force
                        echo -e "${DIM}Force unmounting device...${COLOR_RESET}"
                        echo -e "${YELLOW}Root privileges required for force unmount.${COLOR_RESET}"
                        if sudo umount -f "$partition" 2>/dev/null; then
                            echo -e "${GREEN}✓ Force unmount successful${COLOR_RESET}"
                        else
                            echo -e "${DIM}Force unmount didn't work, trying lazy unmount...${COLOR_RESET}"
                            sudo umount -l "$partition" 2>/dev/null || true
                        fi
                        
                        # Check what's still using the device
                        echo -e "${DIM}Checking what's using the device...${COLOR_RESET}"
                        local device_users=$(sudo lsof "$partition" 2>/dev/null || true)
                        if [[ -n "$device_users" ]]; then
                            echo -e "${YELLOW}Processes using device:${COLOR_RESET}"
                            echo "$device_users"
                            
                            # Try to kill processes using the device (carefully)
                            echo -e "${DIM}Attempting to stop processes using the device...${COLOR_RESET}"
                            local pids=$(sudo lsof -t "$partition" 2>/dev/null || true)
                            if [[ -n "$pids" ]]; then
                                for pid in $pids; do
                                    # Skip critical system processes
                                    local proc_name=$(ps -p "$pid" -o comm= 2>/dev/null || true)
                                    if [[ "$proc_name" != "systemd" ]] && [[ "$proc_name" != "init" ]]; then
                                        echo -e "${DIM}Stopping process $pid ($proc_name)...${COLOR_RESET}"
                                        sudo kill -TERM "$pid" 2>/dev/null || true
                                    fi
                                done
                                sleep 1
                            fi
                        fi
                        
                        # Try to eject the device properly
                        echo -e "${DIM}Ejecting device properly...${COLOR_RESET}"
                        sudo eject "$partition" 2>/dev/null || true
                        sleep 2
                        
                        # One more aggressive unmount attempt
                        echo -e "${DIM}Final unmount attempt...${COLOR_RESET}"
                        sudo umount -f "$partition" 2>/dev/null || true
                        sudo umount -l "$partition" 2>/dev/null || true
                        
                        # Force a sync
                        sync
                        
                        # Wait for device to settle
                        echo -e "${DIM}Waiting for device to settle...${COLOR_RESET}"
                        sleep 3
                        
                        # Try formatting one more time
                        echo -e "${DIM}Final format attempt...${COLOR_RESET}"
                        if sudo mkfs.exfat -n "$label" "$partition"; then
                            echo -e "${GREEN}✓ Successfully formatted with exFAT${COLOR_RESET}"
                        else
                            # If all else fails, suggest manual intervention
                            echo -e "${RED}Error: Unable to format device${COLOR_RESET}"
                            echo -e "${YELLOW}The device appears to be locked by the system.${COLOR_RESET}"
                            echo -e "${YELLOW}Please try one of these solutions:${COLOR_RESET}"
                            echo -e "${YELLOW}  1. Close any file managers or applications using the USB${COLOR_RESET}"
                            echo -e "${YELLOW}  2. Run: sudo umount -f $partition${COLOR_RESET}"
                            echo -e "${YELLOW}  3. Physically unplug and replug the USB device${COLOR_RESET}"
                            echo -e "${YELLOW}  4. Try formatting with a different filesystem (FAT32)${COLOR_RESET}"
                            return 1
                        fi
                    fi
                    
                    # Ensure auto-mount services are running again
                    sudo systemctl start udisks2.service 2>/dev/null || true
                    
                    # Force kernel to recognize the new filesystem
                    sudo partprobe "$device" 2>/dev/null || true
                    sync
                    sleep 2
                    ;;
                fat32)
                    # Check if command exists
                    echo -e "${DIM}Checking for mkfs.vfat...${COLOR_RESET}"
                    if ! command -v mkfs.vfat >/dev/null 2>&1; then
                        echo -e "${RED}mkfs.vfat not found.${COLOR_RESET}"
                        install_missing_filesystem_tool "fat32" || return 1
                        # Retry formatting after installation
                        format_usb_device "$device" "$filesystem" "$label"
                        return $?
                    fi
                    
                    echo -e "${DIM}Found mkfs.vfat, formatting...${COLOR_RESET}"
                    # Always use sudo for formatting
                    echo -e "${YELLOW}Root privileges required for formatting.${COLOR_RESET}"
                    echo -e "${BLUE}Please enter your password when prompted:${COLOR_RESET}"
                    
                    if sudo mkfs.vfat -F 32 -n "$label" "$partition"; then
                        echo -e "${GREEN}✓ Successfully formatted with FAT32${COLOR_RESET}"
                    else
                        local exit_code=$?
                        echo -e "${RED}mkfs.vfat failed with error code $exit_code${COLOR_RESET}"
                        return 1
                    fi
                    ;;
                ntfs)
                    # Check if command exists  
                    echo -e "${DIM}Checking for mkfs.ntfs...${COLOR_RESET}"
                    if ! command -v mkfs.ntfs >/dev/null 2>&1; then
                        echo -e "${RED}mkfs.ntfs not found.${COLOR_RESET}"
                        install_missing_filesystem_tool "ntfs" || return 1
                        # Retry formatting after installation
                        format_usb_device "$device" "$filesystem" "$label"
                        return $?
                    fi
                    
                    echo -e "${DIM}Found mkfs.ntfs, formatting...${COLOR_RESET}"
                    # Always use sudo for formatting
                    echo -e "${YELLOW}Root privileges required for formatting.${COLOR_RESET}"
                    echo -e "${BLUE}Please enter your password when prompted:${COLOR_RESET}"
                    if ! sudo mkfs.ntfs -f -L "$label" "$partition"; then
                        local exit_code=$?
                        echo -e "${RED}mkfs.ntfs failed with error code $exit_code${COLOR_RESET}"
                        return 1
                    fi
                    ;;
                ext4)
                    mkfs.ext4 -L "$label" "$partition" 2>&1 | while read -r line; do
                        log_message "DEBUG" "mkfs.ext4: $line"
                    done
                    ;;
                *)
                    log_message "ERROR" "Unsupported filesystem: $filesystem"
                    return 1
                    ;;
            esac
        fi

    elif [[ "$OSTYPE" == "darwin"* ]]; then
        case "$filesystem" in
            exfat)
                diskutil eraseDisk ExFAT "$label" "$device" 2>&1 | while read -r line; do
                    log_message "DEBUG" "diskutil: $line"
                done
                ;;
            fat32|vfat)
                diskutil eraseDisk FAT32 "$label" "$device" 2>&1 | while read -r line; do
                    log_message "DEBUG" "diskutil: $line"
                done
                ;;
            *)
                log_message "ERROR" "Unsupported filesystem on macOS: $filesystem"
                return 1
                ;;
        esac
    fi
}

# Mount device
mount_device() {
    local device="$1"
    local mount_point="${2:-}"
    
    # Auto-generate mount point if not provided
    if [[ -z "$mount_point" ]]; then
        mount_point="/tmp/leonardo-mount-$$"
        mkdir -p "$mount_point"
    fi
    
    log_message "INFO" "Mounting $device to $mount_point"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        mount "$device" "$mount_point" 2>&1 | while read -r line; do
            log_message "DEBUG" "mount: $line"
        done
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        diskutil mount -mountPoint "$mount_point" "$device" 2>&1 | while read -r line; do
            log_message "DEBUG" "diskutil mount: $line"
        done
    fi
    
    echo "$mount_point"
}

# Unmount device
unmount_device() {
    local device="$1"
    
    log_message "INFO" "Unmounting $device"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Find all mount points for the device
        while IFS= read -r mount_point; do
            umount "$mount_point" 2>&1 | while read -r line; do
                log_message "DEBUG" "umount: $line"
            done
        done < <(findmnt -rno TARGET "$device" 2>/dev/null)
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        diskutil unmount "$device" 2>&1 | while read -r line; do
            log_message "DEBUG" "diskutil unmount: $line"
        done
    fi
}

# Check available space
check_available_space() {
    local path="$1"
    local required_bytes="${2:-0}"
    
    local available_bytes
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        available_bytes=$(df -B1 "$path" 2>/dev/null | tail -1 | awk '{print $4}')
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        available_bytes=$(df -k "$path" 2>/dev/null | tail -1 | awk '{print $4 * 1024}')
    fi
    
    if [[ -z "$available_bytes" ]] || [[ "$available_bytes" -lt "$required_bytes" ]]; then
        local required_human=$(format_bytes "$required_bytes")
        local available_human=$(format_bytes "${available_bytes:-0}")
        log_message "ERROR" "Insufficient space: need $required_human, have $available_human"
        return 1
    fi
    
    echo "$available_bytes"
    return 0
}

# Create directory structure
create_leonardo_structure() {
    local base_path="$1"
    
    log_message "INFO" "Creating Leonardo directory structure at $base_path"
    
    # Define directory structure
    local dirs=(
        "models"
        "models/cache"
        "models/active"
        "config"
        "logs"
        "temp"
        "backups"
        "scripts"
        "data"
        "data/sessions"
        "data/history"
    )
    
    # Create directories
    for dir in "${dirs[@]}"; do
        local full_path="$base_path/leonardo/$dir"
        if mkdir -p "$full_path" 2>/dev/null; then
            log_message "DEBUG" "Created: $full_path"
        else
            log_message "ERROR" "Failed to create: $full_path"
            return 1
        fi
    done
    
    # Set permissions (if not Windows)
    if [[ "$OSTYPE" != "msys" ]] && [[ "$OSTYPE" != "cygwin" ]]; then
        chmod -R 755 "$base_path/leonardo"
    fi
    
    return 0
}

# Copy file with progress
copy_with_progress() {
    local source="$1"
    local dest="$2"
    local callback="${3:-}"
    
    if [[ ! -f "$source" ]]; then
        log_message "ERROR" "Source file not found: $source"
        return 1
    fi
    
    local size=$(stat -f%z "$source" 2>/dev/null || stat -c%s "$source" 2>/dev/null)
    local block_size=$((1024 * 1024))  # 1MB blocks
    local copied=0
    
    log_message "INFO" "Copying $source to $dest ($(format_bytes "$size"))"
    
    # Use dd for copying with progress
    dd if="$source" of="$dest" bs="$block_size" 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ ([0-9]+)\ bytes ]]; then
            copied="${BASH_REMATCH[1]}"
            if [[ -n "$callback" ]] && [[ "$size" -gt 0 ]]; then
                local percent=$((copied * 100 / size))
                $callback "$percent" "$copied" "$size"
            fi
        fi
    done
    
    # Verify copy
    if [[ -f "$dest" ]]; then
        local dest_size=$(stat -f%z "$dest" 2>/dev/null || stat -c%s "$dest" 2>/dev/null)
        if [[ "$dest_size" -eq "$size" ]]; then
            log_message "INFO" "Copy completed successfully"
            return 0
        else
            log_message "ERROR" "Copy verification failed: size mismatch"
            return 1
        fi
    else
        log_message "ERROR" "Copy failed: destination not created"
        return 1
    fi
}

# Safe delete with optional secure wipe
safe_delete() {
    local path="$1"
    local secure="${2:-$LEONARDO_SECURE_DELETE}"
    
    if [[ ! -e "$path" ]]; then
        log_message "DEBUG" "Path does not exist: $path"
        return 0
    fi
    
    log_message "INFO" "Deleting: $path (secure: $secure)"
    
    if [[ "$secure" == "true" ]] && command -v shred >/dev/null 2>&1; then
        # Secure delete with shred
        if [[ -f "$path" ]]; then
            shred -vfz -n 3 "$path" 2>&1 | while read -r line; do
                log_message "DEBUG" "shred: $line"
            done
        elif [[ -d "$path" ]]; then
            find "$path" -type f -exec shred -vfz -n 3 {} \; 2>&1 | while read -r line; do
                log_message "DEBUG" "shred: $line"
            done
            rm -rf "$path"
        fi
    else
        # Regular delete
        rm -rf "$path" 2>&1 | while read -r line; do
            log_message "DEBUG" "rm: $line"
        done
    fi
}

# Get file checksum
get_file_checksum() {
    local file="$1"
    local algorithm="${2:-sha256}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    local checksum
    case "$algorithm" in
        md5)    checksum=$(md5sum "$file" 2>/dev/null | cut -d' ' -f1) ;;
        sha1)   checksum=$(sha1sum "$file" 2>/dev/null | cut -d' ' -f1) ;;
        sha256) checksum=$(sha256sum "$file" 2>/dev/null | cut -d' ' -f1) ;;
        sha512) checksum=$(sha512sum "$file" 2>/dev/null | cut -d' ' -f1) ;;
        *)
            log_message "ERROR" "Unknown checksum algorithm: $algorithm"
            return 1
            ;;
    esac
    
    echo "$checksum"
}

# Create temporary directory
create_temp_dir() {
    local prefix="${1:-leonardo}"
    local temp_dir
    
    if command -v mktemp >/dev/null 2>&1; then
        temp_dir=$(mktemp -d "/tmp/${prefix}.XXXXXX")
    else
        temp_dir="/tmp/${prefix}.$$"
        mkdir -p "$temp_dir"
    fi
    
    log_message "DEBUG" "Created temporary directory: $temp_dir"
    echo "$temp_dir"
}

# Cleanup temporary files
cleanup_temp_files() {
    local pattern="${1:-/tmp/leonardo*}"
    
    log_message "INFO" "Cleaning up temporary files: $pattern"
    
    find /tmp -name "leonardo*" -mtime +1 -exec rm -rf {} \; 2>/dev/null
}

# Export filesystem functions
export -f detect_usb_devices format_usb_device mount_device unmount_device
export -f check_available_space create_leonardo_structure copy_with_progress
export -f safe_delete get_file_checksum create_temp_dir
export -f create_directory ensure_directory
