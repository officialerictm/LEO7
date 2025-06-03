#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - USB Detection Module
# ==============================================================================
# Description: Detect and identify USB drives across platforms
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh
# ==============================================================================

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        CYGWIN*)    echo "windows" ;;
        MINGW*)     echo "windows" ;;
        MSYS*)      echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# Detect USB drives
detect_usb_drives() {
    local platform=$(detect_platform)
    local -a drives=()
    
    case "$platform" in
        "macos")
            detect_usb_drives_macos
            ;;
        "linux")
            detect_usb_drives_linux
            ;;
        "windows")
            detect_usb_drives_windows
            ;;
        *)
            log_message "ERROR" "Unsupported platform: $platform"
            return 1
            ;;
    esac
}

# Detect USB drives on macOS
detect_usb_drives_macos() {
    local -a drives=()
    
    # Use diskutil to find external, physical disks
    while IFS= read -r line; do
        if [[ "$line" =~ /dev/disk[0-9]+ ]]; then
            local disk="${BASH_REMATCH[0]}"
            # Check if it's external and physical
            if diskutil info "$disk" 2>/dev/null | grep -q "Protocol:.*USB"; then
                local info=$(diskutil info "$disk" 2>/dev/null)
                local name=$(echo "$info" | grep "Media Name:" | cut -d: -f2- | xargs)
                local size=$(echo "$info" | grep "Disk Size:" | cut -d: -f2 | awk '{print $1, $2}')
                local mount=$(echo "$info" | grep "Mount Point:" | cut -d: -f2- | xargs)
                
                drives+=("$disk|$name|$size|$mount")
            fi
        fi
    done < <(diskutil list | grep "external, physical")
    
    # Output drives
    for drive in "${drives[@]}"; do
        echo "$drive"
    done
}

# Detect USB drives on Linux
detect_usb_drives_linux() {
    local -a drives=()
    
    # Use lsblk to find USB devices
    while IFS= read -r line; do
        local device=$(echo "$line" | awk '{print $1}')
        local size=$(echo "$line" | awk '{print $2}')
        local mount=$(echo "$line" | awk '{print $3}')
        local label=$(echo "$line" | awk '{print $4}')
        
        # Check if it's a USB device
        if [[ -n "$device" ]] && udevadm info --query=all --name="$device" 2>/dev/null | grep -q "ID_BUS=usb"; then
            drives+=("/dev/$device|$label|$size|$mount")
        fi
    done < <(lsblk -nlo NAME,SIZE,MOUNTPOINT,LABEL | grep -E "^sd[a-z][0-9]?")
    
    # Output drives
    for drive in "${drives[@]}"; do
        echo "$drive"
    done
}

# Detect USB drives on Windows
detect_usb_drives_windows() {
    local -a drives=()
    
    # Use wmic to find USB drives
    if command_exists "wmic"; then
        while IFS= read -r line; do
            if [[ -n "$line" ]] && [[ "$line" != "DeviceID"* ]]; then
                local device=$(echo "$line" | awk '{print $1}')
                local size=$(echo "$line" | awk '{print $2}')
                drives+=("$device|USB Drive|$size|$device")
            fi
        done < <(wmic logicaldisk where "DriveType=2" get DeviceID,Size /format:table 2>/dev/null | tail -n +2)
    fi
    
    # Output drives
    for drive in "${drives[@]}"; do
        echo "$drive"
    done
}

# Get USB drive info
get_usb_drive_info() {
    local device="$1"
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            get_usb_drive_info_macos "$device"
            ;;
        "linux")
            get_usb_drive_info_linux "$device"
            ;;
        "windows")
            get_usb_drive_info_windows "$device"
            ;;
        *)
            log_message "ERROR" "Unsupported platform"
            return 1
            ;;
    esac
}

# Get USB drive info on macOS
get_usb_drive_info_macos() {
    local device="$1"
    
    if diskutil info "$device" >/dev/null 2>&1; then
        local info=$(diskutil info "$device")
        
        echo "Device: $device"
        echo "$info" | grep "Media Name:" | sed 's/^[[:space:]]*//'
        echo "$info" | grep "Volume Name:" | sed 's/^[[:space:]]*//'
        echo "$info" | grep "Disk Size:" | sed 's/^[[:space:]]*//'
        echo "$info" | grep "Device Block Size:" | sed 's/^[[:space:]]*//'
        echo "$info" | grep "Volume Free Space:" | sed 's/^[[:space:]]*//'
        echo "$info" | grep "File System:" | sed 's/^[[:space:]]*//'
        echo "$info" | grep "Mount Point:" | sed 's/^[[:space:]]*//'
        
        # Get USB specific info
        if system_profiler SPUSBDataType 2>/dev/null | grep -A 20 "$(basename "$device")" | grep -q "Serial Number:"; then
            echo "USB Device: Yes"
            system_profiler SPUSBDataType 2>/dev/null | grep -A 20 "$(basename "$device")" | grep "Serial Number:" | head -1
        fi
    else
        log_message "ERROR" "Cannot get info for device: $device"
        return 1
    fi
}

# Get USB drive info on Linux
get_usb_drive_info_linux() {
    local device="$1"
    
    if [[ -b "$device" ]]; then
        echo "Device: $device"
        
        # Basic info from lsblk
        lsblk -no NAME,SIZE,TYPE,FSTYPE,LABEL,MOUNTPOINT "$device" 2>/dev/null | head -1 | \
        while read -r name size type fstype label mount; do
            echo "Size: $size"
            echo "Type: $type"
            echo "File System: $fstype"
            [[ -n "$label" ]] && echo "Label: $label"
            [[ -n "$mount" ]] && echo "Mount Point: $mount"
        done
        
        # USB specific info from udevadm
        if udevadm info --query=all --name="$device" 2>/dev/null | grep -q "ID_BUS=usb"; then
            echo "USB Device: Yes"
            udevadm info --query=all --name="$device" 2>/dev/null | grep "ID_SERIAL=" | cut -d= -f2 | head -1 | xargs -I{} echo "Serial Number: {}"
            udevadm info --query=all --name="$device" 2>/dev/null | grep "ID_VENDOR=" | cut -d= -f2 | head -1 | xargs -I{} echo "Vendor: {}"
            udevadm info --query=all --name="$device" 2>/dev/null | grep "ID_MODEL=" | cut -d= -f2 | head -1 | xargs -I{} echo "Model: {}"
        fi
        
        # Free space if mounted
        if mount | grep -q "^$device"; then
            local mount_point=$(mount | grep "^$device" | awk '{print $3}')
            local free_space=$(df -h "$mount_point" 2>/dev/null | tail -1 | awk '{print $4}')
            echo "Free Space: $free_space"
        fi
    else
        log_message "ERROR" "Device not found: $device"
        return 1
    fi
}

# Get USB drive info on Windows
get_usb_drive_info_windows() {
    local device="$1"
    
    if command_exists "wmic"; then
        echo "Device: $device"
        
        # Get drive info
        wmic logicaldisk where "DeviceID='$device'" get Size,FreeSpace,FileSystem,VolumeName /format:list 2>/dev/null | \
        grep -E "(Size|FreeSpace|FileSystem|VolumeName)=" | while IFS='=' read -r key value; do
            case "$key" in
                "Size") echo "Size: $(format_bytes "$value")" ;;
                "FreeSpace") echo "Free Space: $(format_bytes "$value")" ;;
                "FileSystem") echo "File System: $value" ;;
                "VolumeName") [[ -n "$value" ]] && echo "Volume Name: $value" ;;
            esac
        done
        
        # Check if USB
        if wmic logicaldisk where "DeviceID='$device' and DriveType=2" get DeviceID 2>/dev/null | grep -q "$device"; then
            echo "USB Device: Yes"
        fi
    fi
}

# Check if device is USB
is_usb_device() {
    local device="$1"
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            diskutil info "$device" 2>/dev/null | grep -q "Protocol:.*USB"
            ;;
        "linux")
            udevadm info --query=all --name="$device" 2>/dev/null | grep -q "ID_BUS=usb"
            ;;
        "windows")
            wmic logicaldisk where "DeviceID='$device' and DriveType=2" get DeviceID 2>/dev/null | grep -q "$device"
            ;;
        *)
            return 1
            ;;
    esac
}

# Get USB device speed
get_usb_speed() {
    local device="$1"
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            system_profiler SPUSBDataType 2>/dev/null | grep -A 10 "$(basename "$device")" | grep "Speed:" | head -1 | awk '{print $2, $3}'
            ;;
        "linux")
            if [[ -f "/sys/block/$(basename "$device")/device/speed" ]]; then
                local speed=$(cat "/sys/block/$(basename "$device")/device/speed" 2>/dev/null)
                case "$speed" in
                    "12") echo "USB 1.1 (12 Mbps)" ;;
                    "480") echo "USB 2.0 (480 Mbps)" ;;
                    "5000") echo "USB 3.0 (5 Gbps)" ;;
                    "10000") echo "USB 3.1 (10 Gbps)" ;;
                    "20000") echo "USB 3.2 (20 Gbps)" ;;
                    *) echo "Unknown ($speed Mbps)" ;;
                esac
            fi
            ;;
        "windows")
            # Windows requires more complex WMI queries
            echo "N/A"
            ;;
    esac
}

# Monitor USB device changes
monitor_usb_changes() {
    local callback="${1:-on_usb_change}"
    local platform=$(detect_platform)
    
    log_message "INFO" "Monitoring USB device changes..."
    
    case "$platform" in
        "macos")
            # Use diskutil activity
            diskutil activity | while read -r line; do
                if [[ "$line" =~ (Disk Appeared|Disk Disappeared) ]]; then
                    $callback "$line"
                fi
            done
            ;;
        "linux")
            # Use udevadm monitor
            if command_exists "udevadm"; then
                udevadm monitor --subsystem-match=usb --property | while read -r line; do
                    if [[ "$line" =~ (add|remove) ]]; then
                        $callback "$line"
                    fi
                done
            else
                log_message "ERROR" "udevadm not available for USB monitoring"
                return 1
            fi
            ;;
        "windows")
            log_message "WARN" "USB monitoring not implemented for Windows"
            return 1
            ;;
    esac
}

# Default USB change callback
on_usb_change() {
    local event="$1"
    log_message "INFO" "USB Event: $event"
    
    # Refresh USB device list
    echo "${COLOR_YELLOW}USB device change detected. Refreshing...${COLOR_RESET}"
    list_usb_drives
}

# List USB drives with formatting
list_usb_drives() {
    local format="${1:-table}"
    local drives_found=0
    
    echo "${COLOR_CYAN}Detecting USB drives...${COLOR_RESET}"
    echo ""
    
    if [[ "$format" == "table" ]]; then
        printf "${COLOR_CYAN}%-15s %-30s %-10s %-30s${COLOR_RESET}\n" \
            "Device" "Name" "Size" "Mount Point"
        echo "--------------------------------------------------------------------------------"
    fi
    
    while IFS='|' read -r device name size mount; do
        ((drives_found++))
        
        case "$format" in
            "table")
                printf "%-15s %-30s %-10s %-30s\n" \
                    "$device" "${name:-Unknown}" "${size:-N/A}" "${mount:-Not Mounted}"
                ;;
            "json")
                echo "{\"device\":\"$device\",\"name\":\"$name\",\"size\":\"$size\",\"mount\":\"$mount\"}"
                ;;
            "simple")
                echo "$device"
                ;;
        esac
    done < <(detect_usb_drives)
    
    if [[ $drives_found -eq 0 ]]; then
        echo "${COLOR_YELLOW}No USB drives detected${COLOR_RESET}"
        return 1
    else
        [[ "$format" == "table" ]] && echo ""
        echo "${COLOR_GREEN}Found $drives_found USB drive(s)${COLOR_RESET}"
    fi
    
    return 0
}

# Test USB write speed
test_usb_write_speed() {
    local device="$1"
    local test_size="${2:-100M}"
    
    # Get mount point
    local mount_point=""
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            mount_point=$(diskutil info "$device" 2>/dev/null | grep "Mount Point:" | cut -d: -f2- | xargs)
            ;;
        "linux")
            mount_point=$(lsblk -no MOUNTPOINT "$device" 2>/dev/null | head -1)
            ;;
        "windows")
            mount_point="$device\\"
            ;;
    esac
    
    if [[ -z "$mount_point" ]] || [[ "$mount_point" == "Not Mounted" ]]; then
        log_message "ERROR" "Device not mounted: $device"
        return 1
    fi
    
    echo "${COLOR_CYAN}Testing USB write speed on $device...${COLOR_RESET}"
    echo "Mount point: $mount_point"
    
    local test_file="$mount_point/.leonardo_speed_test_$$"
    local start_time=$(date +%s)
    
    # Write test
    if dd if=/dev/zero of="$test_file" bs=1M count=100 conv=fdatasync 2>/dev/null; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ $duration -gt 0 ]]; then
            local speed=$((104857600 / duration))  # 100MB in bytes
            echo "Write speed: $(format_bytes $speed)/s"
        fi
        
        rm -f "$test_file"
    else
        echo "${COLOR_RED}Write test failed${COLOR_RESET}"
        return 1
    fi
}

# Export USB detection functions
export -f detect_platform detect_usb_drives get_usb_drive_info
export -f is_usb_device get_usb_speed monitor_usb_changes
export -f list_usb_drives test_usb_write_speed
