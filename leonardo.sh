#!/usr/bin/env bash
# Leonardo AI Universal - Portable AI Deployment System
# Version: 7.0.0
# This file was automatically generated - DO NOT EDIT

set -euo pipefail


# ==== Component: src/core/header.sh ====
# ==============================================================================
# Leonardo AI Universal - Core Header
# ==============================================================================
# Description: Script header and metadata initialization
# Version: 7.0.0
# Dependencies: none
# ==============================================================================

# Script metadata
readonly LEONARDO_VERSION="7.0.0"
readonly LEONARDO_NAME="Leonardo AI Universal"
readonly LEONARDO_CODENAME="Phoenix"
readonly LEONARDO_BUILD_DATE="$(date -u +"%Y-%m-%d")"
readonly LEONARDO_AUTHORS=("Eric TM" "AI Assistant Team")
readonly LEONARDO_LICENSE="MIT"
readonly LEONARDO_REPO="https://github.com/officialerictm/LEO7"

# Runtime flags
LEONARDO_DEBUG="${LEONARDO_DEBUG:-false}"
LEONARDO_VERBOSE="${LEONARDO_VERBOSE:-false}"
LEONARDO_QUIET="${LEONARDO_QUIET:-false}"
LEONARDO_NO_COLOR="${LEONARDO_NO_COLOR:-false}"
LEONARDO_MAIN_CALLED=false

# ASCII Art Logo
LEONARDO_LOGO='
    __    _______  ____     _   _____    ____  ____   ____ 
   / /   / ____/ / __ \   / | / /   |  / __ \/ __ \ / __ \
  / /   / __/   / / / /  /  |/ / /| | / /_/ / / / // / / /
 / /___/ /___  / /_/ /  / /|  / ___ |/ _, _/ /_/ // /_/ / 
/_____/_____/  \____/  /_/ |_/_/  |_/_/ |_/_____/ \____/  
'

# Hacker-style banner variations
LEONARDO_BANNERS=(
'
 ╔═══════════════════════════════════════════════════════════╗
 ║  _     _____ ___  _   _   _    ____  ____   ___          ║
 ║ | |   | ____/ _ \| \ | | / \  |  _ \|  _ \ / _ \         ║
 ║ | |   |  _|| | | |  \| |/ _ \ | |_) | | | | | | |        ║
 ║ | |___| |__| |_| | |\  / ___ \|  _ <| |_| | |_| |        ║
 ║ |_____|_____\___/|_| \/_/   \_\_| \_\____/ \___/         ║
 ║                                                           ║
 ║        >> PORTABLE AI DEPLOYMENT SYSTEM v7.0 <<           ║
 ╚═══════════════════════════════════════════════════════════╝
'
'
 ┌─────────────────────────────────────────────────────────┐
 │ ▄▄▌  ▄▄▄ .       ▐ ▄  ▄▄▄· ▄▄▄  ·▄▄▄▄       ▄▄▄       │
 │ ██•  ▀▄.▀·▪     •█▌▐█▐█ ▀█ ▀▄ █·██▪ ██ ▪     ▀▄ █·     │
 │ ██▪  ▐▀▀▪▄ ▄█▀▄ ▐█▐▐▌▄█▀▀█ ▐▀▀▄ ▐█· ▐█▌ ▄█▀▄ ▐▀▀▄      │
 │ ▐█▌▐▌▐█▄▄▌▐█▌.▐▌██▐█▌▐█ ▪▐▌▐█•█▌██. ██ ▐█▌.▐▌▐█•█▌     │
 │ .▀▀▀  ▀▀▀  ▀█▄▀▪▀▀ █▪ ▀  ▀ .▀  ▀▀▀▀▀▀• ▀█▄▀▪.▀  ▀     │
 │                                                         │
 │         [ DEPLOY ANYWHERE • RUN EVERYWHERE ]            │
 └─────────────────────────────────────────────────────────┘
'
)

# Function to display version info
leonardo_version() {
    echo "$LEONARDO_NAME v$LEONARDO_VERSION ($LEONARDO_CODENAME)"
    echo "Build Date: $LEONARDO_BUILD_DATE"
    echo "Repository: $LEONARDO_REPO"
    echo "License: $LEONARDO_LICENSE"
}

# Function to display a random banner
leonardo_banner() {
    local banner_count=${#LEONARDO_BANNERS[@]}
    local random_index=$((RANDOM % banner_count))
    echo -e "${LEONARDO_BANNERS[$random_index]}"
}

# Initialize header
if [[ "$LEONARDO_QUIET" != "true" ]] && [[ "$LEONARDO_DEBUG" == "true" ]]; then
    echo "[DEBUG] Leonardo AI Universal v$LEONARDO_VERSION initializing..."
fi

# ==== Component: src/core/config.sh ====
# ==============================================================================
# Leonardo AI Universal - Configuration
# ==============================================================================
# Description: Global configuration and constants
# Version: 7.0.0
# Dependencies: header.sh, termfix.sh
# ==============================================================================

# Version and metadata (from header, but available globally)
readonly LEONARDO_CONFIG_VERSION="7.0.0"

# Deployment modes
readonly LEONARDO_DEPLOYMENT_MODES=(
    "usb:USB Drive - Portable AI on any USB device"
    "local:Local Install - Run on this machine"
    "container:Container - Docker/Podman deployment"
    "cloud:Cloud - Deploy to cloud instances"
    "airgap:Air-Gapped - Offline secure environments"
)

# File system defaults
readonly LEONARDO_DEFAULT_FS="exfat"  # Works on all platforms
readonly LEONARDO_USB_LABEL="LEONARDO"
readonly LEONARDO_MIN_USB_SIZE=$((16 * 1024 * 1024 * 1024))  # 16GB minimum

# Model registry configuration
readonly LEONARDO_MODEL_REGISTRY_URL="https://models.leonardo-ai.dev/registry.json"
readonly LEONARDO_MODEL_CACHE_DIR="${HOME}/.leonardo/models"
readonly LEONARDO_MODEL_TIMEOUT=300  # 5 minutes for model downloads

# Supported model formats
readonly LEONARDO_SUPPORTED_FORMATS=("gguf" "ggml" "bin" "pth" "safetensors")

# Default models by size category
declare -A LEONARDO_DEFAULT_MODELS=(
    ["tiny"]="gemma-2b"      # < 4GB
    ["small"]="llama3-8b"    # 4-8GB
    ["medium"]="mistral-7b"  # 8-16GB
    ["large"]="llama3-70b"   # > 16GB
)

# System requirements
declare -A LEONARDO_MIN_REQUIREMENTS=(
    ["ram"]=$((8 * 1024 * 1024 * 1024))      # 8GB minimum RAM
    ["disk"]=$((1 * 1024 * 1024 * 1024))     # 1GB minimum free disk
    ["cpu_cores"]=4                           # 4 cores minimum
)

# UI Configuration
readonly LEONARDO_UI_WIDTH=60
readonly LEONARDO_UI_PADDING=2
readonly LEONARDO_SPINNER_CHARS="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
readonly LEONARDO_PROGRESS_STYLE="unicode"  # unicode, ascii, or simple

# Security settings
readonly LEONARDO_PARANOID_MODE="${LEONARDO_PARANOID_MODE:-true}"
readonly LEONARDO_VERIFY_CHECKSUMS="${LEONARDO_VERIFY_CHECKSUMS:-true}"
readonly LEONARDO_SECURE_DELETE="${LEONARDO_SECURE_DELETE:-true}"
readonly LEONARDO_AUDIT_LOG="${LEONARDO_AUDIT_LOG:-true}"

# Network configuration
readonly LEONARDO_USER_AGENT="Leonardo-AI-Universal/$LEONARDO_VERSION"
readonly LEONARDO_DOWNLOAD_RETRIES=3
readonly LEONARDO_DOWNLOAD_TIMEOUT=30
readonly LEONARDO_CHUNK_SIZE=$((1024 * 1024))  # 1MB chunks

# Paths and directories
readonly LEONARDO_BASE_DIR="${LEONARDO_BASE_DIR:-$HOME/.leonardo}"
readonly LEONARDO_TMP_DIR="${LEONARDO_TMP_DIR:-/tmp/leonardo-$$}"
readonly LEONARDO_LOG_DIR="${LEONARDO_LOG_DIR:-$LEONARDO_BASE_DIR/logs}"
readonly LEONARDO_CONFIG_FILE="${LEONARDO_CONFIG_FILE:-$LEONARDO_BASE_DIR/config.json}"

# USB health tracking
readonly LEONARDO_USB_HEALTH_FILE=".leonardo_health.json"
readonly LEONARDO_USB_WRITE_THRESHOLD=$((100 * 1024 * 1024 * 1024))  # 100GB warning threshold
readonly LEONARDO_USB_CYCLE_WARNING=10000  # Warn after 10k write cycles

# Model-specific settings
declare -A LEONARDO_MODEL_CONFIGS=(
    ["llama3-8b"]="context=8192,threads=auto,gpu_layers=auto"
    ["llama3-70b"]="context=4096,threads=auto,gpu_layers=35"
    ["mistral-7b"]="context=32768,threads=auto,gpu_layers=auto"
    ["mixtral-8x7b"]="context=32768,threads=auto,gpu_layers=24"
    ["gemma-2b"]="context=8192,threads=auto,gpu_layers=auto"
    ["gemma-7b"]="context=8192,threads=auto,gpu_layers=auto"
)

# Feature flags
readonly LEONARDO_FEATURES=(
    "usb_health_tracking:true"
    "model_router:true"
    "web_ui:true"
    "api_server:false"
    "telemetry:false"
    "auto_update:false"
    "experimental:false"
)

# Export configuration for use in other modules
export LEONARDO_CONFIG_LOADED=true

# ==== Component: src/utils/colors.sh ====
# ==============================================================================
# Leonardo AI Universal - Color Definitions
# ==============================================================================
# Description: Terminal color codes and styling utilities
# Version: 7.0.0
# Dependencies: none
# ==============================================================================

# Check if colors should be disabled
if [[ "$LEONARDO_NO_COLOR" == "true" ]] || [[ ! -t 1 ]]; then
    # No colors - define empty variables
    NC=""
    BOLD=""
    DIM=""
    UNDERLINE=""
    BLINK=""
    REVERSE=""
    HIDDEN=""
    
    # Regular colors
    BLACK=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    MAGENTA=""
    CYAN=""
    WHITE=""
    
    # Bright colors
    BRIGHT_BLACK=""
    BRIGHT_RED=""
    BRIGHT_GREEN=""
    BRIGHT_YELLOW=""
    BRIGHT_BLUE=""
    BRIGHT_MAGENTA=""
    BRIGHT_CYAN=""
    BRIGHT_WHITE=""
    
    # Background colors
    BG_BLACK=""
    BG_RED=""
    BG_GREEN=""
    BG_YELLOW=""
    BG_BLUE=""
    BG_MAGENTA=""
    BG_CYAN=""
    BG_WHITE=""
else
    # Reset
    NC="\033[0m"       # No Color / Reset
    
    # Text attributes
    BOLD="\033[1m"
    DIM="\033[2m"
    UNDERLINE="\033[4m"
    BLINK="\033[5m"
    REVERSE="\033[7m"
    HIDDEN="\033[8m"
    
    # Regular colors
    BLACK="\033[0;30m"
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[0;33m"
    BLUE="\033[0;34m"
    MAGENTA="\033[0;35m"
    CYAN="\033[0;36m"
    WHITE="\033[0;37m"
    
    # Bright colors
    BRIGHT_BLACK="\033[0;90m"
    BRIGHT_RED="\033[0;91m"
    BRIGHT_GREEN="\033[0;92m"
    BRIGHT_YELLOW="\033[0;93m"
    BRIGHT_BLUE="\033[0;94m"
    BRIGHT_MAGENTA="\033[0;95m"
    BRIGHT_CYAN="\033[0;96m"
    BRIGHT_WHITE="\033[0;97m"
    
    # Background colors
    BG_BLACK="\033[40m"
    BG_RED="\033[41m"
    BG_GREEN="\033[42m"
    BG_YELLOW="\033[43m"
    BG_BLUE="\033[44m"
    BG_MAGENTA="\033[45m"
    BG_CYAN="\033[46m"
    BG_WHITE="\033[47m"
fi

# Special Leonardo color combinations (Matrix/hacker themed)
LEONARDO_PRIMARY="${GREEN}"
LEONARDO_SECONDARY="${CYAN}"
LEONARDO_ACCENT="${MAGENTA}"
LEONARDO_SUCCESS="${GREEN}"
LEONARDO_WARNING="${YELLOW}"
LEONARDO_ERROR="${RED}"
LEONARDO_INFO="${BLUE}"

# Functions for colored output
print_color() {
    local color="$1"
    shift
    echo -e "${color}$*${NC}"
}

print_bold() {
    echo -e "${BOLD}$*${NC}"
}

print_success() {
    echo -e "${LEONARDO_SUCCESS}✓${NC} $*"
}

print_error() {
    echo -e "${LEONARDO_ERROR}✗${NC} $*" >&2
}

print_warning() {
    echo -e "${LEONARDO_WARNING}⚠${NC} $*" >&2
}

print_info() {
    echo -e "${LEONARDO_INFO}ℹ${NC} $*"
}

# Progress indicators with colors
print_progress() {
    local percent="$1"
    local width="${2:-50}"
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    printf "\r${LEONARDO_PRIMARY}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "]${NC} ${BOLD}%3d%%${NC}" "$percent"
}

# Spinner animation
declare -a SPINNER_FRAMES=(
    "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"
)

print_spinner() {
    local message="$1"
    local frame_index="${2:-0}"
    local frame="${SPINNER_FRAMES[$frame_index]}"
    
    printf "\r${LEONARDO_PRIMARY}${frame}${NC} ${message}"
}

# Box drawing characters
BOX_HORIZONTAL="─"
BOX_VERTICAL="│"
BOX_TOP_LEFT="┌"
BOX_TOP_RIGHT="┐"
BOX_BOTTOM_LEFT="└"
BOX_BOTTOM_RIGHT="┘"
BOX_CROSS="┼"
BOX_T_DOWN="┬"
BOX_T_UP="┴"
BOX_T_RIGHT="├"
BOX_T_LEFT="┤"

# Double box drawing
BOX_DOUBLE_HORIZONTAL="═"
BOX_DOUBLE_VERTICAL="║"
BOX_DOUBLE_TOP_LEFT="╔"
BOX_DOUBLE_TOP_RIGHT="╗"
BOX_DOUBLE_BOTTOM_LEFT="╚"
BOX_DOUBLE_BOTTOM_RIGHT="╝"

# Function to draw a box around text
draw_box() {
    local title="$1"
    local content="$2"
    local width="${3:-60}"
    local box_color="${4:-$LEONARDO_PRIMARY}"
    
    # Top border
    echo -e "${box_color}${BOX_TOP_LEFT}$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")${BOX_TOP_RIGHT}${NC}"
    
    # Title if provided
    if [[ -n "$title" ]]; then
        local title_len=${#title}
        local padding=$(( (width - title_len - 2) / 2 ))
        echo -e "${box_color}${BOX_VERTICAL}${NC}$(printf "%${padding}s")${BOLD}${title}${NC}$(printf "%$((width - padding - title_len))s")${box_color}${BOX_VERTICAL}${NC}"
        echo -e "${box_color}${BOX_T_RIGHT}$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")${BOX_T_LEFT}${NC}"
    fi
    
    # Content
    while IFS= read -r line; do
        local line_len=${#line}
        echo -e "${box_color}${BOX_VERTICAL}${NC} ${line}$(printf "%$((width - line_len - 1))s")${box_color}${BOX_VERTICAL}${NC}"
    done <<< "$content"
    
    # Bottom border
    echo -e "${box_color}${BOX_BOTTOM_LEFT}$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")${BOX_BOTTOM_RIGHT}${NC}"
}

# Function to create a gradient effect (for fun ASCII art)
print_gradient() {
    local text="$1"
    local colors=("$BRIGHT_GREEN" "$GREEN" "$CYAN" "$BLUE" "$MAGENTA")
    local len=${#text}
    local color_count=${#colors[@]}
    
    for ((i=0; i<len; i++)); do
        local color_index=$((i % color_count))
        echo -en "${colors[$color_index]}${text:$i:1}"
    done
    echo -e "${NC}"
}

# Matrix rain effect character
get_matrix_char() {
    local chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
    local len=${#chars}
    local index=$((RANDOM % len))
    echo "${chars:$index:1}"
}

# Export color functions
export -f print_color print_bold print_success print_error print_warning print_info
export -f print_progress print_spinner draw_box print_gradient

# ==== Component: src/utils/logging.sh ====
# ==============================================================================
# Leonardo AI Universal - Logging System
# ==============================================================================
# Description: Centralized logging with levels, colors, and file output
# Version: 7.0.0
# Dependencies: colors.sh
# ==============================================================================

# Log levels
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_FATAL=4

# Current log level (can be overridden)
LEONARDO_LOG_LEVEL="${LEONARDO_LOG_LEVEL:-$LOG_LEVEL_INFO}"

# Log file settings
LEONARDO_LOG_FILE="${LEONARDO_LOG_FILE:-$LEONARDO_LOG_DIR/leonardo.log}"
LEONARDO_LOG_MAX_SIZE="${LEONARDO_LOG_MAX_SIZE:-10485760}"  # 10MB
LEONARDO_LOG_ROTATE_COUNT="${LEONARDO_LOG_ROTATE_COUNT:-5}"

# Initialize logging
init_logging() {
    # Create log directory if it doesn't exist
    if [[ ! -d "$LEONARDO_LOG_DIR" ]]; then
        mkdir -p "$LEONARDO_LOG_DIR" 2>/dev/null || {
            echo "[WARNING] Could not create log directory: $LEONARDO_LOG_DIR" >&2
            LEONARDO_LOG_FILE="/tmp/leonardo-$$.log"
        }
    fi
    
    # Rotate logs if needed
    rotate_logs_if_needed
    
    # Log session start
    log_message "INFO" "=== Leonardo AI Universal Session Started ==="
    log_message "INFO" "Version: $LEONARDO_VERSION ($LEONARDO_CODENAME)"
    log_message "INFO" "PID: $$"
    log_message "INFO" "User: $(whoami)"
    log_message "INFO" "System: $(uname -s) $(uname -r)"
}

# Main logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local level_num
    
    # Convert level to number
    case "$level" in
        DEBUG) level_num=$LOG_LEVEL_DEBUG ;;
        INFO)  level_num=$LOG_LEVEL_INFO ;;
        WARN)  level_num=$LOG_LEVEL_WARN ;;
        ERROR) level_num=$LOG_LEVEL_ERROR ;;
        FATAL) level_num=$LOG_LEVEL_FATAL ;;
        *)     level_num=$LOG_LEVEL_INFO ;;
    esac
    
    # Check if we should log this level
    if [[ $level_num -lt $LEONARDO_LOG_LEVEL ]]; then
        return
    fi
    
    # Format the log entry
    local log_entry="[$timestamp] [$level] $message"
    
    # Write to log file if available
    if [[ -n "$LEONARDO_LOG_FILE" ]] && [[ "$LEONARDO_AUDIT_LOG" == "true" ]]; then
        echo "$log_entry" >> "$LEONARDO_LOG_FILE" 2>/dev/null
    fi
    
    # Output to console if not quiet
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        case "$level" in
            DEBUG)
                [[ "$LEONARDO_DEBUG" == "true" ]] && echo -e "${CYAN}[DEBUG]${NC} $message" >&2
                ;;
            INFO)
                [[ "$LEONARDO_VERBOSE" == "true" ]] && echo -e "${BLUE}[INFO]${NC} $message"
                ;;
            WARN)
                echo -e "${YELLOW}[WARN]${NC} $message" >&2
                ;;
            ERROR)
                echo -e "${RED}[ERROR]${NC} $message" >&2
                ;;
            FATAL)
                echo -e "${RED}${BOLD}[FATAL]${NC} $message" >&2
                ;;
        esac
    fi
    
    # Exit on fatal
    if [[ "$level" == "FATAL" ]]; then
        exit 1
    fi
}

# Rotate logs if they exceed max size
rotate_logs_if_needed() {
    if [[ ! -f "$LEONARDO_LOG_FILE" ]]; then
        return
    fi
    
    local file_size=$(stat -f%z "$LEONARDO_LOG_FILE" 2>/dev/null || stat -c%s "$LEONARDO_LOG_FILE" 2>/dev/null || echo 0)
    
    if [[ $file_size -gt $LEONARDO_LOG_MAX_SIZE ]]; then
        log_message "INFO" "Rotating log file (size: $file_size bytes)"
        
        # Rotate existing logs
        for ((i=$((LEONARDO_LOG_ROTATE_COUNT-1)); i>=1; i--)); do
            if [[ -f "$LEONARDO_LOG_FILE.$i" ]]; then
                mv "$LEONARDO_LOG_FILE.$i" "$LEONARDO_LOG_FILE.$((i+1))" 2>/dev/null
            fi
        done
        
        # Move current log to .1
        mv "$LEONARDO_LOG_FILE" "$LEONARDO_LOG_FILE.1" 2>/dev/null
        
        # Remove oldest log if it exists
        rm -f "$LEONARDO_LOG_FILE.$((LEONARDO_LOG_ROTATE_COUNT+1))" 2>/dev/null
    fi
}

# Log a command execution
log_command() {
    local command="$1"
    log_message "DEBUG" "Executing: $command"
    
    local start_time=$(date +%s)
    local output
    local exit_code
    
    # Execute and capture output
    output=$($command 2>&1)
    exit_code=$?
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ $exit_code -eq 0 ]]; then
        log_message "DEBUG" "Command completed successfully (${duration}s)"
    else
        log_message "ERROR" "Command failed with exit code $exit_code (${duration}s)"
        log_message "DEBUG" "Output: $output"
    fi
    
    echo "$output"
    return $exit_code
}

# Log system information
log_system_info() {
    log_message "INFO" "System Information:"
    log_message "INFO" "  OS: $(uname -s) $(uname -r)"
    log_message "INFO" "  Arch: $(uname -m)"
    log_message "INFO" "  CPU: $(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 'unknown') cores"
    log_message "INFO" "  Memory: $(free -h 2>/dev/null | awk '/^Mem:/ {print $2}' || echo 'unknown')"
    log_message "INFO" "  Shell: $SHELL"
    log_message "INFO" "  Bash: ${BASH_VERSION}"
}

# Cleanup function for logging
cleanup_logging() {
    log_message "INFO" "=== Leonardo AI Universal Session Ended ==="
    
    # Compress old logs if configured
    if [[ "${LEONARDO_COMPRESS_LOGS:-false}" == "true" ]]; then
        for ((i=2; i<=LEONARDO_LOG_ROTATE_COUNT; i++)); do
            if [[ -f "$LEONARDO_LOG_FILE.$i" ]] && [[ ! -f "$LEONARDO_LOG_FILE.$i.gz" ]]; then
                gzip "$LEONARDO_LOG_FILE.$i" 2>/dev/null
            fi
        done
    fi
}

# Export logging functions
export -f log_message log_command log_system_info

# ==== Component: src/utils/validation.sh ====
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

# ==== Component: src/utils/filesystem.sh ====
# ==============================================================================
# Leonardo AI Universal - File System Utilities
# ==============================================================================
# Description: File system operations, USB detection, and disk management
# Version: 7.0.0
# Dependencies: logging.sh, colors.sh, validation.sh
# ==============================================================================

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
    
    # Unmount if mounted
    unmount_device "$device"
    
    # Platform-specific formatting
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        case "$filesystem" in
            exfat)
                mkfs.exfat -n "$label" "$device" 2>&1 | while read -r line; do
                    log_message "DEBUG" "mkfs.exfat: $line"
                done
                ;;
            fat32|vfat)
                mkfs.vfat -F 32 -n "$label" "$device" 2>&1 | while read -r line; do
                    log_message "DEBUG" "mkfs.vfat: $line"
                done
                ;;
            ntfs)
                mkfs.ntfs -Q -L "$label" "$device" 2>&1 | while read -r line; do
                    log_message "DEBUG" "mkfs.ntfs: $line"
                done
                ;;
            ext4)
                mkfs.ext4 -L "$label" "$device" 2>&1 | while read -r line; do
                    log_message "DEBUG" "mkfs.ext4: $line"
                done
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

# ==== Component: src/utils/network.sh ====
# ==============================================================================
# Leonardo AI Universal - Network Utilities
# ==============================================================================
# Description: Network operations, downloads, and connectivity checks
# Version: 7.0.0
# Dependencies: logging.sh, colors.sh, validation.sh
# ==============================================================================

# Check internet connectivity
check_connectivity() {
    local timeout="${1:-5}"
    local test_hosts=("8.8.8.8" "1.1.1.1" "google.com")
    
    log_message "INFO" "Checking internet connectivity..."
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1; then
            log_message "DEBUG" "Connectivity check passed: $host"
            return 0
        fi
    done
    
    log_message "ERROR" "No internet connectivity detected"
    return 1
}

# Download file with progress
download_file() {
    local url="$1"
    local output_file="$2"
    local expected_checksum="${3:-}"
    local checksum_algo="${4:-sha256}"
    
    log_message "INFO" "Downloading: $url"
    log_message "DEBUG" "Output: $output_file"
    
    # Create output directory if needed
    local output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir"
    
    # Determine download tool
    local downloader=""
    if command -v curl >/dev/null 2>&1; then
        downloader="curl"
    elif command -v wget >/dev/null 2>&1; then
        downloader="wget"
    else
        log_message "ERROR" "No download tool available (need curl or wget)"
        return 1
    fi
    
    # Download with retry logic
    local retry=0
    local max_retries=$LEONARDO_DOWNLOAD_RETRIES
    
    while [[ $retry -le $max_retries ]]; do
        log_message "INFO" "Download attempt $((retry + 1)) of $((max_retries + 1))"
        
        if [[ "$downloader" == "curl" ]]; then
            if download_with_curl "$url" "$output_file"; then
                break
            fi
        else
            if download_with_wget "$url" "$output_file"; then
                break
            fi
        fi
        
        retry=$((retry + 1))
        if [[ $retry -le $max_retries ]]; then
            log_message "WARN" "Download failed, retrying in 5 seconds..."
            sleep 5
        fi
    done
    
    if [[ $retry -gt $max_retries ]]; then
        log_message "ERROR" "Download failed after $max_retries retries"
        return 1
    fi
    
    # Verify checksum if provided
    if [[ -n "$expected_checksum" ]]; then
        log_message "INFO" "Verifying checksum..."
        if ! validate_checksum "$output_file" "$expected_checksum" "$checksum_algo"; then
            safe_delete "$output_file"
            return 1
        fi
        log_message "INFO" "Checksum verified successfully"
    fi
    
    return 0
}

# Download with curl
download_with_curl() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.tmp"
    
    # Build curl command
    local curl_cmd=(
        curl
        --location                           # Follow redirects
        --fail                              # Fail on HTTP errors
        --silent                            # Silent mode
        --show-error                        # Show errors
        --connect-timeout "$LEONARDO_DOWNLOAD_TIMEOUT"
        --max-time 0                        # No timeout for download
        --retry 0                           # We handle retries ourselves
        --user-agent "$LEONARDO_USER_AGENT"
        --output "$temp_file"
    )
    
    # Add resume support if file exists
    if [[ -f "$temp_file" ]]; then
        curl_cmd+=(--continue-at -)
    fi
    
    # Show progress if not quiet
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        curl_cmd+=(--progress-bar)
    fi
    
    # Execute download
    "${curl_cmd[@]}" "$url" 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]+([0-9.]+[KMG]?)[[:space:]]+ ]]; then
            local percent="${BASH_REMATCH[1]}"
            print_progress "$percent" 50
        elif [[ -n "$line" ]]; then
            log_message "DEBUG" "curl: $line"
        fi
    done
    
    # Move temp file to final location
    if [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$output_file"
        return 0
    else
        return 1
    fi
}

# Download with wget
download_with_wget() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.tmp"
    
    # Build wget command
    local wget_cmd=(
        wget
        --quiet                             # Quiet mode
        --timeout="$LEONARDO_DOWNLOAD_TIMEOUT"
        --tries=1                          # We handle retries ourselves
        --user-agent="$LEONARDO_USER_AGENT"
        --output-document="$temp_file"
    )
    
    # Add resume support if file exists
    if [[ -f "$temp_file" ]]; then
        wget_cmd+=(--continue)
    fi
    
    # Show progress if not quiet
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        wget_cmd+=(--show-progress)
    fi
    
    # Execute download
    "${wget_cmd[@]}" "$url" 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ ([0-9]+)% ]]; then
            local percent="${BASH_REMATCH[1]}"
            print_progress "$percent" 50
        elif [[ -n "$line" ]]; then
            log_message "DEBUG" "wget: $line"
        fi
    done
    
    # Move temp file to final location
    if [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$output_file"
        return 0
    else
        return 1
    fi
}

# Download with parallel chunks (for large files)
download_parallel() {
    local url="$1"
    local output_file="$2"
    local num_chunks="${3:-4}"
    
    log_message "INFO" "Starting parallel download with $num_chunks chunks"
    
    # Get file size
    local file_size=$(get_remote_file_size "$url")
    if [[ -z "$file_size" ]] || [[ "$file_size" -eq 0 ]]; then
        log_message "WARN" "Cannot determine file size, falling back to regular download"
        return download_file "$url" "$output_file"
    fi
    
    local chunk_size=$((file_size / num_chunks))
    local temp_dir=$(create_temp_dir "leonardo-download")
    local pids=()
    
    # Download chunks in parallel
    for ((i=0; i<num_chunks; i++)); do
        local start=$((i * chunk_size))
        local end=$((start + chunk_size - 1))
        
        # Last chunk goes to end of file
        if [[ $i -eq $((num_chunks - 1)) ]]; then
            end=$((file_size - 1))
        fi
        
        local chunk_file="$temp_dir/chunk_$i"
        
        (
            download_range "$url" "$chunk_file" "$start" "$end"
        ) &
        
        pids+=($!)
    done
    
    # Wait for all downloads to complete
    local failed=false
    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            failed=true
        fi
    done
    
    if [[ "$failed" == "true" ]]; then
        log_message "ERROR" "One or more chunks failed to download"
        safe_delete "$temp_dir"
        return 1
    fi
    
    # Combine chunks
    log_message "INFO" "Combining chunks..."
    > "$output_file"
    for ((i=0; i<num_chunks; i++)); do
        cat "$temp_dir/chunk_$i" >> "$output_file"
    done
    
    # Cleanup
    safe_delete "$temp_dir"
    
    log_message "INFO" "Parallel download completed"
    return 0
}

# Download a byte range
download_range() {
    local url="$1"
    local output_file="$2"
    local start="$3"
    local end="$4"
    
    log_message "DEBUG" "Downloading range: bytes=$start-$end"
    
    if command -v curl >/dev/null 2>&1; then
        curl -s -L -H "Range: bytes=$start-$end" \
             --user-agent "$LEONARDO_USER_AGENT" \
             --output "$output_file" \
             "$url"
    else
        wget -q --header="Range: bytes=$start-$end" \
             --user-agent="$LEONARDO_USER_AGENT" \
             -O "$output_file" \
             "$url"
    fi
}

# Get remote file size
get_remote_file_size() {
    local url="$1"
    local size=""
    
    if command -v curl >/dev/null 2>&1; then
        size=$(curl -sI -L "$url" | grep -i "content-length" | tail -1 | awk '{print $2}' | tr -d '\r')
    else
        size=$(wget --spider -S "$url" 2>&1 | grep -i "content-length" | tail -1 | awk '{print $2}')
    fi
    
    echo "${size:-0}"
}

# Upload file (for telemetry or backups)
upload_file() {
    local file="$1"
    local url="$2"
    local method="${3:-POST}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "Upload file not found: $file"
        return 1
    fi
    
    log_message "INFO" "Uploading $file to $url"
    
    if command -v curl >/dev/null 2>&1; then
        curl -X "$method" \
             --fail \
             --silent \
             --show-error \
             --user-agent "$LEONARDO_USER_AGENT" \
             --data-binary "@$file" \
             "$url"
    else
        log_message "ERROR" "Upload requires curl"
        return 1
    fi
}

# Check for updates
check_for_updates() {
    local current_version="$1"
    local update_url="${2:-https://api.leonardo-ai.dev/version}"
    
    log_message "INFO" "Checking for updates..."
    
    local response
    if command -v curl >/dev/null 2>&1; then
        response=$(curl -s -L --max-time 10 "$update_url" 2>/dev/null)
    else
        response=$(wget -q -O- --timeout=10 "$update_url" 2>/dev/null)
    fi
    
    if [[ -z "$response" ]]; then
        log_message "WARN" "Could not check for updates"
        return 1
    fi
    
    # Parse version from response (assumes JSON with "version" field)
    local latest_version=$(echo "$response" | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
    
    if [[ -z "$latest_version" ]]; then
        log_message "WARN" "Could not parse version from response"
        return 1
    fi
    
    log_message "INFO" "Current version: $current_version"
    log_message "INFO" "Latest version: $latest_version"
    
    if [[ "$current_version" != "$latest_version" ]]; then
        echo "$latest_version"
        return 0
    else
        return 1
    fi
}

# Fetch model registry
fetch_model_registry() {
    local registry_url="${1:-$LEONARDO_MODEL_REGISTRY_URL}"
    local cache_file="${2:-$LEONARDO_MODEL_CACHE_DIR/registry.json}"
    local max_age="${3:-3600}"  # 1 hour default
    
    # Check cache
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null)))
        if [[ $cache_age -lt $max_age ]]; then
            log_message "DEBUG" "Using cached registry (age: ${cache_age}s)"
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Fetch fresh registry
    log_message "INFO" "Fetching model registry from $registry_url"
    
    local temp_file=$(create_temp_dir)/registry.json
    if download_file "$registry_url" "$temp_file"; then
        mkdir -p "$(dirname "$cache_file")"
        mv "$temp_file" "$cache_file"
        cat "$cache_file"
        return 0
    else
        # Fall back to cache if available
        if [[ -f "$cache_file" ]]; then
            log_message "WARN" "Using stale cache due to download failure"
            cat "$cache_file"
            return 0
        else
            return 1
        fi
    fi
}

# Export network functions
export -f check_connectivity download_file download_parallel
export -f get_remote_file_size check_for_updates fetch_model_registry

# ==== Component: src/core/main.sh ====
# ==============================================================================
# Leonardo AI Universal - Main Application Entry Point
# ==============================================================================
# Description: Main application logic and orchestration
# Version: 7.0.0
# Dependencies: all components
# ==============================================================================

# Main function - entry point for Leonardo
main() {
    # Mark that main has been called
    LEONARDO_MAIN_CALLED=true
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Show banner unless quiet mode
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        clear
        leonardo_banner
        echo
    fi
    
    # Initialize logging
    log_message "INFO" "Starting $LEONARDO_NAME v$LEONARDO_VERSION"
    
    # Check system requirements
    if ! check_system_requirements; then
        log_message "ERROR" "System requirements not met"
        exit 1
    fi
    
    # Main menu loop
    while true; do
        show_main_menu
        
        case "$MENU_CHOICE" in
            1) handle_create_usb ;;
            2) handle_manage_models ;;
            3) handle_verify_usb ;;
            4) handle_advanced_options ;;
            5) handle_about ;;
            0|q|Q) handle_exit ;;
            *) show_error "Invalid choice. Please try again." ;;
        esac
        
        # Add a pause unless we're exiting
        if [[ "$MENU_CHOICE" != "0" ]] && [[ "$MENU_CHOICE" != "q" ]] && [[ "$MENU_CHOICE" != "Q" ]]; then
            echo
            read -p "Press Enter to continue..."
        fi
    done
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                leonardo_version
                exit 0
                ;;
            -d|--debug)
                LEONARDO_DEBUG=true
                LEONARDO_VERBOSE=true
                shift
                ;;
            -q|--quiet)
                LEONARDO_QUIET=true
                shift
                ;;
            --no-color)
                LEONARDO_NO_COLOR=true
                shift
                ;;
            *)
                log_message "WARNING" "Unknown argument: $1"
                shift
                ;;
        esac
    done
}

# Show help information
show_help() {
    cat << EOF
$LEONARDO_NAME v$LEONARDO_VERSION

Usage: $(basename "$0") [OPTIONS]

OPTIONS:
    -h, --help      Show this help message
    -v, --version   Show version information
    -d, --debug     Enable debug mode (verbose output)
    -q, --quiet     Quiet mode (minimal output)
    --no-color      Disable colored output

EXAMPLES:
    $(basename "$0")           # Start interactive mode
    $(basename "$0") --help    # Show help
    $(basename "$0") --debug   # Run with debug output

For more information, visit: $LEONARDO_REPO
EOF
}

# Placeholder functions for menu items
handle_create_usb() {
    log_message "INFO" "Starting USB creation workflow..."
    show_info "USB creation feature coming soon!"
}

handle_manage_models() {
    log_message "INFO" "Opening model management..."
    show_info "Model management feature coming soon!"
}

handle_verify_usb() {
    log_message "INFO" "Starting USB verification..."
    show_info "USB verification feature coming soon!"
}

handle_advanced_options() {
    log_message "INFO" "Opening advanced options..."
    show_info "Advanced options coming soon!"
}

handle_about() {
    clear
    leonardo_banner
    echo
    leonardo_version
    echo
    echo "Authors: ${LEONARDO_AUTHORS[*]}"
    echo
    echo "Leonardo AI Universal is a portable AI deployment system that"
    echo "enables you to run AI models from a USB drive on any computer."
    echo
    echo "Features:"
    echo "  • Zero-trace operation - leaves no footprint on host systems"
    echo "  • Cross-platform support - works on Windows, macOS, and Linux"
    echo "  • Multiple AI models - supports various open-source LLMs"
    echo "  • Air-gap ready - works completely offline"
    echo "  • Paranoid security - designed with security first"
    echo
}

handle_exit() {
    log_message "INFO" "Shutting down Leonardo AI Universal..."
    echo
    echo "Thanks for using Leonardo AI Universal!"
    echo "May your models be swift and your USBs eternal! 🚀"
    echo
    exit 0
}

# Stub function for log_message (will be replaced by actual logging component)
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ "$LEONARDO_QUIET" == "true" ]] && [[ "$level" != "ERROR" ]]; then
        return
    fi
    
    case "$level" in
        ERROR)   echo -e "\033[0;31m[$timestamp] [ERROR] $message\033[0m" >&2 ;;
        WARNING) echo -e "\033[0;33m[$timestamp] [WARN]  $message\033[0m" ;;
        INFO)    [[ "$LEONARDO_VERBOSE" == "true" ]] && echo -e "\033[0;34m[$timestamp] [INFO]  $message\033[0m" ;;
        DEBUG)   [[ "$LEONARDO_DEBUG" == "true" ]] && echo -e "\033[0;36m[$timestamp] [DEBUG] $message\033[0m" ;;
    esac
}

# Stub function for show_main_menu
show_main_menu() {
    echo
    echo "╔════════════════════════════════════════════╗"
    echo "║          LEONARDO AI UNIVERSAL             ║"
    echo "║            MAIN MENU v7.0.0                ║"
    echo "╚════════════════════════════════════════════╝"
    echo
    echo "  1) Create Leonardo USB"
    echo "  2) Manage AI Models"
    echo "  3) Verify/Repair USB"
    echo "  4) Advanced Options"
    echo "  5) About Leonardo"
    echo
    echo "  0) Exit"
    echo
    read -p "Enter your choice [0-5]: " MENU_CHOICE
}

# Stub functions for UI elements
show_info() { echo -e "\033[0;36m[INFO] $1\033[0m"; }
show_error() { echo -e "\033[0;31m[ERROR] $1\033[0m" >&2; }

# Stub function for system requirements check
check_system_requirements() {
    # This will be replaced by actual system checking logic
    return 0
}

# ==== Footer ====
# If main hasn't been called, call it now
if [ "${LEONARDO_MAIN_CALLED:-false}" = "false" ]; then
    main "$@"
fi
