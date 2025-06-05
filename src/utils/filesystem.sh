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
    
    # Check if we need sudo (Linux only)
    local need_sudo=""
    if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ $EUID -ne 0 ]]; then
        need_sudo="sudo"
        echo -e "${YELLOW}⚠ Formatting USB requires administrator privileges${COLOR_RESET}"
        echo -e "${CYAN}You may be prompted for your password${COLOR_RESET}"
        
        # Prompt for sudo password early
        if ! sudo -v; then
            echo -e "${RED}Error: Unable to obtain administrator privileges${COLOR_RESET}"
            return 1
        fi
    fi
    
    # Unmount if mounted
    unmount_device "$device"

    # Platform-specific formatting
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check if device is a whole disk or partition
        local target_device="$device"
        local is_partition=false
        
        # Check if this is a partition (ends with a number)
        if [[ "$device" =~ [0-9]$ ]]; then
            is_partition=true
            echo -e "${DIM}Detected partition device: $device${COLOR_RESET}"
        else
            # Check if device has partitions
            local partitions=$(lsblk -rno NAME,TYPE "$device" 2>/dev/null | grep -c "part" || echo "0")
            if [[ $partitions -gt 0 ]]; then
                # Device has partitions, we need to either use the first partition or recreate partition table
                echo -e "${YELLOW}Device $device has existing partitions${COLOR_RESET}"
                
                # For whole device formatting, we need to wipe and recreate partition table
                echo -e "${CYAN}Creating new partition table for cross-platform compatibility...${COLOR_RESET}"
                
                # Unmount all partitions
                for part in $(lsblk -rno NAME "$device" | grep -v "^$(basename $device)$"); do
                    local part_device="/dev/$part"
                    echo -e "${DIM}Running: ${need_sudo} umount $part_device${COLOR_RESET}"
                    $need_sudo umount "$part_device" 2>/dev/null || true
                    # Force lazy unmount if regular unmount fails
                    $need_sudo umount -l "$part_device" 2>/dev/null || true
                done
                
                # Wait a moment for unmounts to complete
                sleep 1
                
                # Clear partition signatures to avoid "in use" errors
                echo -e "${DIM}Clearing partition signatures...${COLOR_RESET}"
                $need_sudo wipefs -a "$device" 2>/dev/null || true
                
                # Force kernel to re-read partition table
                $need_sudo partprobe "$device" 2>/dev/null || true
                
                # Create new partition table with single partition
                echo -e "${DIM}Creating GPT partition table...${COLOR_RESET}"
                if ! $need_sudo parted -s "$device" mklabel gpt 2>&1; then
                    echo -e "${RED}Failed to create partition table${COLOR_RESET}"
                    echo -e "${YELLOW}Tip: Try ejecting the USB from your desktop first${COLOR_RESET}"
                    return 1
                fi
                
                echo -e "${DIM}Creating partition...${COLOR_RESET}"
                if ! $need_sudo parted -s "$device" mkpart primary 1MiB 100% 2>&1; then
                    echo -e "${RED}Failed to create partition${COLOR_RESET}"
                    return 1
                fi
                
                # Wait for partition to appear
                sleep 2
                
                # Find the new partition
                if [[ -e "${device}1" ]]; then
                    target_device="${device}1"
                elif [[ -e "${device}p1" ]]; then
                    target_device="${device}p1"
                else
                    echo -e "${RED}Error: Could not find created partition${COLOR_RESET}"
                    return 1
                fi
                echo -e "${GREEN}✓ Created partition: $target_device${COLOR_RESET}"
            fi
        fi
        
        # Now format the target device (either original partition or newly created one)
        case "$filesystem" in
            exfat)
                if ! command -v mkfs.exfat &> /dev/null; then
                    echo -e "${RED}Error: mkfs.exfat not found${COLOR_RESET}"
                    echo -e "${YELLOW}Install with: sudo apt install exfat-utils exfatprogs${COLOR_RESET}"
                    echo -e "${YELLOW}Or on newer systems: sudo apt install exfatprogs${COLOR_RESET}"
                    return 1
                fi
                echo -e "${DIM}Running: ${need_sudo} mkfs.exfat -n \"$label\" $target_device${COLOR_RESET}"
                
                # Capture both stdout and stderr
                local format_output
                format_output=$(${need_sudo} mkfs.exfat -n "$label" "$target_device" 2>&1)
                local exit_code=$?
                
                if [[ $exit_code -ne 0 ]]; then
                    echo -e "${RED}Failed to format USB drive as exFAT${COLOR_RESET}"
                    echo -e "${DIM}Error details: $format_output${COLOR_RESET}"
                    
                    # Check for common issues
                    if [[ "$format_output" == *"No such file or directory"* ]]; then
                        echo -e "${YELLOW}Tip: Device issue detected. Try unplugging and reconnecting the USB${COLOR_RESET}"
                    elif [[ "$format_output" == *"Device or resource busy"* ]]; then
                        echo -e "${YELLOW}Tip: The device may be in use. Try ejecting it from your file manager first${COLOR_RESET}"
                    elif [[ "$format_output" == *"Permission denied"* ]]; then
                        echo -e "${YELLOW}Tip: Permission issue detected even with sudo${COLOR_RESET}"
                    fi
                    return 1
                else
                    echo -e "${GREEN}✓ Successfully formatted as exFAT (cross-platform compatible)${COLOR_RESET}"
                fi
                ;;
            fat32|vfat)
                echo -e "${DIM}Running: ${need_sudo} mkfs.vfat -F 32 -n \"$label\" $target_device${COLOR_RESET}"
                
                local format_output
                format_output=$(${need_sudo} mkfs.vfat -F 32 -n "$label" "$target_device" 2>&1)
                local exit_code=$?
                
                if [[ $exit_code -ne 0 ]]; then
                    echo -e "${RED}Failed to format USB drive as FAT32${COLOR_RESET}"
                    echo -e "${DIM}Error details: $format_output${COLOR_RESET}"
                    return 1
                else
                    echo -e "${GREEN}✓ Successfully formatted as FAT32${COLOR_RESET}"
                fi
                ;;
            ntfs)
                if ! command -v mkfs.ntfs &> /dev/null; then
                    echo -e "${RED}Error: mkfs.ntfs not found${COLOR_RESET}"
                    echo -e "${YELLOW}Install with: sudo apt install ntfs-3g${COLOR_RESET}"
                    return 1
                fi
                echo -e "${DIM}Running: ${need_sudo} mkfs.ntfs -Q -L \"$label\" $target_device${COLOR_RESET}"
                
                local format_output
                format_output=$(${need_sudo} mkfs.ntfs -Q -L "$label" "$target_device" 2>&1)
                local exit_code=$?
                
                if [[ $exit_code -ne 0 ]]; then
                    echo -e "${RED}Failed to format USB drive as NTFS${COLOR_RESET}"
                    echo -e "${DIM}Error details: $format_output${COLOR_RESET}"
                    return 1
                else
                    echo -e "${GREEN}✓ Successfully formatted as NTFS${COLOR_RESET}"
                fi
                ;;
            ext4)
                echo -e "${DIM}Running: ${need_sudo} mkfs.ext4 -L \"$label\" $target_device${COLOR_RESET}"
                
                local format_output
                format_output=$(${need_sudo} mkfs.ext4 -L "$label" "$target_device" 2>&1)
                local exit_code=$?
                
                if [[ $exit_code -ne 0 ]]; then
                    echo -e "${RED}Failed to format USB drive as ext4${COLOR_RESET}"
                    echo -e "${DIM}Error details: $format_output${COLOR_RESET}"
                    return 1
                else
                    echo -e "${GREEN}✓ Successfully formatted as ext4${COLOR_RESET}"
                fi
                ;;
            *)
                log_message "ERROR" "Unsupported filesystem: $filesystem"
                return 1
                ;;
        esac

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
    
    # Platform-specific mounting
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        diskutil mount "$device" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            # Get the mount point from diskutil
            local mounted_at=$(diskutil info "$device" 2>/dev/null | grep "Mount Point:" | cut -d: -f2- | xargs)
            if [[ -n "$mounted_at" ]]; then
                export LEONARDO_USB_MOUNT="$mounted_at"
                echo -e "${GREEN}✓ Mounted at: $mounted_at${COLOR_RESET}"
                return 0
            fi
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        # Create mount point if not specified
        if [[ -z "$mount_point" ]]; then
            mount_point="/media/$USER/leonardo_$$"
            if ! mkdir -p "$mount_point" 2>/dev/null; then
                mount_point="/mnt/leonardo_$$"
            fi
        fi
        
        # Try user-level mount first
        if mount "$device" "$mount_point" 2>/dev/null; then
            export LEONARDO_USB_MOUNT="$mount_point"
            echo -e "${GREEN}✓ Mounted at: $mount_point${COLOR_RESET}"
            return 0
        fi
        
        # Try udisksctl for user mounting
        if command -v udisksctl >/dev/null 2>&1; then
            echo -e "${DIM}Trying udisksctl mount...${COLOR_RESET}"
            local mount_output=$(udisksctl mount -b "$device" 2>&1)
            if [[ $? -eq 0 ]]; then
                # Extract mount point from output
                local mounted_at=$(echo "$mount_output" | grep -oP "Mounted .* at \K.*" | sed 's/\.$//')
                if [[ -n "$mounted_at" ]]; then
                    export LEONARDO_USB_MOUNT="$mounted_at"
                    echo -e "${GREEN}✓ Mounted at: $mounted_at${COLOR_RESET}"
                    return 0
                fi
            fi
        fi
        
        # Try with sudo
        echo -e "${YELLOW}⚠ Mounting USB requires administrator privileges${COLOR_RESET}"
        echo -e "${CYAN}You may be prompted for your password${COLOR_RESET}"
        echo -e "${DIM}Running: sudo mount $device $mount_point${COLOR_RESET}"
        
        # Create mount point with sudo if needed
        if [[ ! -d "$mount_point" ]]; then
            sudo mkdir -p "$mount_point"
        fi
        
        # Mount with sudo
        if sudo mount "$device" "$mount_point" 2>&1; then
            export LEONARDO_USB_MOUNT="$mount_point"
            echo -e "${GREEN}✓ Mounted at: $mount_point${COLOR_RESET}"
            
            # Try to make it writable for the user
            sudo chown -R "$USER:$USER" "$mount_point" 2>/dev/null || true
            return 0
        else
            echo -e "${RED}Failed to mount device${COLOR_RESET}"
            # Clean up mount point if we created it
            rmdir "$mount_point" 2>/dev/null || true
            return 1
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        # Windows - usually auto-mounts
        export LEONARDO_USB_MOUNT="$device"
        return 0
    fi
    
    return 1
}

# Unmount device
unmount_device() {
    local device="$1"
    
    log_message "INFO" "Unmounting $device"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Find all mount points for the device
        local need_sudo=""
        if [[ $EUID -ne 0 ]]; then
            need_sudo="sudo"
        fi
        
        while IFS= read -r mount_point; do
            if [[ -n "$mount_point" ]]; then
                # Try without sudo first
                if ! umount "$mount_point" 2>/dev/null; then
                    if [[ -n "$need_sudo" ]]; then
                        echo -e "${DIM}Running: sudo umount $mount_point${COLOR_RESET}"
                        $need_sudo umount "$mount_point" 2>&1 | while read -r line; do
                            log_message "DEBUG" "umount: $line"
                        done
                    fi
                else
                    log_message "DEBUG" "Unmounted $mount_point"
                fi
            fi
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
