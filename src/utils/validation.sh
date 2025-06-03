#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Input Validation
# ==============================================================================
# Description: Input validation and sanitization utilities
# Version: 7.0.0
# Dependencies: logging.sh, colors.sh
# ==============================================================================

# Validation error handling
validation_error() {
    local field="$1"
    local message="$2"
    log_message "ERROR" "Validation failed for $field: $message"
    print_error "Invalid $field: $message"
    return 1
}

# Validate boolean value
validate_boolean() {
    local value="$1"
    local field="${2:-value}"
    
    case "${value,,}" in
        true|yes|y|1|on)
            echo "true"
            return 0
            ;;
        false|no|n|0|off)
            echo "false"
            return 0
            ;;
        *)
            validation_error "$field" "must be true/false, yes/no, 1/0, or on/off"
            return 1
            ;;
    esac
}

# Validate integer
validate_integer() {
    local value="$1"
    local field="${2:-value}"
    local min="${3:-}"
    local max="${4:-}"
    
    # Check if it's a valid integer
    if ! [[ "$value" =~ ^-?[0-9]+$ ]]; then
        validation_error "$field" "must be an integer"
        return 1
    fi
    
    # Check minimum
    if [[ -n "$min" ]] && [[ "$value" -lt "$min" ]]; then
        validation_error "$field" "must be at least $min"
        return 1
    fi
    
    # Check maximum
    if [[ -n "$max" ]] && [[ "$value" -gt "$max" ]]; then
        validation_error "$field" "must be at most $max"
        return 1
    fi
    
    echo "$value"
    return 0
}

# Validate file path
validate_path() {
    local path="$1"
    local field="${2:-path}"
    local must_exist="${3:-false}"
    local type="${4:-any}"  # file, directory, or any
    
    # Expand path
    path=$(realpath -m "$path" 2>/dev/null || echo "$path")
    
    # Check if path exists (if required)
    if [[ "$must_exist" == "true" ]]; then
        if [[ ! -e "$path" ]]; then
            validation_error "$field" "path does not exist: $path"
            return 1
        fi
        
        # Check type
        case "$type" in
            file)
                if [[ ! -f "$path" ]]; then
                    validation_error "$field" "not a file: $path"
                    return 1
                fi
                ;;
            directory)
                if [[ ! -d "$path" ]]; then
                    validation_error "$field" "not a directory: $path"
                    return 1
                fi
                ;;
        esac
    fi
    
    echo "$path"
    return 0
}

# Validate USB device
validate_usb_device() {
    local device="$1"
    local field="${2:-device}"
    
    # Remove /dev/ prefix if present
    device="${device#/dev/}"
    
    # Check if device exists
    if [[ ! -b "/dev/$device" ]]; then
        validation_error "$field" "device not found: /dev/$device"
        return 1
    fi
    
    # Check if it's a removable device
    local removable=$(cat "/sys/block/${device%%[0-9]*}/removable" 2>/dev/null || echo "0")
    if [[ "$removable" != "1" ]]; then
        validation_error "$field" "not a removable device: /dev/$device"
        return 1
    fi
    
    echo "/dev/$device"
    return 0
}

# Validate size (with units)
validate_size() {
    local size="$1"
    local field="${2:-size}"
    local min_bytes="${3:-0}"
    
    local bytes=0
    local number
    local unit
    
    # Parse number and unit
    if [[ "$size" =~ ^([0-9]+)([KMGT]?)B?$ ]]; then
        number="${BASH_REMATCH[1]}"
        unit="${BASH_REMATCH[2]}"
        
        # Convert to bytes
        case "$unit" in
            "")  bytes=$number ;;
            "K") bytes=$((number * 1024)) ;;
            "M") bytes=$((number * 1024 * 1024)) ;;
            "G") bytes=$((number * 1024 * 1024 * 1024)) ;;
            "T") bytes=$((number * 1024 * 1024 * 1024 * 1024)) ;;
        esac
    else
        validation_error "$field" "invalid size format (use: 16GB, 1024MB, etc.)"
        return 1
    fi
    
    # Check minimum
    if [[ "$bytes" -lt "$min_bytes" ]]; then
        local min_human=$(format_bytes "$min_bytes")
        validation_error "$field" "must be at least $min_human"
        return 1
    fi
    
    echo "$bytes"
    return 0
}

# Validate URL
validate_url() {
    local url="$1"
    local field="${2:-URL}"
    local check_exists="${3:-false}"
    
    # Basic URL format validation
    if ! [[ "$url" =~ ^https?://[A-Za-z0-9.-]+(:[0-9]+)?(/.*)?$ ]]; then
        validation_error "$field" "invalid URL format"
        return 1
    fi
    
    # Check if URL exists (optional)
    if [[ "$check_exists" == "true" ]]; then
        if ! curl -fsS --head "$url" >/dev/null 2>&1; then
            validation_error "$field" "URL is not accessible"
            return 1
        fi
    fi
    
    echo "$url"
    return 0
}

# Validate checksum
validate_checksum() {
    local file="$1"
    local expected="$2"
    local algorithm="${3:-sha256}"
    local field="${4:-checksum}"
    
    if [[ ! -f "$file" ]]; then
        validation_error "$field" "file not found: $file"
        return 1
    fi
    
    local actual
    case "$algorithm" in
        md5)    actual=$(md5sum "$file" 2>/dev/null | cut -d' ' -f1) ;;
        sha1)   actual=$(sha1sum "$file" 2>/dev/null | cut -d' ' -f1) ;;
        sha256) actual=$(sha256sum "$file" 2>/dev/null | cut -d' ' -f1) ;;
        sha512) actual=$(sha512sum "$file" 2>/dev/null | cut -d' ' -f1) ;;
        *)
            validation_error "$field" "unknown algorithm: $algorithm"
            return 1
            ;;
    esac
    
    if [[ "$actual" != "$expected" ]]; then
        validation_error "$field" "mismatch (expected: $expected, got: $actual)"
        return 1
    fi
    
    log_message "DEBUG" "Checksum verified: $file"
    return 0
}

# Validate model ID
validate_model_id() {
    local model_id="$1"
    local field="${2:-model}"
    
    # Check format (alphanumeric with dashes)
    if ! [[ "$model_id" =~ ^[a-z0-9-]+$ ]]; then
        validation_error "$field" "invalid format (use lowercase alphanumeric and dashes)"
        return 1
    fi
    
    echo "$model_id"
    return 0
}

# Validate platform
validate_platform() {
    local platform="$1"
    local field="${2:-platform}"
    
    case "$platform" in
        linux|macos|darwin|windows)
            echo "$platform"
            return 0
            ;;
        *)
            validation_error "$field" "unsupported platform (use: linux, macos, windows)"
            return 1
            ;;
    esac
}

# Validate permissions
validate_permissions() {
    local path="$1"
    local required_perms="$2"  # e.g., "rwx" or "r"
    local field="${3:-permissions}"
    
    if [[ ! -e "$path" ]]; then
        validation_error "$field" "path does not exist: $path"
        return 1
    fi
    
    local missing_perms=""
    
    if [[ "$required_perms" == *"r"* ]] && [[ ! -r "$path" ]]; then
        missing_perms+="read "
    fi
    
    if [[ "$required_perms" == *"w"* ]] && [[ ! -w "$path" ]]; then
        missing_perms+="write "
    fi
    
    if [[ "$required_perms" == *"x"* ]] && [[ ! -x "$path" ]]; then
        missing_perms+="execute "
    fi
    
    if [[ -n "$missing_perms" ]]; then
        validation_error "$field" "missing permissions: $missing_perms"
        return 1
    fi
    
    return 0
}

# Format bytes to human readable
format_bytes() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    
    while [[ "$bytes" -ge 1024 ]] && [[ "$unit" -lt 4 ]]; do
        bytes=$((bytes / 1024))
        unit=$((unit + 1))
    done
    
    echo "${bytes}${units[$unit]}"
}

# Sanitize string for safe use
sanitize_string() {
    local input="$1"
    local allow_spaces="${2:-false}"
    
    # Remove control characters and non-printable chars
    input=$(echo "$input" | tr -cd '[:print:]')
    
    # Remove or replace problematic characters
    if [[ "$allow_spaces" == "true" ]]; then
        input=$(echo "$input" | sed 's/[^a-zA-Z0-9 ._-]//g')
    else
        input=$(echo "$input" | sed 's/[^a-zA-Z0-9._-]//g')
    fi
    
    echo "$input"
}

# Interactive confirmation
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-n}"  # y or n
    
    local yn_prompt
    if [[ "$default" == "y" ]]; then
        yn_prompt="[Y/n]"
    else
        yn_prompt="[y/N]"
    fi
    
    echo -en "${LEONARDO_PRIMARY}➤${NC} $prompt $yn_prompt "
    
    local response
    read -r response
    
    # Use default if empty
    if [[ -z "$response" ]]; then
        response="$default"
    fi
    
    [[ "${response,,}" == "y" ]]
}

# Check system requirements
check_system_requirements() {
    local errors=0
    
    # Check for required commands
    local required_commands=("curl" "tar" "gzip" "awk" "sed")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_message "ERROR" "Required command not found: $cmd"
            ((errors++))
        fi
    done
    
    # Check for disk space (at least 1GB free)
    local available_mb
    case "$LEONARDO_PLATFORM" in
        "macos")
            available_mb=$(df -m "$HOME" | awk 'NR==2 {print $4}')
            ;;
        "linux")
            available_mb=$(df -BM "$HOME" | awk 'NR==2 {print $4}' | sed 's/M//')
            ;;
        *)
            available_mb=2048  # Default assume enough space
            ;;
    esac
    
    if [[ $available_mb -lt 1024 ]]; then
        log_message "ERROR" "Insufficient disk space. Need at least 1GB free."
        ((errors++))
    fi
    
    # Check for write permissions
    if ! touch "$HOME/.leonardo_test_$$" 2>/dev/null; then
        log_message "ERROR" "No write permissions in home directory"
        ((errors++))
    else
        rm -f "$HOME/.leonardo_test_$$"
    fi
    
    return $errors
}

# Export all validation functions
export -f validation_error
export -f validate_boolean
export -f validate_integer
export -f validate_path
export -f validate_usb_device
export -f validate_size
export -f validate_url
export -f validate_checksum
export -f validate_model_id
export -f validate_platform
export -f validate_permissions
export -f format_bytes
export -f sanitize_string
export -f confirm
export -f check_system_requirements
