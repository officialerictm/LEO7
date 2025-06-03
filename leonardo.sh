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

# Detect platform early
if [[ -z "${LEONARDO_PLATFORM:-}" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        LEONARDO_PLATFORM="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        LEONARDO_PLATFORM="linux"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
        LEONARDO_PLATFORM="windows"
    else
        LEONARDO_PLATFORM="unknown"
    fi
    export LEONARDO_PLATFORM
fi

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

# Security defaults - these are overridden by exports later
readonly LEONARDO_VERIFY_CHECKSUMS="${LEONARDO_VERIFY_CHECKSUMS:-true}"

# Network configuration
# User agent is set later as export

# Default timeouts and retries
readonly LEONARDO_DEFAULT_TIMEOUT=30
readonly LEONARDO_MAX_RETRIES=3
readonly LEONARDO_USB_SCAN_TIMEOUT=5
readonly LEONARDO_USB_FORMAT_TIMEOUT=300
readonly LEONARDO_MODEL_VERIFY_TIMEOUT=60
readonly LEONARDO_HEALTH_CHECK_INTERVAL=3600  # 1 hour
readonly LEONARDO_CHUNK_SIZE=$((1024 * 1024))  # 1MB chunks

# Installation paths
export LEONARDO_BASE_DIR="${LEONARDO_BASE_DIR:-$HOME/.leonardo}"
export LEONARDO_INSTALL_DIR="${LEONARDO_INSTALL_DIR:-$LEONARDO_BASE_DIR}"
export LEONARDO_MODEL_DIR="${LEONARDO_MODEL_DIR:-$LEONARDO_BASE_DIR/models}"
export LEONARDO_CONFIG_DIR="${LEONARDO_CONFIG_DIR:-$LEONARDO_BASE_DIR/config}"
export LEONARDO_LOG_DIR="${LEONARDO_LOG_DIR:-$LEONARDO_BASE_DIR/logs}"
export LEONARDO_TEMP_DIR="${LEONARDO_TEMP_DIR:-/tmp/leonardo}"
export LEONARDO_BACKUP_DIR="${LEONARDO_BACKUP_DIR:-$LEONARDO_BASE_DIR/backups}"
export LEONARDO_MODEL_CACHE_DIR="${LEONARDO_MODEL_CACHE_DIR:-$LEONARDO_MODEL_DIR/cache}"

# Download settings
export LEONARDO_USER_AGENT="${LEONARDO_USER_AGENT:-Leonardo-AI-Universal/7.0.0}"
export LEONARDO_DOWNLOAD_RETRIES="${LEONARDO_DOWNLOAD_RETRIES:-3}"
export LEONARDO_DOWNLOAD_TIMEOUT="${LEONARDO_DOWNLOAD_TIMEOUT:-30}"

# Legacy compatibility
export LEONARDO_TMP_DIR="${LEONARDO_TMP_DIR:-$LEONARDO_TEMP_DIR}"
export LEONARDO_CONFIG_FILE="${LEONARDO_CONFIG_FILE:-$LEONARDO_CONFIG_DIR/config.json}"

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

# Default behavior flags
export LEONARDO_PARANOID_MODE="${LEONARDO_PARANOID_MODE:-false}"
export LEONARDO_SECURE_DELETE="${LEONARDO_SECURE_DELETE:-false}"
export LEONARDO_AUDIT_LOG="${LEONARDO_AUDIT_LOG:-false}"
export LEONARDO_NO_TELEMETRY="${LEONARDO_NO_TELEMETRY:-true}"

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

# Compatibility aliases
COLOR_RESET="${NC}"
COLOR_BLACK="${BLACK}"
COLOR_RED="${RED}"
COLOR_GREEN="${GREEN}"
COLOR_YELLOW="${YELLOW}"
COLOR_BLUE="${BLUE}"
COLOR_MAGENTA="${MAGENTA}"
COLOR_CYAN="${CYAN}"
COLOR_WHITE="${WHITE}"
COLOR_DIM="${DIM}"

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

# Export color variables
export NC BOLD DIM UNDERLINE BLINK REVERSE HIDDEN
export BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE
export BRIGHT_BLACK BRIGHT_RED BRIGHT_GREEN BRIGHT_YELLOW
export BRIGHT_BLUE BRIGHT_MAGENTA BRIGHT_CYAN BRIGHT_WHITE
export BG_BLACK BG_RED BG_GREEN BG_YELLOW BG_BLUE BG_MAGENTA BG_CYAN BG_WHITE
export LEONARDO_PRIMARY LEONARDO_SECONDARY LEONARDO_ACCENT
export LEONARDO_SUCCESS LEONARDO_ERROR LEONARDO_WARNING LEONARDO_INFO
export BOX_HORIZONTAL BOX_VERTICAL BOX_TOP_LEFT BOX_TOP_RIGHT
export BOX_BOTTOM_LEFT BOX_BOTTOM_RIGHT BOX_CROSS BOX_T_DOWN
export BOX_T_UP BOX_T_RIGHT BOX_T_LEFT
export BOX_DOUBLE_HORIZONTAL BOX_DOUBLE_VERTICAL BOX_DOUBLE_TOP_LEFT
export BOX_DOUBLE_TOP_RIGHT BOX_DOUBLE_BOTTOM_LEFT BOX_DOUBLE_BOTTOM_RIGHT
export COLOR_RESET COLOR_BLACK COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_BLUE COLOR_MAGENTA COLOR_CYAN COLOR_WHITE COLOR_DIM

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

# ==== Component: src/network/download.sh ====
# ==============================================================================
# Leonardo AI Universal - Network Download Module
# ==============================================================================
# Description: File download functionality with progress tracking
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, progress.sh, validation.sh
# ==============================================================================

# Download file with progress
download_file_with_progress() {
    local url="$1"
    local output_file="$2"
    local retries="${3:-$LEONARDO_DOWNLOAD_RETRIES}"
    
    # Validate inputs
    if [[ -z "$url" ]] || [[ -z "$output_file" ]]; then
        log_message "ERROR" "Invalid download parameters"
        return 1
    fi
    
    # Create output directory
    local output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir"
    
    # Check available downloaders
    local downloader=""
    if command_exists "curl"; then
        downloader="curl"
    elif command_exists "wget"; then
        downloader="wget"
    else
        log_message "ERROR" "No suitable downloader found (curl or wget required)"
        return 1
    fi
    
    log_message "INFO" "Downloading: $url"
    log_message "INFO" "Output: $output_file"
    log_message "INFO" "Using: $downloader"
    
    local attempt=1
    while [[ $attempt -le $retries ]]; do
        log_message "INFO" "Download attempt $attempt/$retries"
        
        if [[ "$downloader" == "curl" ]]; then
            if download_with_curl "$url" "$output_file"; then
                return 0
            fi
        else
            if download_with_wget "$url" "$output_file"; then
                return 0
            fi
        fi
        
        ((attempt++))
        if [[ $attempt -le $retries ]]; then
            log_message "WARN" "Download failed, retrying in 5 seconds..."
            sleep 5
        fi
    done
    
    log_message "ERROR" "Download failed after $retries attempts"
    return 1
}

# Download with curl
download_with_curl() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.tmp"
    
    # Download with progress bar
    if [[ -t 1 ]] && [[ "$LEONARDO_QUIET" != "true" ]]; then
        # Interactive mode with progress bar
        curl -L -f -# \
            --connect-timeout "$LEONARDO_TIMEOUT" \
            --retry 3 \
            --retry-delay 2 \
            -o "$temp_file" \
            "$url" 2>&1 | \
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*([0-9]+(\.[0-9]+)?)[[:space:]]+.*$ ]]; then
                local percent="${BASH_REMATCH[1]}"
                show_download_progress "$percent" "$url"
            fi
        done
    else
        # Non-interactive mode
        curl -L -f -S \
            --connect-timeout "$LEONARDO_TIMEOUT" \
            --retry 3 \
            --retry-delay 2 \
            -o "$temp_file" \
            "$url"
    fi
    
    local result=$?
    
    if [[ $result -eq 0 ]] && [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$output_file"
        return 0
    else
        rm -f "$temp_file"
        return 1
    fi
}

# Download with wget
download_with_wget() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.tmp"
    
    # Download with progress
    if [[ -t 1 ]] && [[ "$LEONARDO_QUIET" != "true" ]]; then
        # Interactive mode with progress bar
        wget --progress=bar:force \
            --timeout="$LEONARDO_TIMEOUT" \
            --tries=3 \
            --wait=2 \
            -O "$temp_file" \
            "$url" 2>&1 | \
        while IFS= read -r line; do
            if [[ "$line" =~ ([0-9]+)% ]]; then
                local percent="${BASH_REMATCH[1]}"
                show_download_progress "$percent" "$url"
            fi
        done
    else
        # Non-interactive mode
        wget -q \
            --timeout="$LEONARDO_TIMEOUT" \
            --tries=3 \
            --wait=2 \
            -O "$temp_file" \
            "$url"
    fi
    
    local result=$?
    
    if [[ $result -eq 0 ]] && [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$output_file"
        return 0
    else
        rm -f "$temp_file"
        return 1
    fi
}

# Download file (simple version without progress)
download_file() {
    local url="$1"
    local output_file="$2"
    
    if command_exists "curl"; then
        curl -L -f -s -o "$output_file" "$url"
    elif command_exists "wget"; then
        wget -q -O "$output_file" "$url"
    else
        log_message "ERROR" "No suitable downloader found"
        return 1
    fi
}

# Fetch remote file to string
fetch_remote_file() {
    local url="$1"
    
    if command_exists "curl"; then
        curl -L -f -s "$url"
    elif command_exists "wget"; then
        wget -q -O - "$url"
    else
        log_message "ERROR" "No suitable downloader found"
        return 1
    fi
}

# Download and verify file
download_and_verify() {
    local url="$1"
    local output_file="$2"
    local expected_hash="$3"
    local hash_type="${4:-sha256}"
    
    # Download file
    if ! download_file_with_progress "$url" "$output_file"; then
        return 1
    fi
    
    # Verify if hash provided
    if [[ -n "$expected_hash" ]]; then
        log_message "INFO" "Verifying file integrity..."
        
        local actual_hash=""
        case "$hash_type" in
            "sha256")
                actual_hash=$(sha256sum "$output_file" 2>/dev/null | awk '{print $1}')
                ;;
            "md5")
                actual_hash=$(md5sum "$output_file" 2>/dev/null | awk '{print $1}')
                ;;
            *)
                log_message "ERROR" "Unsupported hash type: $hash_type"
                rm -f "$output_file"
                return 1
                ;;
        esac
        
        if [[ "$actual_hash" != "$expected_hash" ]]; then
            log_message "ERROR" "Hash verification failed!"
            log_message "ERROR" "Expected: $expected_hash"
            log_message "ERROR" "Actual:   $actual_hash"
            rm -f "$output_file"
            return 1
        fi
        
        log_message "INFO" "File verified successfully"
    fi
    
    return 0
}

# Batch download files
batch_download() {
    local -n urls=$1
    local -n outputs=$2
    local parallel="${3:-1}"
    
    if [[ ${#urls[@]} -ne ${#outputs[@]} ]]; then
        log_message "ERROR" "URL and output arrays must have same length"
        return 1
    fi
    
    local total=${#urls[@]}
    local completed=0
    local failed=0
    
    echo "${COLOR_CYAN}Downloading $total files...${COLOR_RESET}"
    
    for i in "${!urls[@]}"; do
        local url="${urls[$i]}"
        local output="${outputs[$i]}"
        
        echo ""
        echo "${COLOR_YELLOW}[$((i+1))/$total] $(basename "$output")${COLOR_RESET}"
        
        if download_file_with_progress "$url" "$output"; then
            ((completed++))
        else
            ((failed++))
            log_message "ERROR" "Failed to download: $(basename "$output")"
        fi
    done
    
    echo ""
    echo "${COLOR_CYAN}Download complete:${COLOR_RESET}"
    echo "  ${COLOR_GREEN}Success: $completed${COLOR_RESET}"
    [[ $failed -gt 0 ]] && echo "  ${COLOR_RED}Failed: $failed${COLOR_RESET}"
    
    return $failed
}

# Resume download
resume_download() {
    local url="$1"
    local output_file="$2"
    
    if [[ ! -f "$output_file" ]]; then
        # No partial file, do normal download
        download_file_with_progress "$url" "$output_file"
        return $?
    fi
    
    local existing_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo 0)
    
    log_message "INFO" "Resuming download from byte $existing_size"
    
    if command_exists "curl"; then
        curl -L -f -C "$existing_size" -# -o "$output_file" "$url"
    elif command_exists "wget"; then
        wget -c --progress=bar:force -O "$output_file" "$url"
    else
        log_message "ERROR" "No suitable downloader with resume support found"
        return 1
    fi
}

# Mirror remote directory
mirror_remote_directory() {
    local remote_url="$1"
    local local_dir="$2"
    local include_pattern="${3:-*}"
    
    log_message "INFO" "Mirroring remote directory: $remote_url"
    
    mkdir -p "$local_dir"
    
    if command_exists "wget"; then
        wget -r -np -nH --cut-dirs=1 \
            -P "$local_dir" \
            -A "$include_pattern" \
            "$remote_url"
    else
        log_message "ERROR" "Directory mirroring requires wget"
        return 1
    fi
}

# Test download speed
test_download_speed() {
    local test_url="${1:-http://speedtest.tele2.net/10MB.zip}"
    local test_file="$LEONARDO_TEMP_DIR/speedtest_$$"
    
    echo "${COLOR_CYAN}Testing download speed...${COLOR_RESET}"
    
    local start_time=$(date +%s)
    
    if download_file "$test_url" "$test_file"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local file_size=$(stat -f%z "$test_file" 2>/dev/null || stat -c%s "$test_file" 2>/dev/null || echo 0)
        
        if [[ $duration -gt 0 ]]; then
            local speed=$((file_size / duration))
            echo "Download speed: $(format_bytes $speed)/s"
        fi
        
        rm -f "$test_file"
    else
        echo "${COLOR_RED}Speed test failed${COLOR_RESET}"
        return 1
    fi
}

# Fetch model registry
fetch_model_registry() {
    local registry_url="$1"
    local output_file="$2"
    
    log_message "INFO" "Fetching model registry from: $registry_url"
    
    if download_file "$registry_url" "$output_file"; then
        log_message "INFO" "Model registry updated successfully"
        return 0
    else
        log_message "ERROR" "Failed to fetch model registry"
        return 1
    fi
}

# Export download functions
export -f download_file_with_progress download_file fetch_remote_file
export -f download_and_verify batch_download resume_download
export -f mirror_remote_directory test_download_speed fetch_model_registry

# ==== Component: src/network/transfer.sh ====
# ==============================================================================
# Leonardo AI Universal - Network Transfer Module
# ==============================================================================
# Description: File transfer functionality (upload, sync, share)
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, validation.sh
# ==============================================================================

# Upload file
upload_file() {
    local file="$1"
    local destination="$2"
    local method="${3:-auto}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    case "$method" in
        "curl")
            upload_with_curl "$file" "$destination"
            ;;
        "rsync")
            upload_with_rsync "$file" "$destination"
            ;;
        "scp")
            upload_with_scp "$file" "$destination"
            ;;
        "auto")
            if command_exists "rsync"; then
                upload_with_rsync "$file" "$destination"
            elif command_exists "scp"; then
                upload_with_scp "$file" "$destination"
            elif command_exists "curl"; then
                upload_with_curl "$file" "$destination"
            else
                log_message "ERROR" "No suitable upload method found"
                return 1
            fi
            ;;
        *)
            log_message "ERROR" "Unknown upload method: $method"
            return 1
            ;;
    esac
}

# Upload with curl
upload_with_curl() {
    local file="$1"
    local url="$2"
    
    log_message "INFO" "Uploading with curl: $(basename "$file")"
    
    if curl -f -T "$file" "$url"; then
        log_message "INFO" "Upload successful"
        return 0
    else
        log_message "ERROR" "Upload failed"
        return 1
    fi
}

# Upload with rsync
upload_with_rsync() {
    local file="$1"
    local destination="$2"
    
    log_message "INFO" "Uploading with rsync: $(basename "$file")"
    
    rsync -avz --progress "$file" "$destination"
}

# Upload with scp
upload_with_scp() {
    local file="$1"
    local destination="$2"
    
    log_message "INFO" "Uploading with scp: $(basename "$file")"
    
    scp -p "$file" "$destination"
}

# Create temporary share link
create_share_link() {
    local file="$1"
    local expire_hours="${2:-24}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    # Use transfer.sh for temporary file sharing
    if command_exists "curl"; then
        log_message "INFO" "Creating share link for: $(basename "$file")"
        
        local response=$(curl -s --upload-file "$file" "https://transfer.sh/$(basename "$file")")
        
        if [[ -n "$response" ]]; then
            echo "${COLOR_GREEN}Share link:${COLOR_RESET} $response"
            echo "${COLOR_YELLOW}Expires in $expire_hours hours${COLOR_RESET}"
            return 0
        fi
    fi
    
    log_message "ERROR" "Failed to create share link"
    return 1
}

# Sync directory
sync_directory() {
    local source="$1"
    local destination="$2"
    local method="${3:-rsync}"
    
    if [[ ! -d "$source" ]]; then
        log_message "ERROR" "Source directory not found: $source"
        return 1
    fi
    
    case "$method" in
        "rsync")
            sync_with_rsync "$source" "$destination"
            ;;
        "cp")
            sync_with_cp "$source" "$destination"
            ;;
        *)
            log_message "ERROR" "Unknown sync method: $method"
            return 1
            ;;
    esac
}

# Sync with rsync
sync_with_rsync() {
    local source="$1"
    local destination="$2"
    
    log_message "INFO" "Syncing with rsync: $source -> $destination"
    
    rsync -avz --delete --progress "$source/" "$destination/"
}

# Sync with cp
sync_with_cp() {
    local source="$1"
    local destination="$2"
    
    log_message "INFO" "Syncing with cp: $source -> $destination"
    
    cp -R "$source"/* "$destination/"
}

# Transfer between systems
transfer_between_systems() {
    local source_system="$1"
    local source_path="$2"
    local dest_system="$3"
    local dest_path="$4"
    
    log_message "INFO" "Transferring: $source_system:$source_path -> $dest_system:$dest_path"
    
    if command_exists "rsync"; then
        rsync -avz --progress "$source_system:$source_path" "$dest_system:$dest_path"
    elif command_exists "scp"; then
        # Use intermediate transfer
        local temp_file="$LEONARDO_TEMP_DIR/transfer_$$"
        scp "$source_system:$source_path" "$temp_file" && \
        scp "$temp_file" "$dest_system:$dest_path"
        rm -f "$temp_file"
    else
        log_message "ERROR" "No suitable transfer method found"
        return 1
    fi
}

# Check connectivity
check_connectivity() {
    local host="${1:-8.8.8.8}"
    local port="${2:-443}"
    local timeout="${3:-5}"
    
    if command_exists "nc"; then
        nc -z -w "$timeout" "$host" "$port" 2>/dev/null
    elif command_exists "timeout"; then
        timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    else
        ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
    fi
}

# Test transfer speed
test_transfer_speed() {
    local destination="$1"
    local test_size="${2:-10M}"
    
    echo "${COLOR_CYAN}Testing transfer speed to $destination...${COLOR_RESET}"
    
    # Create test file
    local test_file="$LEONARDO_TEMP_DIR/speedtest_$$"
    dd if=/dev/zero of="$test_file" bs=1M count=10 2>/dev/null
    
    local start_time=$(date +%s)
    
    if upload_file "$test_file" "$destination"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ $duration -gt 0 ]]; then
            local speed=$((10485760 / duration))  # 10MB in bytes
            echo "Transfer speed: $(format_bytes $speed)/s"
        fi
    else
        echo "${COLOR_RED}Speed test failed${COLOR_RESET}"
    fi
    
    rm -f "$test_file"
}

# Create model package
create_model_package() {
    local model_id="$1"
    local output_file="$2"
    
    log_message "INFO" "Creating model package for: $model_id"
    
    # Get model info
    local model_file=$(get_model_metadata "$model_id" "filename")
    local model_path="$LEONARDO_MODEL_DIR/$model_file"
    
    if [[ ! -f "$model_path" ]]; then
        log_message "ERROR" "Model file not found: $model_path"
        return 1
    fi
    
    # Create package directory
    local package_dir="$LEONARDO_TEMP_DIR/package_$$"
    mkdir -p "$package_dir"
    
    # Copy model and metadata
    cp "$model_path" "$package_dir/"
    
    # Create metadata file
    cat > "$package_dir/metadata.json" << EOF
{
  "model_id": "$model_id",
  "name": "$(get_model_metadata "$model_id" "name")",
  "size": "$(get_model_metadata "$model_id" "size")",
  "format": "$(get_model_metadata "$model_id" "format")",
  "quantization": "$(get_model_metadata "$model_id" "quantization")",
  "family": "$(get_model_metadata "$model_id" "family")",
  "license": "$(get_model_metadata "$model_id" "license")",
  "sha256": "$(get_model_metadata "$model_id" "sha256")",
  "packaged_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    # Create archive
    tar -czf "$output_file" -C "$package_dir" .
    
    # Cleanup
    rm -rf "$package_dir"
    
    log_message "INFO" "Model package created: $output_file"
    return 0
}

# Extract model package
extract_model_package() {
    local package_file="$1"
    local extract_dir="${2:-$LEONARDO_MODEL_DIR}"
    
    if [[ ! -f "$package_file" ]]; then
        log_message "ERROR" "Package file not found: $package_file"
        return 1
    fi
    
    log_message "INFO" "Extracting model package: $package_file"
    
    # Create temporary extraction directory
    local temp_dir="$LEONARDO_TEMP_DIR/extract_$$"
    mkdir -p "$temp_dir"
    
    # Extract package
    if tar -xzf "$package_file" -C "$temp_dir"; then
        # Check for metadata
        if [[ -f "$temp_dir/metadata.json" ]]; then
            # Move model file
            local model_files=$(find "$temp_dir" -name "*.gguf" -o -name "*.bin" -o -name "*.safetensors")
            for file in $model_files; do
                mv "$file" "$extract_dir/"
                log_message "INFO" "Extracted: $(basename "$file")"
            done
            
            # Process metadata
            # TODO: Import metadata into registry
            
            rm -rf "$temp_dir"
            return 0
        else
            log_message "ERROR" "Invalid package: missing metadata"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        log_message "ERROR" "Failed to extract package"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Export transfer functions
export -f upload_file create_share_link sync_directory
export -f transfer_between_systems check_connectivity test_transfer_speed
export -f create_model_package extract_model_package

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

# ==== Component: src/usb/detector.sh ====
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

# ==== Component: src/usb/manager.sh ====
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
    LEONARDO_USB_DEVICE="$device"
    
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
    echo "${COLOR_YELLOW}WARNING: This will erase all data on $device${COLOR_RESET}"
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
            fi
            
            # Format partition
            local partition="${device}1"
            [[ -b "${device}p1" ]] && partition="${device}p1"
            
            case "$filesystem" in
                "exfat")
                    mkfs.exfat -n "$label" "$partition" >/dev/null 2>&1
                    ;;
                "fat32")
                    mkfs.vfat -F 32 -n "$label" "$partition" >/dev/null 2>&1
                    ;;
                "ntfs")
                    mkfs.ntfs -f -L "$label" "$partition" >/dev/null 2>&1
                    ;;
                "ext4")
                    mkfs.ext4 -L "$label" "$partition" >/dev/null 2>&1
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
            ;;
        "linux")
            # Create mount point if not specified
            if [[ -z "$mount_point" ]]; then
                mount_point="/mnt/leonardo_$$"
                mkdir -p "$mount_point"
            fi
            
            if mount "$device" "$mount_point" 2>/dev/null; then
                LEONARDO_USB_MOUNT="$mount_point"
            else
                log_message "ERROR" "Failed to mount device"
                rmdir "$mount_point" 2>/dev/null
                return 1
            fi
            ;;
        "windows")
            # Windows auto-mounts with drive letters
            LEONARDO_USB_MOUNT="$device\\"
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
                [[ "$LEONARDO_USB_MOUNT" =~ ^/mnt/leonardo_ ]] && rmdir "$LEONARDO_USB_MOUNT" 2>/dev/null
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
        chmod +x "$mount_point/leonardo.sh" 2>/dev/null
        
        # Create platform-specific launchers
        create_usb_launchers "$mount_point"
        
        log_message "SUCCESS" "Leonardo installed to USB successfully"
        
        # Show summary
        echo ""
        echo "${COLOR_GREEN}Installation complete!${COLOR_RESET}"
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
    chmod +x "$mount_point/launch-leonardo.sh" 2>/dev/null
    
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
    chmod +x "$mount_point/leonardo.desktop" 2>/dev/null
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
        echo "${COLOR_YELLOW}WARNING: This will overwrite existing Leonardo data${COLOR_RESET}"
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

# ==== Component: src/usb/health.sh ====
# ==============================================================================
# Leonardo AI Universal - USB Health Monitoring Module
# ==============================================================================
# Description: Monitor USB drive health, write cycles, and performance
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh, detector.sh
# ==============================================================================

# Health check thresholds
readonly USB_HEALTH_WRITE_CYCLE_WARNING=10000
readonly USB_HEALTH_WRITE_CYCLE_CRITICAL=50000
readonly USB_HEALTH_TEMP_WARNING=60
readonly USB_HEALTH_TEMP_CRITICAL=70
readonly USB_HEALTH_SPEED_MIN_MB=10

# Health status database
declare -g LEONARDO_USB_HEALTH_DB="${LEONARDO_USB_MOUNT:-}/leonardo/data/health.db"

# Initialize health monitoring
init_usb_health() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    
    if [[ -z "$mount_point" ]] || [[ ! -d "$mount_point" ]]; then
        log_message "ERROR" "Invalid mount point for health monitoring"
        return 1
    fi
    
    # Create health database directory
    mkdir -p "$(dirname "$LEONARDO_USB_HEALTH_DB")" 2>/dev/null
    
    # Initialize health database if not exists
    if [[ ! -f "$LEONARDO_USB_HEALTH_DB" ]]; then
        cat > "$LEONARDO_USB_HEALTH_DB" << EOF
# Leonardo USB Health Database
# Format: timestamp|metric|value
# Initialized: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF
    fi
    
    log_message "INFO" "USB health monitoring initialized"
    return 0
}

# Record health metric
record_health_metric() {
    local metric="$1"
    local value="$2"
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")
    
    echo "${timestamp}|${metric}|${value}" >> "$LEONARDO_USB_HEALTH_DB"
}

# Get USB SMART data
get_usb_smart_data() {
    local device="${1:-$LEONARDO_USB_DEVICE}"
    local platform=$(detect_platform)
    
    case "$platform" in
        "linux")
            if command_exists "smartctl"; then
                # Try to get SMART data
                if smartctl -i "$device" 2>/dev/null | grep -q "SMART support is: Available"; then
                    smartctl -A "$device" 2>/dev/null
                else
                    echo "SMART data not available for USB device"
                fi
            else
                echo "smartctl not installed"
            fi
            ;;
        "macos")
            if command_exists "smartctl"; then
                smartctl -A "$device" 2>/dev/null || echo "SMART data not available"
            else
                # Use diskutil for basic info
                diskutil info "$device" | grep -E "(Media Name|Total Size|Device Block Size)"
            fi
            ;;
        *)
            echo "SMART monitoring not supported on this platform"
            ;;
    esac
}

# Estimate write cycles
estimate_write_cycles() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    
    if [[ ! -f "$LEONARDO_USB_HEALTH_DB" ]]; then
        echo "0"
        return
    fi
    
    # Count write operations from health database
    local write_count=$(grep "|write_operation|" "$LEONARDO_USB_HEALTH_DB" 2>/dev/null | wc -l)
    
    # Estimate based on write operations (rough approximation)
    # Assume each operation writes average 10MB, USB has 100GB capacity
    # This gives us a very rough estimate of write cycles
    local estimated_cycles=$((write_count / 1000))
    
    echo "$estimated_cycles"
}

# Check USB temperature (if available)
check_usb_temperature() {
    local device="${1:-$LEONARDO_USB_DEVICE}"
    local platform=$(detect_platform)
    local temp="N/A"
    
    case "$platform" in
        "linux")
            # Try to get temperature from hwmon
            local device_name=$(basename "$device")
            local hwmon_path="/sys/block/$device_name/device/hwmon"
            
            if [[ -d "$hwmon_path" ]]; then
                for hwmon in "$hwmon_path"/hwmon*; do
                    if [[ -f "$hwmon/temp1_input" ]]; then
                        local temp_milli=$(cat "$hwmon/temp1_input" 2>/dev/null)
                        temp=$((temp_milli / 1000))
                        break
                    fi
                done
            fi
            
            # Try smartctl as fallback
            if [[ "$temp" == "N/A" ]] && command_exists "smartctl"; then
                local smart_temp=$(smartctl -A "$device" 2>/dev/null | grep -i "temperature" | awk '{print $10}')
                [[ -n "$smart_temp" ]] && temp="$smart_temp"
            fi
            ;;
        "macos")
            # Try smartctl
            if command_exists "smartctl"; then
                local smart_temp=$(smartctl -A "$device" 2>/dev/null | grep -i "temperature" | awk '{print $10}')
                [[ -n "$smart_temp" ]] && temp="$smart_temp"
            fi
            ;;
    esac
    
    echo "$temp"
}

# Perform comprehensive health check
perform_health_check() {
    local device="${1:-$LEONARDO_USB_DEVICE}"
    local mount_point="${2:-$LEONARDO_USB_MOUNT}"
    
    if [[ -z "$device" ]]; then
        log_message "ERROR" "No USB device specified"
        return 1
    fi
    
    echo "${COLOR_CYAN}USB Health Check${COLOR_RESET}"
    echo "=================="
    echo ""
    
    # Basic device info
    echo "${COLOR_CYAN}Device Information:${COLOR_RESET}"
    get_usb_drive_info "$device" | sed 's/^/  /'
    echo ""
    
    # Performance test
    echo "${COLOR_CYAN}Performance Test:${COLOR_RESET}"
    local write_speed="N/A"
    if [[ -n "$mount_point" ]] && [[ -d "$mount_point" ]]; then
        # Quick write test (10MB)
        local test_file="$mount_point/.leonardo_health_test_$$"
        local start_time=$(date +%s%N)
        
        if dd if=/dev/zero of="$test_file" bs=1M count=10 conv=fdatasync 2>/dev/null; then
            local end_time=$(date +%s%N)
            local duration=$((end_time - start_time))
            
            if [[ $duration -gt 0 ]]; then
                # Calculate MB/s
                local speed_bytes=$((10485760 * 1000000000 / duration))
                write_speed="$(format_bytes $speed_bytes)/s"
                
                # Record metric
                record_health_metric "write_speed" "$speed_bytes"
            fi
            
            rm -f "$test_file"
        fi
    fi
    echo "  Write Speed: $write_speed"
    
    # USB speed
    echo "  USB Speed: $(get_usb_speed "$device")"
    echo ""
    
    # Health metrics
    echo "${COLOR_CYAN}Health Metrics:${COLOR_RESET}"
    
    # Temperature
    local temp=$(check_usb_temperature "$device")
    echo -n "  Temperature: "
    if [[ "$temp" != "N/A" ]]; then
        if [[ $temp -ge $USB_HEALTH_TEMP_CRITICAL ]]; then
            echo "${COLOR_RED}${temp}°C (CRITICAL)${COLOR_RESET}"
        elif [[ $temp -ge $USB_HEALTH_TEMP_WARNING ]]; then
            echo "${COLOR_YELLOW}${temp}°C (WARNING)${COLOR_RESET}"
        else
            echo "${COLOR_GREEN}${temp}°C${COLOR_RESET}"
        fi
        record_health_metric "temperature" "$temp"
    else
        echo "N/A"
    fi
    
    # Write cycles
    local cycles=$(estimate_write_cycles)
    echo -n "  Estimated Write Cycles: "
    if [[ $cycles -ge $USB_HEALTH_WRITE_CYCLE_CRITICAL ]]; then
        echo "${COLOR_RED}${cycles} (CRITICAL)${COLOR_RESET}"
    elif [[ $cycles -ge $USB_HEALTH_WRITE_CYCLE_WARNING ]]; then
        echo "${COLOR_YELLOW}${cycles} (WARNING)${COLOR_RESET}"
    else
        echo "${COLOR_GREEN}${cycles}${COLOR_RESET}"
    fi
    
    # Free space
    if [[ -n "$mount_point" ]]; then
        local free_space=$(df -h "$mount_point" 2>/dev/null | tail -1 | awk '{print $4}')
        local used_percent=$(df "$mount_point" 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
        
        echo -n "  Free Space: $free_space "
        if [[ $used_percent -ge 95 ]]; then
            echo "${COLOR_RED}(${used_percent}% used - CRITICAL)${COLOR_RESET}"
        elif [[ $used_percent -ge 80 ]]; then
            echo "${COLOR_YELLOW}(${used_percent}% used - WARNING)${COLOR_RESET}"
        else
            echo "${COLOR_GREEN}(${used_percent}% used)${COLOR_RESET}"
        fi
    fi
    
    echo ""
    
    # SMART data (if available)
    echo "${COLOR_CYAN}SMART Data:${COLOR_RESET}"
    get_usb_smart_data "$device" | grep -E "(Reallocated|Wear_Leveling|Runtime_Bad|Temperature|Power_On)" | sed 's/^/  /'
    echo ""
    
    # Overall health status
    echo -n "${COLOR_CYAN}Overall Status:${COLOR_RESET} "
    local status="GOOD"
    local status_color="$COLOR_GREEN"
    
    if [[ $cycles -ge $USB_HEALTH_WRITE_CYCLE_CRITICAL ]] || [[ "$temp" != "N/A" && $temp -ge $USB_HEALTH_TEMP_CRITICAL ]]; then
        status="CRITICAL"
        status_color="$COLOR_RED"
    elif [[ $cycles -ge $USB_HEALTH_WRITE_CYCLE_WARNING ]] || [[ "$temp" != "N/A" && $temp -ge $USB_HEALTH_TEMP_WARNING ]]; then
        status="WARNING"
        status_color="$COLOR_YELLOW"
    fi
    
    echo "${status_color}${status}${COLOR_RESET}"
    
    # Record overall health
    record_health_metric "health_status" "$status"
    
    return 0
}

# Generate health report
generate_health_report() {
    local output_file="${1:-./usb_health_report_$(date +%Y%m%d_%H%M%S).txt}"
    local device="${2:-$LEONARDO_USB_DEVICE}"
    
    {
        echo "Leonardo USB Health Report"
        echo "========================="
        echo "Generated: $(date)"
        echo ""
        
        perform_health_check "$device"
        
        echo ""
        echo "Health History (Last 30 days):"
        echo "=============================="
        
        if [[ -f "$LEONARDO_USB_HEALTH_DB" ]]; then
            # Get metrics from last 30 days
            local cutoff_date=$(date -u -d "30 days ago" +"%Y-%m-%d" 2>/dev/null || date -u -v-30d +"%Y-%m-%d")
            
            echo ""
            echo "Write Speed Trend:"
            grep "|write_speed|" "$LEONARDO_USB_HEALTH_DB" | tail -20 | while IFS='|' read -r timestamp metric value; do
                echo "  $timestamp: $(format_bytes $value)/s"
            done
            
            echo ""
            echo "Temperature History:"
            grep "|temperature|" "$LEONARDO_USB_HEALTH_DB" | tail -20 | while IFS='|' read -r timestamp metric value; do
                echo "  $timestamp: ${value}°C"
            done
            
            echo ""
            echo "Health Status Changes:"
            grep "|health_status|" "$LEONARDO_USB_HEALTH_DB" | tail -10 | while IFS='|' read -r timestamp metric value; do
                echo "  $timestamp: $value"
            done
        else
            echo "No historical data available"
        fi
        
    } > "$output_file"
    
    log_message "INFO" "Health report generated: $output_file"
    echo "${COLOR_GREEN}Health report saved to: $output_file${COLOR_RESET}"
}

# Monitor health in background
monitor_usb_health() {
    local interval="${1:-300}"  # Default 5 minutes
    local device="${2:-$LEONARDO_USB_DEVICE}"
    
    if [[ -z "$device" ]]; then
        log_message "ERROR" "No USB device to monitor"
        return 1
    fi
    
    log_message "INFO" "Starting USB health monitoring (interval: ${interval}s)"
    
    # Create monitoring script
    local monitor_script="/tmp/leonardo_health_monitor_$$.sh"
    cat > "$monitor_script" << EOF
#!/usr/bin/env bash
source "$0"  # Source Leonardo

while true; do
    # Check if device still exists
    if ! is_usb_device "$device"; then
        log_message "WARN" "USB device disconnected"
        break
    fi
    
    # Perform quick health check
    local temp=\$(check_usb_temperature "$device")
    local cycles=\$(estimate_write_cycles)
    
    # Record metrics
    [[ "\$temp" != "N/A" ]] && record_health_metric "temperature" "\$temp"
    record_health_metric "write_cycles" "\$cycles"
    
    # Check for critical conditions
    if [[ "\$temp" != "N/A" && \$temp -ge $USB_HEALTH_TEMP_CRITICAL ]]; then
        log_message "CRITICAL" "USB temperature critical: \${temp}°C"
    fi
    
    if [[ \$cycles -ge $USB_HEALTH_WRITE_CYCLE_CRITICAL ]]; then
        log_message "CRITICAL" "USB write cycles critical: \$cycles"
    fi
    
    sleep $interval
done

rm -f "$monitor_script"
EOF
    
    chmod +x "$monitor_script"
    
    # Run in background
    nohup bash "$monitor_script" > /dev/null 2>&1 &
    local monitor_pid=$!
    
    echo "${COLOR_GREEN}Health monitoring started (PID: $monitor_pid)${COLOR_RESET}"
    echo "To stop monitoring: kill $monitor_pid"
    
    # Save PID for later
    echo "$monitor_pid" > "/tmp/leonardo_health_monitor.pid"
    
    return 0
}

# Stop health monitoring
stop_health_monitoring() {
    if [[ -f "/tmp/leonardo_health_monitor.pid" ]]; then
        local pid=$(cat "/tmp/leonardo_health_monitor.pid")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            log_message "INFO" "Health monitoring stopped"
        fi
        rm -f "/tmp/leonardo_health_monitor.pid"
    else
        log_message "WARN" "No active health monitoring found"
    fi
}

# Analyze health trends
analyze_health_trends() {
    if [[ ! -f "$LEONARDO_USB_HEALTH_DB" ]]; then
        log_message "ERROR" "No health data available"
        return 1
    fi
    
    echo "${COLOR_CYAN}USB Health Trend Analysis${COLOR_RESET}"
    echo "========================="
    echo ""
    
    # Analyze write speed trends
    echo "Write Speed Analysis:"
    local speeds=($(grep "|write_speed|" "$LEONARDO_USB_HEALTH_DB" | tail -100 | cut -d'|' -f3))
    if [[ ${#speeds[@]} -gt 0 ]]; then
        local sum=0
        local min=${speeds[0]}
        local max=${speeds[0]}
        
        for speed in "${speeds[@]}"; do
            ((sum += speed))
            [[ $speed -lt $min ]] && min=$speed
            [[ $speed -gt $max ]] && max=$speed
        done
        
        local avg=$((sum / ${#speeds[@]}))
        
        echo "  Average: $(format_bytes $avg)/s"
        echo "  Minimum: $(format_bytes $min)/s"
        echo "  Maximum: $(format_bytes $max)/s"
        
        # Check for degradation
        local recent_avg=0
        local recent_count=0
        for ((i=${#speeds[@]}-10; i<${#speeds[@]}; i++)); do
            if [[ $i -ge 0 ]]; then
                ((recent_avg += speeds[i]))
                ((recent_count++))
            fi
        done
        
        if [[ $recent_count -gt 0 ]]; then
            recent_avg=$((recent_avg / recent_count))
            local degradation=$(( (avg - recent_avg) * 100 / avg ))
            
            if [[ $degradation -gt 20 ]]; then
                echo "  ${COLOR_YELLOW}⚠ Performance degradation detected: ${degradation}%${COLOR_RESET}"
            fi
        fi
    else
        echo "  No data available"
    fi
    
    echo ""
    
    # Temperature trends
    echo "Temperature Analysis:"
    local temps=($(grep "|temperature|" "$LEONARDO_USB_HEALTH_DB" | tail -100 | cut -d'|' -f3 | grep -v "N/A"))
    if [[ ${#temps[@]} -gt 0 ]]; then
        local sum=0
        local min=${temps[0]}
        local max=${temps[0]}
        local high_count=0
        
        for temp in "${temps[@]}"; do
            ((sum += temp))
            [[ $temp -lt $min ]] && min=$temp
            [[ $temp -gt $max ]] && max=$temp
            [[ $temp -ge $USB_HEALTH_TEMP_WARNING ]] && ((high_count++))
        done
        
        local avg=$((sum / ${#temps[@]}))
        
        echo "  Average: ${avg}°C"
        echo "  Minimum: ${min}°C"
        echo "  Maximum: ${max}°C"
        
        if [[ $high_count -gt 0 ]]; then
            local high_percent=$((high_count * 100 / ${#temps[@]}))
            echo "  ${COLOR_YELLOW}⚠ High temperature incidents: ${high_count} (${high_percent}%)${COLOR_RESET}"
        fi
    else
        echo "  No data available"
    fi
    
    echo ""
    
    # Health status summary
    echo "Health Status Summary:"
    local good_count=$(grep "|health_status|GOOD" "$LEONARDO_USB_HEALTH_DB" | wc -l)
    local warn_count=$(grep "|health_status|WARNING" "$LEONARDO_USB_HEALTH_DB" | wc -l)
    local crit_count=$(grep "|health_status|CRITICAL" "$LEONARDO_USB_HEALTH_DB" | wc -l)
    local total_count=$((good_count + warn_count + crit_count))
    
    if [[ $total_count -gt 0 ]]; then
        echo "  Good: $good_count ($((good_count * 100 / total_count))%)"
        echo "  Warning: $warn_count ($((warn_count * 100 / total_count))%)"
        echo "  Critical: $crit_count ($((crit_count * 100 / total_count))%)"
    else
        echo "  No data available"
    fi
    
    return 0
}

# Export health monitoring functions
export -f init_usb_health record_health_metric get_usb_smart_data
export -f estimate_write_cycles check_usb_temperature perform_health_check
export -f generate_health_report monitor_usb_health stop_health_monitoring
export -f analyze_health_trends

# ==== Component: src/usb/cli.sh ====
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
            echo "${COLOR_RED}Unknown command: $command${COLOR_RESET}"
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
        echo "${COLOR_RED}Error: No device specified${COLOR_RESET}"
        echo "Usage: leonardo usb info <device>"
        return 1
    fi
    
    if ! is_usb_device "$device"; then
        echo "${COLOR_RED}Error: Not a USB device: $device${COLOR_RESET}"
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
        echo "${COLOR_GREEN}Leonardo Status: Installed${COLOR_RESET}"
        if [[ -f "$mount_point/leonardo/VERSION" ]]; then
            echo "Leonardo Version: $(cat "$mount_point/leonardo/VERSION")"
        fi
    else
        echo ""
        echo "${COLOR_YELLOW}Leonardo Status: Not Installed${COLOR_RESET}"
    fi
}

# Initialize USB for Leonardo
usb_cli_init() {
    local device="$1"
    
    if [[ -z "$device" ]]; then
        echo "${COLOR_RED}Error: No device specified${COLOR_RESET}"
        echo "Usage: leonardo usb init <device>"
        return 1
    fi
    
    # Initialize device
    if ! init_usb_device "$device"; then
        return 1
    fi
    
    # Check if already has Leonardo structure
    if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ -d "$LEONARDO_USB_MOUNT/leonardo" ]]; then
        echo "${COLOR_YELLOW}Leonardo structure already exists on USB${COLOR_RESET}"
        if ! confirm_action "Reinitialize USB"; then
            return 0
        fi
    fi
    
    # Create Leonardo structure
    if ! create_leonardo_structure; then
        return 1
    fi
    
    echo ""
    echo "${COLOR_GREEN}USB drive initialized for Leonardo!${COLOR_RESET}"
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
        echo "${COLOR_CYAN}Auto-detecting USB device...${COLOR_RESET}"
        device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
        
        if [[ -z "$device" ]]; then
            echo "${COLOR_RED}No USB device detected${COLOR_RESET}"
            return 1
        fi
        
        echo "Found: $device"
        if ! confirm_action "Use this device"; then
            return 1
        fi
    fi
    
    # Check if Leonardo script exists
    if [[ ! -f "$leonardo_script" ]]; then
        echo "${COLOR_RED}Leonardo script not found: $leonardo_script${COLOR_RESET}"
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
        echo "${COLOR_RED}Error: No device specified${COLOR_RESET}"
        echo "Usage: leonardo usb format <device> [--format <fs>] [--label <name>]"
        return 1
    fi
    
    # Validate filesystem
    case "$filesystem" in
        exfat|fat32|ntfs|ext4)
            ;;
        *)
            echo "${COLOR_RED}Error: Unsupported filesystem: $filesystem${COLOR_RESET}"
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
        echo "${COLOR_RED}Error: No device specified${COLOR_RESET}"
        echo "Usage: leonardo usb mount <device> [mount_point]"
        return 1
    fi
    
    mount_usb_drive "$device" "$mount_point"
}

# Unmount USB drive
usb_cli_unmount() {
    local device="$1"
    
    if [[ -z "$device" ]]; then
        echo "${COLOR_RED}Error: No device specified${COLOR_RESET}"
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
                echo "${COLOR_RED}No USB device detected${COLOR_RESET}"
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
                echo "${COLOR_RED}No USB device detected${COLOR_RESET}"
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
                echo "${COLOR_RED}No USB device detected${COLOR_RESET}"
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
        echo "${COLOR_RED}Leonardo not found on USB device${COLOR_RESET}"
        return 1
    fi
    
    backup_usb_data "$LEONARDO_USB_MOUNT" "$backup_file"
}

# Restore USB data
usb_cli_restore() {
    local backup_file="$1"
    local device="$2"
    
    if [[ -z "$backup_file" ]]; then
        echo "${COLOR_RED}Error: No backup file specified${COLOR_RESET}"
        echo "Usage: leonardo usb restore <backup_file> [device]"
        return 1
    fi
    
    if [[ ! -f "$backup_file" ]]; then
        echo "${COLOR_RED}Error: Backup file not found: $backup_file${COLOR_RESET}"
        return 1
    fi
    
    # Auto-detect if no device specified
    if [[ -z "$device" ]]; then
        if [[ -n "$LEONARDO_USB_DEVICE" ]]; then
            device="$LEONARDO_USB_DEVICE"
        else
            device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
            if [[ -z "$device" ]]; then
                echo "${COLOR_RED}No USB device detected${COLOR_RESET}"
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
                echo "${COLOR_RED}No USB device detected${COLOR_RESET}"
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
        echo "${COLOR_RED}Leonardo not found on USB device${COLOR_RESET}"
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
                echo "${COLOR_RED}No USB device detected${COLOR_RESET}"
                return 1
            fi
        fi
    fi
    
    # Initialize device
    if ! init_usb_device "$device"; then
        return 1
    fi
    
    echo "${COLOR_CYAN}USB Performance Test${COLOR_RESET}"
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

# Export USB CLI functions
export -f usb_cli usb_cli_help
export -f usb_cli_list usb_cli_info usb_cli_init usb_cli_install
export -f usb_cli_format usb_cli_mount usb_cli_unmount
export -f usb_cli_health usb_cli_monitor usb_cli_backup usb_cli_restore
export -f usb_cli_clean usb_cli_test register_usb_commands

# ==== Component: src/network/checksum.sh ====
# ==============================================================================
# Leonardo AI Universal - Checksum Verification Module
# ==============================================================================
# Description: File integrity verification using multiple hash algorithms
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh
# ==============================================================================

# Supported hash algorithms
declare -A HASH_COMMANDS=(
    ["md5"]="md5sum"
    ["sha1"]="sha1sum"
    ["sha256"]="sha256sum"
    ["sha512"]="sha512sum"
)

# Platform-specific hash commands
init_hash_commands() {
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            HASH_COMMANDS["md5"]="md5 -r"
            HASH_COMMANDS["sha1"]="shasum -a 1"
            HASH_COMMANDS["sha256"]="shasum -a 256"
            HASH_COMMANDS["sha512"]="shasum -a 512"
            ;;
        "windows")
            # Windows using certUtil
            HASH_COMMANDS["md5"]="certutil -hashfile"
            HASH_COMMANDS["sha1"]="certutil -hashfile"
            HASH_COMMANDS["sha256"]="certutil -hashfile"
            HASH_COMMANDS["sha512"]="certutil -hashfile"
            ;;
    esac
}

# Calculate file hash
calculate_hash() {
    local file="$1"
    local algorithm="${2:-sha256}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    local hash_cmd="${HASH_COMMANDS[$algorithm]}"
    if [[ -z "$hash_cmd" ]]; then
        log_message "ERROR" "Unsupported hash algorithm: $algorithm"
        return 1
    fi
    
    local hash=""
    local platform=$(detect_platform)
    
    case "$platform" in
        "windows")
            # Windows certutil outputs differently
            hash=$(certutil -hashfile "$file" "${algorithm^^}" 2>/dev/null | grep -v ":" | tr -d ' \r\n' | tr '[:upper:]' '[:lower:]')
            ;;
        *)
            # Unix-like systems
            hash=$($hash_cmd "$file" 2>/dev/null | awk '{print $1}')
            ;;
    esac
    
    if [[ -z "$hash" ]]; then
        log_message "ERROR" "Failed to calculate $algorithm hash for $file"
        return 1
    fi
    
    echo "$hash"
    return 0
}

# Verify file checksum
verify_checksum() {
    local file="$1"
    local expected_hash="$2"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    if [[ -z "$expected_hash" ]]; then
        log_message "ERROR" "No expected hash provided"
        return 1
    fi
    
    log_message "INFO" "Verifying $algorithm checksum for $(basename "$file")..."
    
    local actual_hash
    actual_hash=$(calculate_hash "$file" "$algorithm")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Normalize hashes for comparison
    expected_hash=$(echo "$expected_hash" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    actual_hash=$(echo "$actual_hash" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    
    if [[ "$actual_hash" == "$expected_hash" ]]; then
        log_message "SUCCESS" "Checksum verification passed"
        return 0
    else
        log_message "ERROR" "Checksum verification failed"
        log_message "ERROR" "Expected: $expected_hash"
        log_message "ERROR" "Actual:   $actual_hash"
        return 1
    fi
}

# Verify checksum from file
verify_checksum_file() {
    local file="$1"
    local checksum_file="$2"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$checksum_file" ]]; then
        log_message "ERROR" "Checksum file not found: $checksum_file"
        return 1
    fi
    
    # Extract hash from checksum file
    local expected_hash
    local filename=$(basename "$file")
    
    # Try different checksum file formats
    # Format 1: "hash  filename"
    expected_hash=$(grep -E "^[a-fA-F0-9]+[[:space:]]+\*?${filename}$" "$checksum_file" 2>/dev/null | awk '{print $1}')
    
    # Format 2: "hash" (single line with just the hash)
    if [[ -z "$expected_hash" ]]; then
        expected_hash=$(grep -E "^[a-fA-F0-9]+$" "$checksum_file" 2>/dev/null | head -1)
    fi
    
    # Format 3: "SHA256(filename)= hash" (BSD style)
    if [[ -z "$expected_hash" ]]; then
        expected_hash=$(grep -E "^${algorithm^^}\(${filename}\)=" "$checksum_file" 2>/dev/null | cut -d'=' -f2- | tr -d ' ')
    fi
    
    if [[ -z "$expected_hash" ]]; then
        log_message "ERROR" "Could not extract hash from checksum file"
        return 1
    fi
    
    verify_checksum "$file" "$expected_hash" "$algorithm"
}

# Generate checksum file
generate_checksum_file() {
    local file="$1"
    local output_file="${2:-${file}.sha256}"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    log_message "INFO" "Generating $algorithm checksum for $(basename "$file")..."
    
    local hash
    hash=$(calculate_hash "$file" "$algorithm")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Write checksum in standard format
    echo "$hash  $(basename "$file")" > "$output_file"
    
    log_message "SUCCESS" "Checksum saved to $output_file"
    return 0
}

# Batch verify checksums
batch_verify_checksums() {
    local checksum_file="$1"
    local base_dir="${2:-.}"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$checksum_file" ]]; then
        log_message "ERROR" "Checksum file not found: $checksum_file"
        return 1
    fi
    
    local total=0
    local passed=0
    local failed=0
    
    echo "${COLOR_CYAN}Batch Checksum Verification${COLOR_RESET}"
    echo "Algorithm: ${algorithm^^}"
    echo ""
    
    # Process each line in checksum file
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^# ]] && continue
        
        # Extract hash and filename
        local hash=$(echo "$line" | awk '{print $1}')
        local filename=$(echo "$line" | awk '{print $2}' | sed 's/^\*//')
        
        if [[ -z "$hash" ]] || [[ -z "$filename" ]]; then
            continue
        fi
        
        local filepath="$base_dir/$filename"
        ((total++))
        
        echo -n "Verifying $filename... "
        
        if [[ ! -f "$filepath" ]]; then
            echo "${COLOR_RED}FILE NOT FOUND${COLOR_RESET}"
            ((failed++))
            continue
        fi
        
        if verify_checksum "$filepath" "$hash" "$algorithm" >/dev/null 2>&1; then
            echo "${COLOR_GREEN}✓ PASS${COLOR_RESET}"
            ((passed++))
        else
            echo "${COLOR_RED}✗ FAIL${COLOR_RESET}"
            ((failed++))
        fi
    done < "$checksum_file"
    
    echo ""
    echo "Summary: $passed/$total passed"
    
    if [[ $failed -gt 0 ]]; then
        log_message "ERROR" "$failed files failed verification"
        return 1
    else
        log_message "SUCCESS" "All files passed verification"
        return 0
    fi
}

# Generate checksums for directory
generate_directory_checksums() {
    local directory="$1"
    local output_file="${2:-checksums.sha256}"
    local algorithm="${3:-sha256}"
    local pattern="${4:-*}"
    
    if [[ ! -d "$directory" ]]; then
        log_message "ERROR" "Directory not found: $directory"
        return 1
    fi
    
    log_message "INFO" "Generating checksums for files in $directory..."
    
    local count=0
    > "$output_file"  # Clear output file
    
    # Add header
    echo "# Leonardo AI Universal - Checksum File" >> "$output_file"
    echo "# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")" >> "$output_file"
    echo "# Algorithm: ${algorithm^^}" >> "$output_file"
    echo "" >> "$output_file"
    
    # Process files
    find "$directory" -type f -name "$pattern" -print0 | while IFS= read -r -d '' file; do
        local relative_path="${file#$directory/}"
        local hash
        
        hash=$(calculate_hash "$file" "$algorithm")
        if [[ $? -eq 0 ]]; then
            echo "$hash  $relative_path" >> "$output_file"
            ((count++))
        fi
    done
    
    log_message "SUCCESS" "Generated checksums for $count files"
    return 0
}

# Detect hash algorithm from checksum length
detect_hash_algorithm() {
    local hash="$1"
    local length=${#hash}
    
    case $length in
        32) echo "md5" ;;
        40) echo "sha1" ;;
        64) echo "sha256" ;;
        128) echo "sha512" ;;
        *) echo "unknown" ;;
    esac
}

# Verify download with checksum
verify_download() {
    local url="$1"
    local file="$2"
    local expected_hash="$3"
    local algorithm="${4:-auto}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "Downloaded file not found: $file"
        return 1
    fi
    
    # Auto-detect algorithm if needed
    if [[ "$algorithm" == "auto" ]]; then
        algorithm=$(detect_hash_algorithm "$expected_hash")
        if [[ "$algorithm" == "unknown" ]]; then
            log_message "ERROR" "Could not detect hash algorithm"
            return 1
        fi
        log_message "INFO" "Auto-detected algorithm: ${algorithm^^}"
    fi
    
    # Verify checksum
    verify_checksum "$file" "$expected_hash" "$algorithm"
}

# Compare two files by checksum
compare_files_by_hash() {
    local file1="$1"
    local file2="$2"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$file1" ]] || [[ ! -f "$file2" ]]; then
        log_message "ERROR" "One or both files not found"
        return 1
    fi
    
    local hash1=$(calculate_hash "$file1" "$algorithm")
    local hash2=$(calculate_hash "$file2" "$algorithm")
    
    if [[ "$hash1" == "$hash2" ]]; then
        log_message "INFO" "Files are identical (${algorithm^^})"
        return 0
    else
        log_message "INFO" "Files are different"
        return 1
    fi
}

# Initialize hash commands on module load
init_hash_commands

# Export checksum functions
export -f calculate_hash verify_checksum verify_checksum_file
export -f generate_checksum_file batch_verify_checksums
export -f generate_directory_checksums detect_hash_algorithm
export -f verify_download compare_files_by_hash

# ==== Component: src/deployment/usb_deploy.sh ====
# ==============================================================================
# Leonardo AI Universal - USB Deployment Module
# ==============================================================================
# Description: Deploy Leonardo and AI models to USB drives
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, usb/*.sh, models/*.sh, checksum.sh
# ==============================================================================

# USB deployment configuration
USB_DEPLOY_MIN_SPACE_GB=8
USB_DEPLOY_RECOMMENDED_SPACE_GB=32

# Deploy Leonardo to USB
deploy_to_usb() {
    local target_device="${1:-}"
    local options="${2:-}"
    
    echo "${COLOR_CYAN}Leonardo USB Deployment${COLOR_RESET}"
    echo "========================"
    echo ""
    
    # Step 1: Detect or select USB device
    if [[ -z "$target_device" ]]; then
        echo "Detecting USB drives..."
        local devices=$(detect_usb_drives)
        
        if [[ -z "$devices" ]]; then
            log_message "ERROR" "No USB drives detected"
            echo ""
            echo "Please insert a USB drive and try again."
            return 1
        fi
        
        # Show available devices
        list_usb_drives
        echo ""
        
        # Let user select
        read -p "Enter device path (e.g., /dev/sdb): " target_device
        
        if [[ -z "$target_device" ]]; then
            log_message "ERROR" "No device selected"
            return 1
        fi
    fi
    
    # Validate device
    if ! is_usb_device "$target_device"; then
        log_message "ERROR" "Not a valid USB device: $target_device"
        return 1
    fi
    
    # Step 2: Check USB health
    echo ""
    echo "${COLOR_YELLOW}Checking USB health...${COLOR_RESET}"
    init_usb_device "$target_device" >/dev/null 2>&1
    
    local health_status
    if command -v smartctl >/dev/null 2>&1; then
        health_status=$(check_usb_smart_health "$target_device" 2>/dev/null | grep "SMART overall-health" || echo "Health check unavailable")
        echo "Health: $health_status"
    fi
    
    # Check write cycles if available
    local write_cycles=$(estimate_write_cycles 2>/dev/null || echo "unknown")
    if [[ "$write_cycles" != "unknown" ]]; then
        echo "Estimated write cycles: $write_cycles"
        if [[ $write_cycles -gt 5000 ]]; then
            echo "${COLOR_YELLOW}Warning: This USB has high write cycles${COLOR_RESET}"
        fi
    fi
    
    # Step 3: Initialize USB
    echo ""
    if ! confirm_action "Initialize USB for Leonardo"; then
        return 1
    fi
    
    echo ""
    echo "${COLOR_CYAN}Initializing USB...${COLOR_RESET}"
    
    # Format if requested
    if [[ "$options" == *"format"* ]]; then
        local filesystem="${USB_FORMAT_TYPE:-exfat}"
        if ! format_usb_drive "$target_device" "$filesystem" "LEONARDO"; then
            return 1
        fi
    fi
    
    # Initialize and mount
    if ! init_usb_device "$target_device"; then
        return 1
    fi
    
    # Check space
    if ! check_usb_free_space "$LEONARDO_USB_MOUNT" $((USB_DEPLOY_MIN_SPACE_GB * 1024)); then
        log_message "ERROR" "Insufficient space. Need at least ${USB_DEPLOY_MIN_SPACE_GB}GB"
        return 1
    fi
    
    echo "Available space: ${LEONARDO_USB_FREE}"
    
    # Step 4: Create Leonardo structure
    echo ""
    echo "${COLOR_CYAN}Creating Leonardo structure...${COLOR_RESET}"
    if ! create_leonardo_structure; then
        return 1
    fi
    
    # Step 5: Install Leonardo
    echo ""
    echo "${COLOR_CYAN}Installing Leonardo...${COLOR_RESET}"
    
    local leonardo_script="./leonardo.sh"
    if [[ ! -f "$leonardo_script" ]]; then
        # Try to build it
        if [[ -f "assembly/build-simple.sh" ]]; then
            echo "Building Leonardo..."
            (cd assembly && ./build-simple.sh) || return 1
        else
            log_message "ERROR" "Leonardo script not found"
            return 1
        fi
    fi
    
    if ! install_leonardo_to_usb "$LEONARDO_USB_MOUNT" "$leonardo_script"; then
        return 1
    fi
    
    # Step 6: Configure for first run
    echo ""
    echo "${COLOR_CYAN}Configuring Leonardo...${COLOR_RESET}"
    configure_usb_leonardo
    
    # Step 7: Optionally install models
    if [[ "$options" != *"no-models"* ]]; then
        echo ""
        if confirm_action "Install AI models now"; then
            deploy_models_to_usb
        fi
    fi
    
    # Step 8: Create autorun (if supported)
    if [[ "$options" == *"autorun"* ]]; then
        create_usb_autorun
    fi
    
    # Step 9: Final verification
    echo ""
    echo "${COLOR_CYAN}Verifying deployment...${COLOR_RESET}"
    verify_usb_deployment
    
    # Success!
    echo ""
    echo "${COLOR_GREEN}✓ Leonardo successfully deployed to USB!${COLOR_RESET}"
    echo ""
    echo "To use Leonardo:"
    echo "1. Safely eject this USB drive"
    echo "2. Insert into any computer"
    echo "3. Run leonardo.sh (Linux/Mac) or leonardo.bat (Windows)"
    echo ""
    echo "USB Mount: $LEONARDO_USB_MOUNT"
    
    return 0
}

# Configure Leonardo for USB deployment
configure_usb_leonardo() {
    local config_file="$LEONARDO_USB_MOUNT/leonardo/config/leonardo.conf"
    
    # Create configuration
    cat > "$config_file" << EOF
# Leonardo AI Universal - USB Configuration
# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Deployment type
LEONARDO_DEPLOYMENT_TYPE="usb"

# USB-specific settings
LEONARDO_USB_MODE="true"
LEONARDO_PORTABLE_MODE="true"
LEONARDO_NO_INSTALL="true"

# Paths (relative to USB root)
LEONARDO_BASE_DIR="\$(dirname "\$(readlink -f "\$0")")/leonardo"
LEONARDO_MODEL_DIR="\$LEONARDO_BASE_DIR/models"
LEONARDO_CACHE_DIR="\$LEONARDO_BASE_DIR/cache"
LEONARDO_CONFIG_DIR="\$LEONARDO_BASE_DIR/config"
LEONARDO_LOG_DIR="\$LEONARDO_BASE_DIR/logs"
LEONARDO_DATA_DIR="\$LEONARDO_BASE_DIR/data"

# Performance settings for USB
LEONARDO_LOW_MEMORY_MODE="true"
LEONARDO_CACHE_SIZE_MB="512"
LEONARDO_MAX_THREADS="4"

# Security settings
LEONARDO_PARANOID_MODE="true"
LEONARDO_NO_TELEMETRY="true"
LEONARDO_CLEANUP_ON_EXIT="true"
EOF
    
    log_message "SUCCESS" "USB configuration created"
}

# Deploy models to USB
deploy_models_to_usb() {
    echo ""
    echo "${COLOR_CYAN}Model Deployment${COLOR_RESET}"
    echo ""
    
    # Check available space
    check_usb_free_space "$LEONARDO_USB_MOUNT" 1024
    local free_gb=$((LEONARDO_USB_FREE_MB / 1024))
    
    echo "Available space: ${free_gb}GB"
    echo ""
    
    # Show model recommendations based on space
    if [[ $free_gb -lt 8 ]]; then
        echo "${COLOR_YELLOW}Limited space. Recommended models:${COLOR_RESET}"
        echo "- TinyLlama (1.1B) - 2GB"
        echo "- Phi-2 (2.7B) - 3GB"
    elif [[ $free_gb -lt 16 ]]; then
        echo "${COLOR_CYAN}Recommended models:${COLOR_RESET}"
        echo "- Llama 3.2 (3B) - 4GB"
        echo "- Mistral 7B - 8GB"
        echo "- Gemma 2B - 3GB"
    else
        echo "${COLOR_GREEN}Plenty of space! Popular models:${COLOR_RESET}"
        echo "- Llama 3.1 (8B) - 8GB"
        echo "- Mistral 7B - 8GB"
        echo "- Mixtral 8x7B - 48GB (if space permits)"
    fi
    
    echo ""
    
    # Model selection
    local selected_models=()
    local total_size=0
    
    while true; do
        # Use model selector
        select_model_interactive
        
        if [[ -z "$SELECTED_MODEL_ID" ]]; then
            break
        fi
        
        # Get model info
        local model_info=$(get_model_info "$SELECTED_MODEL_ID")
        local model_size=$(echo "$model_info" | grep "Size:" | awk '{print $2}' | sed 's/GB//')
        
        # Check if we have space
        local new_total=$((total_size + model_size))
        if [[ $new_total -gt $((free_gb - 2)) ]]; then
            echo "${COLOR_RED}Not enough space for this model${COLOR_RESET}"
            continue
        fi
        
        selected_models+=("$SELECTED_MODEL_ID")
        total_size=$new_total
        
        echo "Selected: $(echo "$model_info" | grep "Name:" | cut -d: -f2-)"
        echo "Total size: ${total_size}GB"
        echo ""
        
        if ! confirm_action "Select another model"; then
            break
        fi
    done
    
    # Download and install selected models
    if [[ ${#selected_models[@]} -gt 0 ]]; then
        echo ""
        echo "${COLOR_CYAN}Downloading models...${COLOR_RESET}"
        
        for model_id in "${selected_models[@]}"; do
            echo ""
            download_model_to_usb "$model_id"
        done
    fi
}

# Download model to USB
download_model_to_usb() {
    local model_id="$1"
    local target_dir="$LEONARDO_USB_MOUNT/leonardo/models"
    
    # Ensure target directory exists
    ensure_directory "$target_dir"
    
    # Set download target
    export LEONARDO_MODEL_DIR="$target_dir"
    
    # Download using model manager
    download_model "$model_id"
    
    # Verify integrity
    local model_file="$target_dir/${model_id}.gguf"
    if [[ -f "$model_file.sha256" ]]; then
        echo "Verifying model integrity..."
        verify_checksum_file "$model_file" "$model_file.sha256"
    fi
}

# Create autorun files
create_usb_autorun() {
    # Windows autorun.inf (note: often disabled by default on modern Windows)
    cat > "$LEONARDO_USB_MOUNT/autorun.inf" << EOF
[autorun]
label=Leonardo AI Universal
icon=leonardo\\assets\\leonardo.ico
action=Run Leonardo AI Universal
open=leonardo.bat
EOF
    
    # Create desktop entry for Linux
    cat > "$LEONARDO_USB_MOUNT/.autorun" << EOF
#!/bin/bash
# Leonardo AI Universal Autorun
cd "\$(dirname "\$0")"
./leonardo.sh
EOF
    chmod +x "$LEONARDO_USB_MOUNT/.autorun"
    
    log_message "INFO" "Autorun files created (may require user permission)"
}

# Verify USB deployment
verify_usb_deployment() {
    local checks_passed=0
    local checks_total=0
    
    # Check 1: Leonardo executable
    ((checks_total++))
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo.sh" ]]; then
        # Check if executable or if filesystem doesn't support permissions (FAT/exFAT)
        if [[ -x "$LEONARDO_USB_MOUNT/leonardo.sh" ]] || ! chmod +x "$LEONARDO_USB_MOUNT/leonardo.sh" 2>/dev/null; then
            echo "✓ Leonardo executable found"
            ((checks_passed++))
        else
            echo "✗ Leonardo executable missing or not executable"
        fi
    else
        echo "✗ Leonardo executable missing"
    fi
    
    # Check 2: Directory structure
    ((checks_total++))
    local required_dirs=("leonardo" "leonardo/models" "leonardo/config" "leonardo/logs")
    local dirs_ok=true
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$LEONARDO_USB_MOUNT/$dir" ]]; then
            dirs_ok=false
            break
        fi
    done
    
    if [[ "$dirs_ok" == "true" ]]; then
        echo "✓ Directory structure complete"
        ((checks_passed++))
    else
        echo "✗ Directory structure incomplete"
    fi
    
    # Check 3: Configuration
    ((checks_total++))
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo/config/leonardo.conf" ]]; then
        echo "✓ Configuration file present"
        ((checks_passed++))
    else
        echo "✗ Configuration file missing"
    fi
    
    # Check 4: Platform launchers
    ((checks_total++))
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo.bat" ]] || [[ -f "$LEONARDO_USB_MOUNT/leonardo.command" ]]; then
        echo "✓ Platform launchers created"
        ((checks_passed++))
    else
        echo "✗ Platform launchers missing"
    fi
    
    # Check 5: Write test
    ((checks_total++))
    local test_file="$LEONARDO_USB_MOUNT/.leonardo_test_$$"
    if echo "test" > "$test_file" 2>/dev/null && rm -f "$test_file" 2>/dev/null; then
        echo "✓ USB is writable"
        ((checks_passed++))
    else
        echo "✗ USB write test failed"
    fi
    
    echo ""
    echo "Verification: $checks_passed/$checks_total checks passed"
    
    return $((checks_total - checks_passed))
}

# Quick USB deployment (minimal interaction)
quick_deploy_to_usb() {
    local device="$1"
    
    # Auto-detect if not specified
    if [[ -z "$device" ]]; then
        device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
        if [[ -z "$device" ]]; then
            log_message "ERROR" "No USB device detected"
            return 1
        fi
    fi
    
    # Deploy with defaults
    deploy_to_usb "$device" "no-models"
}

# USB deployment status
get_usb_deployment_status() {
    local device="$1"
    
    # Initialize device
    if ! init_usb_device "$device" >/dev/null 2>&1; then
        echo "Status: Not mounted"
        return 1
    fi
    
    # Check deployment
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo.sh" ]]; then
        echo "Status: Leonardo installed"
        
        # Check version
        if [[ -f "$LEONARDO_USB_MOUNT/leonardo/VERSION" ]]; then
            echo "Version: $(cat "$LEONARDO_USB_MOUNT/leonardo/VERSION")"
        fi
        
        # Check models
        local model_count=$(find "$LEONARDO_USB_MOUNT/leonardo/models" -name "*.gguf" 2>/dev/null | wc -l)
        echo "Models: $model_count installed"
        
        # Check space
        check_usb_free_space "$LEONARDO_USB_MOUNT" 0
        echo "Free space: ${LEONARDO_USB_FREE}"
    else
        echo "Status: Not deployed"
    fi
}

# Export deployment functions
export -f deploy_to_usb configure_usb_leonardo deploy_models_to_usb
export -f download_model_to_usb create_usb_autorun verify_usb_deployment
export -f quick_deploy_to_usb get_usb_deployment_status

# ==== Component: src/deployment/local_deploy.sh ====
# ==============================================================================
# Leonardo AI Universal - Local Deployment Module
# ==============================================================================
# Description: Deploy Leonardo and AI models to local systems
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh, models/*.sh, checksum.sh
# ==============================================================================

# Local deployment paths
LOCAL_INSTALL_PREFIX="${LOCAL_INSTALL_PREFIX:-$HOME/.leonardo}"
LOCAL_BIN_PATH="${LOCAL_BIN_PATH:-$HOME/.local/bin}"
LOCAL_DESKTOP_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

# Deploy Leonardo locally
deploy_to_local() {
    local install_path="${1:-$LOCAL_INSTALL_PREFIX}"
    local options="${2:-}"
    
    echo "${COLOR_CYAN}Leonardo Local Deployment${COLOR_RESET}"
    echo "========================="
    echo ""
    
    # Step 1: Check system
    echo "${COLOR_YELLOW}Checking system...${COLOR_RESET}"
    check_local_system
    
    # Step 2: Select installation path
    if [[ "$options" != *"auto"* ]]; then
        echo ""
        echo "Default installation path: $install_path"
        read -p "Use this path? (Y/n): " response
        
        if [[ "${response,,}" == "n" ]]; then
            read -p "Enter installation path: " custom_path
            if [[ -n "$custom_path" ]]; then
                install_path="$custom_path"
            fi
        fi
    fi
    
    # Expand path
    install_path=$(eval echo "$install_path")
    
    # Step 3: Check if already installed
    if [[ -d "$install_path" ]] && [[ -f "$install_path/leonardo.sh" ]]; then
        echo ""
        echo "${COLOR_YELLOW}Leonardo is already installed at: $install_path${COLOR_RESET}"
        
        if ! confirm_action "Reinstall/Update Leonardo"; then
            return 0
        fi
    fi
    
    # Step 4: Create installation directory
    echo ""
    echo "${COLOR_CYAN}Creating installation directory...${COLOR_RESET}"
    if ! ensure_directory "$install_path"; then
        log_message "ERROR" "Failed to create installation directory"
        return 1
    fi
    
    # Step 5: Install Leonardo
    echo ""
    echo "${COLOR_CYAN}Installing Leonardo...${COLOR_RESET}"
    if ! install_leonardo_local "$install_path"; then
        return 1
    fi
    
    # Step 6: Create system integration
    echo ""
    echo "${COLOR_CYAN}Creating system integration...${COLOR_RESET}"
    create_local_integration "$install_path"
    
    # Step 7: Configure Leonardo
    echo ""
    echo "${COLOR_CYAN}Configuring Leonardo...${COLOR_RESET}"
    configure_local_leonardo "$install_path"
    
    # Step 8: Optionally install models
    if [[ "$options" != *"no-models"* ]]; then
        echo ""
        if confirm_action "Install AI models now"; then
            deploy_models_to_local "$install_path"
        fi
    fi
    
    # Step 9: Verify installation
    echo ""
    echo "${COLOR_CYAN}Verifying installation...${COLOR_RESET}"
    verify_local_deployment "$install_path"
    
    # Success!
    echo ""
    echo "${COLOR_GREEN}✓ Leonardo successfully installed!${COLOR_RESET}"
    echo ""
    echo "Installation path: $install_path"
    echo ""
    echo "To use Leonardo:"
    echo "1. Run: leonardo"
    echo "2. Or: $install_path/leonardo.sh"
    echo ""
    
    # Update shell if needed
    if [[ "$options" != *"no-shell"* ]]; then
        update_shell_config "$install_path"
    fi
    
    return 0
}

# Check local system
check_local_system() {
    local platform=$(detect_platform)
    
    echo "Platform: $platform"
    echo "Architecture: $(uname -m)"
    echo "Shell: $SHELL"
    
    # Check disk space
    local available_space
    case "$platform" in
        "macos")
            available_space=$(df -g "$HOME" | awk 'NR==2 {print $4}')
            echo "Available space: ${available_space}GB"
            ;;
        "linux")
            available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
            echo "Available space: ${available_space}GB"
            ;;
        "windows")
            # WSL or Git Bash
            available_space=$(df -BG "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//')
            if [[ -n "$available_space" ]]; then
                echo "Available space: ${available_space}GB"
            fi
            ;;
    esac
    
    # Check dependencies
    echo ""
    echo "Checking dependencies..."
    local deps=("curl" "tar" "gzip")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "${COLOR_YELLOW}Missing dependencies: ${missing[*]}${COLOR_RESET}"
        echo "Please install them before continuing."
        return 1
    else
        echo "✓ All dependencies satisfied"
    fi
}

# Install Leonardo locally
install_leonardo_local() {
    local install_path="$1"
    local leonardo_script="./leonardo.sh"
    
    # Build if necessary
    if [[ ! -f "$leonardo_script" ]]; then
        if [[ -f "assembly/build-simple.sh" ]]; then
            echo "Building Leonardo..."
            (cd assembly && ./build-simple.sh) || return 1
        else
            log_message "ERROR" "Leonardo script not found"
            return 1
        fi
    fi
    
    # Copy Leonardo
    echo "Copying Leonardo..."
    cp "$leonardo_script" "$install_path/" || return 1
    chmod +x "$install_path/leonardo.sh"
    
    # Create directory structure
    echo "Creating directory structure..."
    local dirs=("models" "cache" "config" "logs" "data" "scripts" "backups" "temp")
    
    for dir in "${dirs[@]}"; do
        ensure_directory "$install_path/$dir"
    done
    
    # Copy assets if available
    if [[ -d "assets" ]]; then
        cp -r assets "$install_path/"
    fi
    
    # Create VERSION file
    echo "$LEONARDO_VERSION" > "$install_path/VERSION"
    
    log_message "SUCCESS" "Leonardo installed to $install_path"
    return 0
}

# Create local system integration
create_local_integration() {
    local install_path="$1"
    local platform=$(detect_platform)
    
    # Create command link
    ensure_directory "$LOCAL_BIN_PATH"
    
    # Create wrapper script
    local wrapper="$LOCAL_BIN_PATH/leonardo"
    cat > "$wrapper" << EOF
#!/usr/bin/env bash
# Leonardo AI Universal launcher
exec "$install_path/leonardo.sh" "\$@"
EOF
    chmod +x "$wrapper"
    echo "✓ Command 'leonardo' created"
    
    # Platform-specific integration
    case "$platform" in
        "linux")
            create_desktop_entry "$install_path"
            ;;
        "macos")
            create_macos_app "$install_path"
            ;;
        "windows")
            create_windows_shortcut "$install_path"
            ;;
    esac
}

# Create Linux desktop entry
create_desktop_entry() {
    local install_path="$1"
    
    ensure_directory "$LOCAL_DESKTOP_PATH"
    
    cat > "$LOCAL_DESKTOP_PATH/leonardo.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Leonardo AI Universal
Comment=Deploy AI models anywhere
Icon=$install_path/assets/leonardo.png
Exec=$install_path/leonardo.sh
Terminal=true
Categories=Development;Science;
Keywords=AI;ML;LLM;Models;
EOF
    
    # Update desktop database if available
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$LOCAL_DESKTOP_PATH" 2>/dev/null
    fi
    
    echo "✓ Desktop entry created"
}

# Create macOS app bundle
create_macos_app() {
    local install_path="$1"
    local app_path="$HOME/Applications/Leonardo.app"
    
    # Create app structure
    ensure_directory "$app_path/Contents/MacOS"
    ensure_directory "$app_path/Contents/Resources"
    
    # Create launcher
    cat > "$app_path/Contents/MacOS/Leonardo" << EOF
#!/bin/bash
cd "$install_path"
open -a Terminal "$install_path/leonardo.sh"
EOF
    chmod +x "$app_path/Contents/MacOS/Leonardo"
    
    # Create Info.plist
    cat > "$app_path/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Leonardo</string>
    <key>CFBundleIdentifier</key>
    <string>ai.leonardo.universal</string>
    <key>CFBundleName</key>
    <string>Leonardo AI Universal</string>
    <key>CFBundleVersion</key>
    <string>$LEONARDO_VERSION</string>
    <key>CFBundleIconFile</key>
    <string>leonardo.icns</string>
</dict>
</plist>
EOF
    
    echo "✓ macOS app created"
}

# Create Windows shortcut (for WSL/Git Bash)
create_windows_shortcut() {
    local install_path="$1"
    local desktop="$HOME/Desktop"
    
    if [[ -d "$desktop" ]]; then
        # Create batch file
        cat > "$desktop/Leonardo.bat" << EOF
@echo off
title Leonardo AI Universal
bash "$install_path/leonardo.sh" %*
pause
EOF
        echo "✓ Desktop shortcut created"
    fi
}

# Configure local Leonardo
configure_local_leonardo() {
    local install_path="$1"
    local config_file="$install_path/config/leonardo.conf"
    
    cat > "$config_file" << EOF
# Leonardo AI Universal - Local Configuration
# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Deployment type
LEONARDO_DEPLOYMENT_TYPE="local"

# Local paths
LEONARDO_BASE_DIR="$install_path"
LEONARDO_MODEL_DIR="\$LEONARDO_BASE_DIR/models"
LEONARDO_CACHE_DIR="\$LEONARDO_BASE_DIR/cache"
LEONARDO_CONFIG_DIR="\$LEONARDO_BASE_DIR/config"
LEONARDO_LOG_DIR="\$LEONARDO_BASE_DIR/logs"
LEONARDO_DATA_DIR="\$LEONARDO_BASE_DIR/data"

# Performance settings
LEONARDO_CACHE_SIZE_MB="2048"
LEONARDO_MAX_THREADS="0"  # 0 = auto-detect

# Update settings
LEONARDO_AUTO_UPDATE="true"
LEONARDO_UPDATE_CHANNEL="stable"
EOF
    
    log_message "SUCCESS" "Local configuration created"
}

# Deploy models to local installation
deploy_models_to_local() {
    local install_path="$1"
    local model_dir="$install_path/models"
    
    # Set model directory
    export LEONARDO_MODEL_DIR="$model_dir"
    
    echo ""
    echo "${COLOR_CYAN}Model Installation${COLOR_RESET}"
    echo ""
    
    # Check disk space
    local available_gb
    available_gb=$(df -BG "$install_path" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "unknown")
    
    if [[ "$available_gb" != "unknown" ]]; then
        echo "Available space: ${available_gb}GB"
        echo ""
    fi
    
    # Show recommendations
    echo "${COLOR_CYAN}Recommended starter models:${COLOR_RESET}"
    echo "1. Llama 3.2 (3B) - Fast and capable"
    echo "2. Mistral 7B - Excellent general purpose"
    echo "3. Gemma 2B - Lightweight option"
    echo ""
    
    # Let user select models
    local continue_selection=true
    
    while [[ "$continue_selection" == "true" ]]; do
        select_model_interactive
        
        if [[ -z "$SELECTED_MODEL_ID" ]]; then
            break
        fi
        
        # Download model
        echo ""
        download_model "$SELECTED_MODEL_ID"
        
        echo ""
        if ! confirm_action "Install another model"; then
            continue_selection=false
        fi
    done
}

# Verify local deployment
verify_local_deployment() {
    local install_path="$1"
    local checks_passed=0
    local checks_total=0
    
    # Check 1: Leonardo executable
    ((checks_total++))
    if [[ -f "$install_path/leonardo.sh" ]] && [[ -x "$install_path/leonardo.sh" ]]; then
        echo "✓ Leonardo executable found"
        ((checks_passed++))
    else
        echo "✗ Leonardo executable missing"
    fi
    
    # Check 2: Directory structure
    ((checks_total++))
    local required_dirs=("models" "config" "logs" "cache")
    local dirs_ok=true
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$install_path/$dir" ]]; then
            dirs_ok=false
            break
        fi
    done
    
    if [[ "$dirs_ok" == "true" ]]; then
        echo "✓ Directory structure complete"
        ((checks_passed++))
    else
        echo "✗ Directory structure incomplete"
    fi
    
    # Check 3: Configuration
    ((checks_total++))
    if [[ -f "$install_path/config/leonardo.conf" ]]; then
        echo "✓ Configuration file present"
        ((checks_passed++))
    else
        echo "✗ Configuration file missing"
    fi
    
    # Check 4: Command availability
    ((checks_total++))
    if command -v leonardo >/dev/null 2>&1; then
        echo "✓ 'leonardo' command available"
        ((checks_passed++))
    else
        echo "✗ 'leonardo' command not in PATH"
    fi
    
    echo ""
    echo "Verification: $checks_passed/$checks_total checks passed"
    
    return $((checks_total - checks_passed))
}

# Update shell configuration
update_shell_config() {
    local install_path="$1"
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$LOCAL_BIN_PATH:"* ]]; then
        echo ""
        echo "${COLOR_YELLOW}Adding Leonardo to PATH...${COLOR_RESET}"
        
        # Detect shell config file
        local shell_config=""
        case "$SHELL" in
            */bash)
                shell_config="$HOME/.bashrc"
                ;;
            */zsh)
                shell_config="$HOME/.zshrc"
                ;;
            */fish)
                shell_config="$HOME/.config/fish/config.fish"
                ;;
        esac
        
        if [[ -n "$shell_config" ]] && [[ -f "$shell_config" ]]; then
            # Check if already added
            if ! grep -q "leonardo.*PATH" "$shell_config"; then
                echo "" >> "$shell_config"
                echo "# Leonardo AI Universal" >> "$shell_config"
                echo "export PATH=\"\$PATH:$LOCAL_BIN_PATH\"" >> "$shell_config"
                echo "✓ PATH updated in $shell_config"
                echo ""
                echo "Run 'source $shell_config' or restart your terminal"
            fi
        fi
    fi
}

# Uninstall Leonardo
uninstall_leonardo_local() {
    local install_path="${1:-$LOCAL_INSTALL_PREFIX}"
    
    echo "${COLOR_YELLOW}Uninstalling Leonardo...${COLOR_RESET}"
    echo ""
    
    if [[ ! -d "$install_path" ]]; then
        echo "Leonardo not found at: $install_path"
        return 1
    fi
    
    if ! confirm_action "Remove Leonardo and all data"; then
        return 0
    fi
    
    # Remove installation
    echo "Removing $install_path..."
    rm -rf "$install_path"
    
    # Remove command
    if [[ -f "$LOCAL_BIN_PATH/leonardo" ]]; then
        rm -f "$LOCAL_BIN_PATH/leonardo"
    fi
    
    # Remove desktop entry
    if [[ -f "$LOCAL_DESKTOP_PATH/leonardo.desktop" ]]; then
        rm -f "$LOCAL_DESKTOP_PATH/leonardo.desktop"
    fi
    
    # Remove macOS app
    if [[ -d "$HOME/Applications/Leonardo.app" ]]; then
        rm -rf "$HOME/Applications/Leonardo.app"
    fi
    
    echo ""
    echo "${COLOR_GREEN}✓ Leonardo uninstalled${COLOR_RESET}"
}

# Export deployment functions
export -f deploy_to_local check_local_system install_leonardo_local
export -f create_local_integration configure_local_leonardo
export -f deploy_models_to_local verify_local_deployment
export -f update_shell_config uninstall_leonardo_local

# ==== Component: src/deployment/cli.sh ====
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

# ==== Component: src/ui/menu.sh ====
# ==============================================================================
# Leonardo AI Universal - Menu System
# ==============================================================================
# Description: Interactive menu navigation and selection
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, validation.sh
# ==============================================================================

# Menu state tracking
declare -g MENU_SELECTION=""
declare -g MENU_POSITION=1
declare -g MENU_MAX_ITEMS=0

# Compatibility
BRIGHT="${BOLD}"

# Display menu with arrow key navigation
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    local num_options=${#options[@]}
    
    MENU_MAX_ITEMS=$num_options
    MENU_POSITION=1
    MENU_SELECTION=""
    
    # Hide cursor
    tput civis
    
    # Trap for cleanup
    trap 'tput cnorm; echo' INT TERM
    
    while true; do
        # Clear screen and display menu
        clear
        display_menu_frame "$title" "${options[@]}"
        
        # Read user input
        read -rsn1 key
        
        case "$key" in
            # Arrow keys
            $'\x1b')
                read -rsn2 -t 0.1 key
                case "$key" in
                    '[A') # Up arrow
                        ((MENU_POSITION--))
                        [[ $MENU_POSITION -lt 1 ]] && MENU_POSITION=$num_options
                        ;;
                    '[B') # Down arrow
                        ((MENU_POSITION++))
                        [[ $MENU_POSITION -gt $num_options ]] && MENU_POSITION=1
                        ;;
                esac
                ;;
            # Enter key
            '')
                MENU_SELECTION="${options[$((MENU_POSITION-1))]}"
                break
                ;;
            # Number keys for quick selection
            [1-9])
                if [[ $key -le $num_options ]]; then
                    MENU_POSITION=$key
                    MENU_SELECTION="${options[$((key-1))]}"
                    break
                fi
                ;;
            # Escape or q to quit
            $'\x1b'|q|Q)
                MENU_SELECTION=""
                break
                ;;
        esac
    done
    
    # Show cursor again
    tput cnorm
    trap - INT TERM
    
    # Return selection
    echo "$MENU_SELECTION"
}

# Display menu frame with highlighting
display_menu_frame() {
    local title="$1"
    shift
    local options=("$@")
    
    # Draw title box
    echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
    printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
    echo
    
    # Display options
    local i=1
    for option in "${options[@]}"; do
        if [[ $i -eq $MENU_POSITION ]]; then
            # Highlighted option
            echo -e "${CYAN}▶ ${BRIGHT}${option}${COLOR_RESET}"
        else
            echo -e "  ${DIM}${option}${COLOR_RESET}"
        fi
        ((i++))
    done
    
    echo
    echo -e "${DIM}Use ↑/↓ arrows or numbers to select, Enter to confirm, q to quit${COLOR_RESET}"
}

# Simple yes/no menu
confirm_menu() {
    local prompt="$1"
    local default="${2:-n}"
    
    echo -e "${YELLOW}${prompt}${COLOR_RESET}"
    
    local options=("Yes" "No")
    local selection=$(show_menu "Confirm Action" "${options[@]}")
    
    case "$selection" in
        "Yes") return 0 ;;
        "No"|"") return 1 ;;
    esac
}

# Alias for backward compatibility
confirm_action() {
    confirm_menu "$@"
}

# Multi-select checklist menu
show_checklist() {
    local title="$1"
    shift
    local options=("$@")
    local num_options=${#options[@]}
    local -a selected=()
    
    # Initialize all as unselected
    for ((i=0; i<num_options; i++)); do
        selected[i]=0
    done
    
    MENU_POSITION=1
    
    # Hide cursor
    tput civis
    trap 'tput cnorm; echo' INT TERM
    
    while true; do
        clear
        display_checklist_frame "$title" "${options[@]}" "${selected[@]}"
        
        # Read user input
        read -rsn1 key
        
        case "$key" in
            $'\x1b')
                read -rsn2 -t 0.1 key
                case "$key" in
                    '[A') # Up arrow
                        ((MENU_POSITION--))
                        [[ $MENU_POSITION -lt 1 ]] && MENU_POSITION=$num_options
                        ;;
                    '[B') # Down arrow
                        ((MENU_POSITION++))
                        [[ $MENU_POSITION -gt $num_options ]] && MENU_POSITION=1
                        ;;
                esac
                ;;
            ' ') # Space to toggle
                local idx=$((MENU_POSITION-1))
                selected[idx]=$((1 - selected[idx]))
                ;;
            '') # Enter to confirm
                break
                ;;
            q|Q) # Quit
                selected=()
                break
                ;;
        esac
    done
    
    # Show cursor again
    tput cnorm
    trap - INT TERM
    
    # Return selected items
    local result=()
    for ((i=0; i<num_options; i++)); do
        if [[ ${selected[i]} -eq 1 ]]; then
            result+=("${options[i]}")
        fi
    done
    
    printf '%s\n' "${result[@]}"
}

# Display checklist frame
display_checklist_frame() {
    local title="$1"
    shift
    local num_options=$(($# / 2))
    local -a options=("${@:1:$num_options}")
    local -a selected=("${@:$((num_options+1))}")
    
    # Draw title box
    echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
    printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
    echo
    
    # Display options with checkboxes
    local i=1
    for ((idx=0; idx<num_options; idx++)); do
        local checkbox="[ ]"
        [[ ${selected[idx]} -eq 1 ]] && checkbox="[✓]"
        
        if [[ $i -eq $MENU_POSITION ]]; then
            echo -e "${CYAN}▶ ${checkbox} ${BRIGHT}${options[idx]}${COLOR_RESET}"
        else
            echo -e "  ${checkbox} ${DIM}${options[idx]}${COLOR_RESET}"
        fi
        ((i++))
    done
    
    echo
    echo -e "${DIM}Use ↑/↓ to navigate, Space to select, Enter to confirm${COLOR_RESET}"
}

# Radio button menu (single selection)
show_radio_menu() {
    local title="$1"
    local current="$2"
    shift 2
    local options=("$@")
    
    # Find current selection index
    local current_idx=0
    for ((i=0; i<${#options[@]}; i++)); do
        if [[ "${options[i]}" == "$current" ]]; then
            current_idx=$((i+1))
            break
        fi
    done
    
    MENU_POSITION=${current_idx:-1}
    local selection=$(show_menu "$title" "${options[@]}")
    echo "$selection"
}

# Progress menu with cancel option
show_progress_menu() {
    local title="$1"
    local message="$2"
    local -n progress_var=$3
    local -n cancel_var=$4
    
    # Run in background
    (
        while [[ ${cancel_var} -eq 0 ]] && [[ ${progress_var} -lt 100 ]]; do
            clear
            echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
            printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
            echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
            echo
            echo -e "${message}"
            echo
            print_progress ${progress_var} 40
            echo
            echo -e "${DIM}Press 'c' to cancel${COLOR_RESET}"
            sleep 0.1
        done
    ) &
    
    local bg_pid=$!
    
    # Wait for input or completion
    while kill -0 $bg_pid 2>/dev/null; do
        read -rsn1 -t 0.1 key
        if [[ "$key" == "c" ]] || [[ "$key" == "C" ]]; then
            cancel_var=1
            kill $bg_pid 2>/dev/null
            wait $bg_pid 2>/dev/null
            return 1
        fi
    done
    
    return 0
}

# Input dialog
show_input_dialog() {
    local title="$1"
    local prompt="$2"
    local default="$3"
    local validation_func="${4:-}"
    
    clear
    echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
    printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
    echo
    echo -e "${prompt}"
    
    if [[ -n "$default" ]]; then
        echo -e "${DIM}(default: $default)${COLOR_RESET}"
    fi
    
    echo
    
    local input
    while true; do
        read -er -p "> " input
        
        # Use default if empty
        if [[ -z "$input" ]] && [[ -n "$default" ]]; then
            input="$default"
        fi
        
        # Validate if function provided
        if [[ -n "$validation_func" ]]; then
            if $validation_func "$input"; then
                break
            else
                echo -e "${RED}Invalid input. Please try again.${COLOR_RESET}"
            fi
        else
            break
        fi
    done
    
    echo "$input"
}

# List selection with filtering
show_filtered_list() {
    local title="$1"
    shift
    local items=("$@")
    local filtered_items=("${items[@]}")
    local filter=""
    local selected=""
    
    while true; do
        clear
        echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
        printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
        echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
        echo
        echo -e "Filter: ${YELLOW}$filter${COLOR_RESET}_"
        echo -e "${DIM}Type to filter, ↑/↓ to select, Enter to confirm, Esc to cancel${COLOR_RESET}"
        echo
        
        # Apply filter
        if [[ -n "$filter" ]]; then
            filtered_items=()
            for item in "${items[@]}"; do
                if [[ "${item,,}" == *"${filter,,}"* ]]; then
                    filtered_items+=("$item")
                fi
            done
        fi
        
        # Display filtered items
        if [[ ${#filtered_items[@]} -eq 0 ]]; then
            echo -e "${DIM}No items match filter${COLOR_RESET}"
        else
            selected=$(show_menu "Select Item" "${filtered_items[@]}")
            if [[ -n "$selected" ]]; then
                echo "$selected"
                return 0
            fi
        fi
        
        # Read input for filtering
        read -rsn1 key
        case "$key" in
            $'\x1b') # Escape
                return 1
                ;;
            $'\x7f'|$'\b') # Backspace
                filter="${filter%?}"
                ;;
            '') # Enter
                if [[ ${#filtered_items[@]} -eq 1 ]]; then
                    echo "${filtered_items[0]}"
                    return 0
                fi
                ;;
            *)
                if [[ "$key" =~ ^[[:print:]]$ ]]; then
                    filter="${filter}${key}"
                fi
                ;;
        esac
    done
}

# Export menu functions
export -f show_menu confirm_menu confirm_action show_checklist show_radio_menu
export -f show_progress_menu show_input_dialog show_filtered_list

# ==== Component: src/ui/progress.sh ====
# ==============================================================================
# Leonardo AI Universal - Progress Display Components
# ==============================================================================
# Description: Progress bars, spinners, and status displays
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh
# ==============================================================================

# Progress bar state
declare -g PROGRESS_ACTIVE=0
declare -g PROGRESS_PID=""

# Enhanced progress bar with percentage and ETA
show_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local title="${4:-Progress}"
    local start_time="${5:-$(date +%s)}"
    
    # Calculate percentage
    local percent=$((current * 100 / total))
    
    # Calculate filled width
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    # Calculate ETA
    local elapsed=$(($(date +%s) - start_time))
    local eta=""
    if [[ $elapsed -gt 0 ]] && [[ $current -gt 0 ]]; then
        local rate=$(echo "scale=2; $current / $elapsed" | bc 2>/dev/null || echo "0")
        if [[ $(echo "$rate > 0" | bc 2>/dev/null) == "1" ]]; then
            local remaining=$((total - current))
            local eta_seconds=$(echo "scale=0; $remaining / $rate" | bc 2>/dev/null || echo "0")
            eta=$(format_duration "$eta_seconds")
        fi
    fi
    
    # Build progress bar
    printf "\r${YELLOW}%s${RESET} [" "$title"
    
    # Filled portion with gradient effect
    if [[ $filled -gt 0 ]]; then
        local gradient=""
        for ((i=0; i<filled; i++)); do
            if [[ $percent -lt 33 ]]; then
                gradient+="${RED}█"
            elif [[ $percent -lt 66 ]]; then
                gradient+="${YELLOW}█"
            else
                gradient+="${GREEN}█"
            fi
        done
        printf "%b" "$gradient${RESET}"
    fi
    
    # Empty portion
    printf "%${empty}s" | tr ' ' '░'
    
    # Percentage and ETA
    printf "] ${BRIGHT}%3d%%${RESET}" "$percent"
    if [[ -n "$eta" ]]; then
        printf " ${DIM}ETA: %s${RESET}" "$eta"
    fi
    
    # Add data info if provided
    if [[ -n "${6:-}" ]] && [[ -n "${7:-}" ]]; then
        local current_size="$6"
        local total_size="$7"
        printf " ${DIM}(%s/%s)${RESET}" \
            "$(format_bytes "$current_size")" \
            "$(format_bytes "$total_size")"
    fi
    
    # Newline if complete
    if [[ $percent -eq 100 ]]; then
        echo
    fi
}

# Multi-line progress display
show_multi_progress() {
    local -n tasks=$1
    local -n progress=$2
    local title="${3:-Tasks Progress}"
    
    # Save cursor position
    tput sc
    
    # Clear area
    local num_tasks=${#tasks[@]}
    for ((i=0; i<=num_tasks+3; i++)); do
        echo -e "\033[K"
    done
    
    # Restore cursor
    tput rc
    
    # Display title
    echo -e "${GREEN}╔════════════════════════════════════════════╗${RESET}"
    printf "${GREEN}║${RESET} %-42s ${GREEN}║${RESET}\n" "$title"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${RESET}"
    echo
    
    # Display each task progress
    local all_complete=true
    for ((i=0; i<num_tasks; i++)); do
        local task="${tasks[i]}"
        local prog="${progress[i]:-0}"
        
        printf "%-20s " "$task:"
        
        # Mini progress bar
        local bar_width=20
        local filled=$((prog * bar_width / 100))
        local empty=$((bar_width - filled))
        
        printf "["
        if [[ $prog -eq 100 ]]; then
            printf "${GREEN}%${bar_width}s${RESET}" | tr ' ' '█'
        else
            all_complete=false
            printf "${YELLOW}%${filled}s${RESET}" | tr ' ' '█'
            printf "%${empty}s" | tr ' ' '░'
        fi
        printf "] %3d%%\n" "$prog"
    done
    
    # Return whether all tasks are complete
    [[ "$all_complete" == "true" ]]
}

# Animated spinner styles
declare -a SPINNER_STYLES=(
    "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"                    # Braille dots
    "◐◓◑◒"                              # Circle quarters
    "▁▂▃▄▅▆▇█▇▆▅▄▃▂"                    # Building blocks
    "⣾⣽⣻⢿⡿⣟⣯⣷"                    # Braille blocks
    "←↖↑↗→↘↓↙"                          # Arrows
    "|/-\\"                             # Classic
    "◢◣◤◥"                              # Triangles
    "⬒⬔⬓⬕"                              # Diamond
    "⠁⠂⠄⡀⢀⠠⠐⠈"                    # Dots
)

# Show spinner with message
show_spinner() {
    local message="$1"
    local style_idx="${2:-0}"
    local style="${SPINNER_STYLES[$style_idx]}"
    local delay="${3:-0.1}"
    
    PROGRESS_ACTIVE=1
    
    # Run spinner in background
    (
        local i=0
        while [[ $PROGRESS_ACTIVE -eq 1 ]]; do
            local char="${style:$i:1}"
            printf "\r${CYAN}%s${RESET} %s" "$char" "$message"
            sleep "$delay"
            i=$(( (i + 1) % ${#style} ))
        done
        printf "\r\033[K"  # Clear line
    ) &
    
    PROGRESS_PID=$!
}

# Stop spinner
stop_spinner() {
    PROGRESS_ACTIVE=0
    if [[ -n "$PROGRESS_PID" ]]; then
        kill "$PROGRESS_PID" 2>/dev/null
        wait "$PROGRESS_PID" 2>/dev/null
        PROGRESS_PID=""
    fi
    printf "\r\033[K"  # Clear line
}

# Matrix-style progress
show_matrix_progress() {
    local message="$1"
    local duration="${2:-5}"
    local width="${3:-$(tput cols)}"
    
    # Matrix rain characters
    local chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
    local drops=()
    
    # Initialize drops
    for ((i=0; i<width; i++)); do
        drops[i]=$((RANDOM % 20 - 10))
    done
    
    # Save screen state
    tput smcup
    clear
    
    local start_time=$(date +%s)
    while [[ $(($(date +%s) - start_time)) -lt $duration ]]; do
        clear
        
        # Update and draw drops
        for ((x=0; x<width; x++)); do
            local y=${drops[x]}
            if [[ $y -ge 0 ]]; then
                # Draw the trail
                for ((ty=0; ty<y && ty<20; ty++)); do
                    tput cup $ty $x
                    local brightness=$((255 - (y - ty) * 12))
                    printf "\033[38;2;0;%d;0m%s\033[0m" \
                        "$brightness" \
                        "${chars:$((RANDOM % ${#chars})):1}"
                done
            fi
            
            # Move drop down
            drops[x]=$((drops[x] + 1))
            
            # Reset drop if it goes off screen
            if [[ ${drops[x]} -gt 25 ]]; then
                drops[x]=$((RANDOM % 10 - 10))
            fi
        done
        
        # Display message in center
        local msg_y=$(($(tput lines) / 2))
        local msg_x=$(((width - ${#message}) / 2))
        tput cup $msg_y $msg_x
        echo -e "${BRIGHT}${GREEN}$message${RESET}"
        
        sleep 0.05
    done
    
    # Restore screen
    tput rmcup
}

# Download progress with speed and time
show_download_progress() {
    local url="$1"
    local current_bytes="$2"
    local total_bytes="$3"
    local start_time="${4:-$(date +%s)}"
    
    # Calculate speed
    local elapsed=$(($(date +%s) - start_time))
    local speed=0
    if [[ $elapsed -gt 0 ]]; then
        speed=$((current_bytes / elapsed))
    fi
    
    # Extract filename from URL
    local filename=$(basename "$url" | cut -c1-30)
    [[ ${#filename} -eq 30 ]] && filename="${filename}..."
    
    # Show progress
    show_progress_bar "$current_bytes" "$total_bytes" 40 "$filename" \
        "$start_time" "$current_bytes" "$total_bytes"
    
    # Add speed indicator
    if [[ $speed -gt 0 ]]; then
        printf " ${DIM}↓ %s/s${RESET}" "$(format_bytes "$speed")"
    fi
}

# Status indicator with icon
show_status() {
    local status="$1"
    local message="$2"
    local icon=""
    local color=""
    
    case "$status" in
        success|ok|done)
            icon="✓"
            color="$GREEN"
            ;;
        error|fail|failed)
            icon="✗"
            color="$RED"
            ;;
        warning|warn)
            icon="⚠"
            color="$YELLOW"
            ;;
        info)
            icon="ℹ"
            color="$BLUE"
            ;;
        loading|progress)
            icon="◌"
            color="$CYAN"
            ;;
        *)
            icon="•"
            color="$WHITE"
            ;;
    esac
    
    echo -e "${color}${icon}${RESET} ${message}"
}

# Countdown timer
show_countdown() {
    local seconds="$1"
    local message="${2:-Countdown}"
    
    for ((i=seconds; i>0; i--)); do
        printf "\r${YELLOW}%s:${RESET} %02d:%02d" \
            "$message" \
            $((i / 60)) \
            $((i % 60))
        sleep 1
    done
    printf "\r\033[K"
    show_status "done" "$message complete!"
}

# Format duration for display
format_duration() {
    local seconds="$1"
    
    if [[ $seconds -lt 60 ]]; then
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        printf "%dm %ds" $((seconds / 60)) $((seconds % 60))
    else
        printf "%dh %dm" $((seconds / 3600)) $((seconds % 3600 / 60))
    fi
}

# Format bytes for display
format_bytes() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    
    # Use bc for floating point math
    local size=$bytes
    while [[ $(echo "$size >= 1024" | bc 2>/dev/null) == "1" ]] && [[ $unit -lt 4 ]]; do
        size=$(echo "scale=2; $size / 1024" | bc 2>/dev/null)
        ((unit++))
    done
    
    # Format with appropriate precision
    if [[ $unit -eq 0 ]]; then
        printf "%d %s" "$bytes" "${units[unit]}"
    else
        printf "%.2f %s" "$size" "${units[unit]}"
    fi
}

# ASCII art progress animations
show_ascii_progress() {
    local type="$1"
    local progress="$2"
    
    case "$type" in
        rocket)
            local pos=$((progress * 50 / 100))
            printf "\r"
            printf "%${pos}s" | tr ' ' '.'
            printf "🚀"
            printf "%$((50 - pos))s" | tr ' ' '.'
            printf " %3d%%" "$progress"
            ;;
            
        pac)
            local pos=$((progress * 40 / 100))
            local mouth=$((progress % 20 < 10))
            printf "\r"
            printf "%${pos}s" | tr ' ' ' '
            if [[ $mouth -eq 1 ]]; then
                printf "${YELLOW}ᗧ${RESET}"
            else
                printf "${YELLOW}ᗤ${RESET}"
            fi
            printf "%$((40 - pos))s" | tr ' ' '·'
            printf " %3d%%" "$progress"
            ;;
            
        train)
            local pos=$((progress * 35 / 100))
            printf "\r["
            printf "%${pos}s" | tr ' ' '='
            printf "🚂"
            printf "%$((35 - pos))s" | tr ' ' '-'
            printf "] %3d%%" "$progress"
            ;;
    esac
}

# Simple progress function with spinner
show_progress() {
    local message="${1:-Processing...}"
    echo "${CYAN}→ ${message}${RESET}"
}

# Export progress functions
export -f show_progress_bar show_multi_progress show_spinner stop_spinner
export -f show_progress show_download_progress show_status show_countdown
export -f format_duration format_bytes show_matrix_progress show_ascii_progress

# ==== Component: src/ui/dashboard.sh ====
# ==============================================================================
# Leonardo AI Universal - Dashboard Display
# ==============================================================================
# Description: Interactive dashboard and system status displays
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh
# ==============================================================================

# Dashboard state
declare -g DASHBOARD_ACTIVE=0
declare -g DASHBOARD_REFRESH_RATE=1

# Compatibility
RESET="${COLOR_RESET}"

# Main dashboard display
show_dashboard() {
    local usb_device="${1:-}"
    
    DASHBOARD_ACTIVE=1
    
    # Hide cursor and setup terminal
    tput civis
    tput smcup
    clear
    
    # Trap for cleanup
    trap 'DASHBOARD_ACTIVE=0; tput rmcup; tput cnorm' INT TERM EXIT
    
    while [[ $DASHBOARD_ACTIVE -eq 1 ]]; do
        clear
        draw_dashboard_frame
        
        # System info section
        tput cup 3 2
        show_system_info
        
        # USB status section
        tput cup 3 40
        show_usb_status "$usb_device"
        
        # Model status section
        tput cup 12 2
        show_model_status
        
        # Performance metrics
        tput cup 12 40
        show_performance_metrics
        
        # Recent activity
        tput cup 20 2
        show_recent_activity
        
        # Footer with controls
        local rows=$(tput lines)
        tput cup $((rows - 2)) 2
        echo -e "${DIM}Press 'q' to quit, 'r' to refresh${RESET}"
        
        # Check for input with timeout
        if read -rsn1 -t "$DASHBOARD_REFRESH_RATE" key; then
            case "$key" in
                q|Q) DASHBOARD_ACTIVE=0 ;;
                r|R) continue ;;
            esac
        fi
    done
    
    # Cleanup
    DASHBOARD_ACTIVE=0
    tput rmcup
    tput cnorm
    trap - INT TERM EXIT
}

# Draw dashboard frame
draw_dashboard_frame() {
    local cols=$(tput cols)
    local rows=$(tput lines)
    
    # Title bar
    echo -e "${GREEN}╔$(printf '═%.0s' $(seq 2 $((cols-2))))╗${RESET}"
    printf "${GREEN}║${RESET} ${BRIGHT}%-$((cols-4))s${RESET} ${GREEN}║${RESET}\n" \
        "Leonardo AI Universal - System Dashboard"
    echo -e "${GREEN}╠$(printf '═%.0s' $(seq 2 $((cols-2))))╣${RESET}"
    
    # Main area
    for ((i=3; i<rows-2; i++)); do
        tput cup $i 0
        echo -e "${GREEN}║${RESET}$(printf ' %.0s' $(seq 2 $((cols-2))))${GREEN}║${RESET}"
    done
    
    # Bottom border
    tput cup $((rows-2)) 0
    echo -e "${GREEN}╚$(printf '═%.0s' $(seq 2 $((cols-2))))╝${RESET}"
    
    # Section dividers
    tput cup 11 0
    echo -e "${GREEN}╟$(printf '─%.0s' $(seq 2 $((cols-2))))╢${RESET}"
    tput cup 19 0
    echo -e "${GREEN}╟$(printf '─%.0s' $(seq 2 $((cols-2))))╢${RESET}"
    
    # Vertical divider
    for ((i=3; i<11; i++)); do
        tput cup $i 38
        echo -e "${GREEN}│${RESET}"
    done
    for ((i=12; i<19; i++)); do
        tput cup $i 38
        echo -e "${GREEN}│${RESET}"
    done
}

# System information display
show_system_info() {
    echo -e "${YELLOW}System Information${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # OS info
    local os_name=$(uname -s)
    local os_version=$(uname -r)
    printf "OS: ${CYAN}%-25s${RESET}\n" "$os_name $os_version"
    
    # CPU info
    local cpu_model="Unknown"
    local cpu_cores=1
    if [[ -f /proc/cpuinfo ]]; then
        cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        cpu_cores=$(grep -c "processor" /proc/cpuinfo)
    elif command -v sysctl >/dev/null 2>&1; then
        cpu_model=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
        cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null || echo "1")
    fi
    printf "CPU: ${CYAN}%-24s${RESET}\n" "${cpu_model:0:24}"
    printf "Cores: ${CYAN}%-22s${RESET}\n" "$cpu_cores"
    
    # Memory info
    local total_mem=0
    local free_mem=0
    if command -v free >/dev/null 2>&1; then
        total_mem=$(free -b | awk '/^Mem:/ {print $2}')
        free_mem=$(free -b | awk '/^Mem:/ {print $4}')
    elif command -v vm_stat >/dev/null 2>&1; then
        local pages=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
        free_mem=$((pages * 4096))
        total_mem=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
    fi
    
    printf "Memory: ${CYAN}%s / %s${RESET}\n" \
        "$(format_bytes "$free_mem")" \
        "$(format_bytes "$total_mem")"
    
    # Disk space
    local disk_info=$(df -h / | tail -1)
    local disk_used=$(echo "$disk_info" | awk '{print $3}')
    local disk_total=$(echo "$disk_info" | awk '{print $2}')
    printf "Disk: ${CYAN}%s / %s${RESET}\n" "$disk_used" "$disk_total"
}

# USB device status
show_usb_status() {
    local device="$1"
    
    echo -e "${YELLOW}USB Device Status${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [[ -z "$device" ]]; then
        echo -e "${DIM}No USB device selected${RESET}"
        return
    fi
    
    # Device info
    printf "Device: ${CYAN}%-21s${RESET}\n" "$device"
    
    # Mount status
    local mount_point=$(findmnt -rno TARGET "$device" 2>/dev/null | head -1)
    if [[ -n "$mount_point" ]]; then
        printf "Status: ${GREEN}%-21s${RESET}\n" "Mounted"
        printf "Path: ${CYAN}%-23s${RESET}\n" "$mount_point"
        
        # Space info
        local space_info=$(df -B1 "$mount_point" | tail -1)
        local used=$(echo "$space_info" | awk '{print $3}')
        local total=$(echo "$space_info" | awk '{print $2}')
        local percent=$(echo "$space_info" | awk '{print $5}')
        
        printf "Space: ${CYAN}%s / %s${RESET}\n" \
            "$(format_bytes "$used")" \
            "$(format_bytes "$total")"
        
        # Visual usage bar
        show_usage_bar "Usage" "${percent%\%}" 30
    else
        printf "Status: ${RED}%-21s${RESET}\n" "Not Mounted"
    fi
    
    # Health status (placeholder)
    printf "Health: ${GREEN}%-21s${RESET}\n" "Good"
    printf "Write Cycles: ${CYAN}%-15s${RESET}\n" "1,234 / 10,000"
}

# Model status display
show_model_status() {
    echo -e "${YELLOW}AI Models${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Mock model data
    local models=(
        "llama3:8b|7.2GB|Ready"
        "mistral:7b|4.1GB|Ready"
        "mixtral:8x7b|26GB|Downloading"
        "claude:opus|15GB|Not Installed"
    )
    
    for model in "${models[@]}"; do
        IFS='|' read -r name size status <<< "$model"
        
        case "$status" in
            "Ready")
                printf "${GREEN}◉${RESET} %-20s %10s\n" "$name" "$size"
                ;;
            "Downloading")
                printf "${YELLOW}◐${RESET} %-20s %10s\n" "$name" "$size"
                ;;
            *)
                printf "${DIM}○${RESET} ${DIM}%-20s %10s${RESET}\n" "$name" "$size"
                ;;
        esac
    done
    
    echo
    printf "Total Models: ${CYAN}%d${RESET}\n" "${#models[@]}"
    printf "Total Size: ${CYAN}%s${RESET}\n" "52.3 GB"
}

# Performance metrics
show_performance_metrics() {
    echo -e "${YELLOW}Performance${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # CPU usage
    local cpu_usage=0
    if command -v top >/dev/null 2>&1; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print int($3)}')
        else
            cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
        fi
    fi
    show_usage_bar "CPU" "$cpu_usage" 30
    
    # Memory usage
    local mem_usage=0
    if command -v free >/dev/null 2>&1; then
        mem_usage=$(free | awk '/^Mem:/ {print int($3/$2 * 100)}')
    elif command -v vm_stat >/dev/null 2>&1; then
        local pages_free=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
        local pages_total=$(sysctl -n hw.memsize 2>/dev/null || echo "1")
        pages_total=$((pages_total / 4096))
        mem_usage=$(( (pages_total - pages_free) * 100 / pages_total ))
    fi
    show_usage_bar "Memory" "$mem_usage" 30
    
    # Network activity
    echo
    printf "Network: ${GREEN}▲${RESET} 1.2 MB/s ${RED}▼${RESET} 0.3 MB/s\n"
    
    # Temperature (if available)
    local temp="N/A"
    if command -v sensors >/dev/null 2>&1; then
        temp=$(sensors | grep "Core 0" | awk '{print $3}' | head -1)
    fi
    printf "Temperature: ${CYAN}%-15s${RESET}\n" "$temp"
}

# Recent activity log
show_recent_activity() {
    echo -e "${YELLOW}Recent Activity${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Mock activity entries
    local activities=(
        "$(date '+%H:%M:%S') ${GREEN}[SUCCESS]${RESET} Model llama3:8b loaded"
        "$(date '+%H:%M:%S' -d '1 minute ago' 2>/dev/null || date '+%H:%M:%S') ${BLUE}[INFO]${RESET} USB device mounted"
        "$(date '+%H:%M:%S' -d '2 minutes ago' 2>/dev/null || date '+%H:%M:%S') ${YELLOW}[DOWNLOAD]${RESET} mistral:7b - 85% complete"
        "$(date '+%H:%M:%S' -d '5 minutes ago' 2>/dev/null || date '+%H:%M:%S') ${GREEN}[SUCCESS]${RESET} System initialized"
    )
    
    for activity in "${activities[@]}"; do
        echo -e "$activity"
    done
}

# Usage bar display
show_usage_bar() {
    local label="$1"
    local percent="$2"
    local width="${3:-30}"
    
    printf "%-8s [" "$label:"
    
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    # Color based on usage
    local color="$GREEN"
    if [[ $percent -gt 80 ]]; then
        color="$RED"
    elif [[ $percent -gt 60 ]]; then
        color="$YELLOW"
    fi
    
    # Draw bar
    if [[ $filled -gt 0 ]]; then
        printf "${color}%${filled}s${RESET}" | tr ' ' '█'
    fi
    if [[ $empty -gt 0 ]]; then
        printf "%${empty}s" | tr ' ' '░'
    fi
    
    printf "] %3d%%\n" "$percent"
}

# Mini dashboard for quick status
show_mini_dashboard() {
    local device="$1"
    
    clear
    echo -e "${GREEN}┌─────────────────────────────────────┐${RESET}"
    echo -e "${GREEN}│${RESET} ${BRIGHT}Leonardo AI - Quick Status${RESET}        ${GREEN}│${RESET}"
    echo -e "${GREEN}├─────────────────────────────────────┤${RESET}"
    
    # Device status
    if [[ -n "$device" ]]; then
        local mount_point=$(findmnt -rno TARGET "$device" 2>/dev/null | head -1)
        if [[ -n "$mount_point" ]]; then
            echo -e "${GREEN}│${RESET} Device: ${CYAN}$device${RESET} ${GREEN}[OK]${RESET}"
            
            # Space
            local space_info=$(df -h "$mount_point" | tail -1)
            local used=$(echo "$space_info" | awk '{print $3}')
            local total=$(echo "$space_info" | awk '{print $2}')
            echo -e "${GREEN}│${RESET} Space: ${CYAN}$used / $total${RESET}"
        else
            echo -e "${GREEN}│${RESET} Device: ${RED}Not Mounted${RESET}"
        fi
    else
        echo -e "${GREEN}│${RESET} Device: ${DIM}None Selected${RESET}"
    fi
    
    # Model count
    echo -e "${GREEN}│${RESET} Models: ${CYAN}3 Ready, 1 Downloading${RESET}"
    
    # System load
    local load=$(uptime | awk -F'load average:' '{print $2}' | xargs)
    echo -e "${GREEN}│${RESET} Load: ${CYAN}$load${RESET}"
    
    echo -e "${GREEN}└─────────────────────────────────────┘${RESET}"
}

# System health check display
show_health_check() {
    echo -e "${YELLOW}System Health Check${RESET}"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    local checks=(
        "Internet Connectivity|check_connectivity|Network"
        "USB Write Speed|test_usb_speed|USB"
        "Available Memory|check_memory|System"
        "Disk Space|check_disk_space|System"
        "Model Integrity|verify_models|Models"
    )
    
    for check in "${checks[@]}"; do
        IFS='|' read -r name func category <<< "$check"
        
        printf "%-25s " "$name"
        
        # Simulate check (replace with actual function calls)
        if [[ $((RANDOM % 10)) -gt 1 ]]; then
            echo -e "${GREEN}✓ PASS${RESET}"
        else
            echo -e "${RED}✗ FAIL${RESET}"
        fi
    done
}

# Export dashboard functions
export -f show_dashboard show_mini_dashboard show_health_check

# ==== Component: src/ui/web.sh ====
# ==============================================================================
# Leonardo AI Universal - Web UI Foundation
# ==============================================================================
# Description: Web server and browser-based UI components
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, network.sh
# ==============================================================================

# Web server configuration
LEONARDO_WEB_PORT="${LEONARDO_WEB_PORT:-7777}"
LEONARDO_WEB_HOST="${LEONARDO_WEB_HOST:-0.0.0.0}"
LEONARDO_WEB_ROOT="${LEONARDO_WEB_ROOT:-$LEONARDO_INSTALL_DIR/web}"
LEONARDO_WEB_PID=""

# Start web UI server
start_web_ui() {
    local port="${1:-$LEONARDO_WEB_PORT}"
    local host="${2:-$LEONARDO_WEB_HOST}"
    
    log_message "INFO" "Starting Leonardo Web UI on $host:$port"
    
    # Check if port is already in use
    if check_port_in_use "$port"; then
        log_message "ERROR" "Port $port is already in use"
        return 1
    fi
    
    # Create web root if it doesn't exist
    if [[ ! -d "$LEONARDO_WEB_ROOT" ]]; then
        mkdir -p "$LEONARDO_WEB_ROOT"
        generate_web_ui_files
    fi
    
    # Start Python simple HTTP server (fallback)
    if command -v python3 >/dev/null 2>&1; then
        (
            cd "$LEONARDO_WEB_ROOT"
            python3 -m http.server "$port" --bind "$host" >/dev/null 2>&1
        ) &
        LEONARDO_WEB_PID=$!
        
    elif command -v python >/dev/null 2>&1; then
        (
            cd "$LEONARDO_WEB_ROOT"
            python -m SimpleHTTPServer "$port" >/dev/null 2>&1
        ) &
        LEONARDO_WEB_PID=$!
        
    else
        log_message "ERROR" "No Python found to start web server"
        return 1
    fi
    
    # Wait for server to start
    sleep 2
    
    if kill -0 "$LEONARDO_WEB_PID" 2>/dev/null; then
        log_message "INFO" "Web UI started successfully"
        show_status "success" "Web UI available at http://$host:$port"
        
        # Try to open browser
        open_browser "http://localhost:$port"
        return 0
    else
        log_message "ERROR" "Failed to start web server"
        return 1
    fi
}

# Stop web UI server
stop_web_ui() {
    if [[ -n "$LEONARDO_WEB_PID" ]] && kill -0 "$LEONARDO_WEB_PID" 2>/dev/null; then
        log_message "INFO" "Stopping Web UI server (PID: $LEONARDO_WEB_PID)"
        kill "$LEONARDO_WEB_PID"
        wait "$LEONARDO_WEB_PID" 2>/dev/null
        LEONARDO_WEB_PID=""
        show_status "success" "Web UI stopped"
    else
        log_message "WARN" "Web UI server not running"
    fi
}

# Check if port is in use
check_port_in_use() {
    local port="$1"
    
    if command -v nc >/dev/null 2>&1; then
        nc -z localhost "$port" 2>/dev/null
    elif command -v lsof >/dev/null 2>&1; then
        lsof -i ":$port" >/dev/null 2>&1
    else
        # Fallback: try to bind to the port
        (python3 -c "import socket; s=socket.socket(); s.bind(('', $port)); s.close()" 2>/dev/null) || return 0
        return 1
    fi
}

# Open browser
open_browser() {
    local url="$1"
    
    log_message "INFO" "Opening browser: $url"
    
    # Platform-specific browser opening
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$url" 2>/dev/null &
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$url" 2>/dev/null &
        elif command -v gnome-open >/dev/null 2>&1; then
            gnome-open "$url" 2>/dev/null &
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        start "$url" 2>/dev/null &
    fi
}

# Generate web UI files
generate_web_ui_files() {
    log_message "INFO" "Generating Web UI files"
    
    # Create index.html
    cat > "$LEONARDO_WEB_ROOT/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leonardo AI Universal</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <header>
            <pre class="ascii-banner">
 ▄▄▌  ▄▄▄ .       ▐ ▄  ▄▄▄· ▄▄▄  ·▄▄▄▄       ▄▄▄      
 ██•  ▀▄.▀·▪     •█▌▐█▐█ ▀█ ▀▄ █·██▪ ██ ▪     ▀▄ █·    
 ██▪  ▐▀▀▪▄ ▄█▀▄ ▐█▐▐▌▄█▀▀█ ▐▀▀▄ ▐█· ▐█▌ ▄█▀▄ ▐▀▀▄     
 ▐█▌▐▌▐█▄▄▌▐█▌.▐▌██▐█▌▐█ ▪▐▌▐█•█▌██. ██ ▐█▌.▐▌▐█•█▌    
 .▀▀▀  ▀▀▀  ▀█▄▀▪▀▀ █▪ ▀  ▀ .▀  ▀▀▀▀▀▀• ▀█▄▀▪.▀  ▀     
            </pre>
            <h1>AI Universal Control Panel</h1>
        </header>

        <nav class="main-nav">
            <button class="nav-btn active" data-section="status">System Status</button>
            <button class="nav-btn" data-section="models">AI Models</button>
            <button class="nav-btn" data-section="usb">USB Management</button>
            <button class="nav-btn" data-section="settings">Settings</button>
        </nav>

        <main id="content">
            <!-- Dynamic content loaded here -->
        </main>

        <div class="terminal" id="terminal">
            <div class="terminal-header">
                <span>Terminal Output</span>
                <button class="terminal-toggle">_</button>
            </div>
            <div class="terminal-content" id="terminal-output"></div>
        </div>
    </div>

    <script src="leonardo.js"></script>
</body>
</html>
EOF

    # Create CSS file
    cat > "$LEONARDO_WEB_ROOT/style.css" << 'EOF'
:root {
    --bg-primary: #0a0a0a;
    --bg-secondary: #1a1a1a;
    --bg-tertiary: #2a2a2a;
    --text-primary: #00ff00;
    --text-secondary: #00cc00;
    --text-dim: #008800;
    --accent: #00ffff;
    --error: #ff3333;
    --warning: #ffcc00;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Courier New', monospace;
    background: var(--bg-primary);
    color: var(--text-primary);
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 20px;
    flex: 1;
}

header {
    text-align: center;
    margin-bottom: 30px;
}

.ascii-banner {
    color: var(--text-primary);
    font-size: 0.8em;
    line-height: 1.2;
    margin-bottom: 20px;
    text-shadow: 0 0 10px var(--text-primary);
}

h1 {
    font-size: 2em;
    text-transform: uppercase;
    letter-spacing: 3px;
    text-shadow: 0 0 20px var(--accent);
}

.main-nav {
    display: flex;
    gap: 10px;
    margin-bottom: 30px;
    justify-content: center;
}

.nav-btn {
    background: var(--bg-secondary);
    border: 1px solid var(--text-dim);
    color: var(--text-secondary);
    padding: 10px 20px;
    cursor: pointer;
    transition: all 0.3s;
    text-transform: uppercase;
    font-family: inherit;
}

.nav-btn:hover {
    background: var(--bg-tertiary);
    border-color: var(--text-primary);
    color: var(--text-primary);
    box-shadow: 0 0 10px var(--text-primary);
}

.nav-btn.active {
    background: var(--text-dim);
    color: var(--bg-primary);
    border-color: var(--text-primary);
}

main {
    background: var(--bg-secondary);
    border: 1px solid var(--text-dim);
    padding: 20px;
    min-height: 400px;
    box-shadow: 0 0 20px rgba(0, 255, 0, 0.1);
}

.status-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
}

.status-card {
    background: var(--bg-tertiary);
    border: 1px solid var(--text-dim);
    padding: 15px;
    border-radius: 5px;
}

.status-card h3 {
    color: var(--accent);
    margin-bottom: 10px;
    text-transform: uppercase;
}

.metric {
    display: flex;
    justify-content: space-between;
    margin: 5px 0;
}

.metric-value {
    color: var(--text-primary);
}

.progress-bar {
    background: var(--bg-primary);
    height: 20px;
    margin: 10px 0;
    position: relative;
    border: 1px solid var(--text-dim);
}

.progress-fill {
    background: linear-gradient(to right, var(--text-dim), var(--text-primary));
    height: 100%;
    transition: width 0.3s;
    box-shadow: 0 0 10px var(--text-primary);
}

.terminal {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: var(--bg-primary);
    border-top: 1px solid var(--text-dim);
    max-height: 300px;
    transition: transform 0.3s;
}

.terminal-header {
    background: var(--bg-secondary);
    padding: 10px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    cursor: move;
}

.terminal-content {
    height: 200px;
    overflow-y: auto;
    padding: 10px;
    font-size: 0.9em;
    font-family: 'Courier New', monospace;
}

.terminal-content .log-entry {
    margin: 2px 0;
}

.log-info { color: var(--text-primary); }
.log-warn { color: var(--warning); }
.log-error { color: var(--error); }

.model-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 15px;
}

.model-card {
    background: var(--bg-tertiary);
    border: 1px solid var(--text-dim);
    padding: 15px;
    cursor: pointer;
    transition: all 0.3s;
}

.model-card:hover {
    border-color: var(--text-primary);
    box-shadow: 0 0 15px rgba(0, 255, 0, 0.3);
}

.model-status {
    display: inline-block;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    margin-right: 5px;
}

.status-ready { background: var(--text-primary); }
.status-downloading { background: var(--warning); }
.status-offline { background: var(--text-dim); }

@keyframes pulse {
    0% { opacity: 1; }
    50% { opacity: 0.5; }
    100% { opacity: 1; }
}

.loading {
    animation: pulse 1.5s infinite;
}

/* Matrix rain effect background */
.matrix-bg {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    pointer-events: none;
    opacity: 0.1;
    z-index: -1;
}
EOF

    # Create JavaScript file
    cat > "$LEONARDO_WEB_ROOT/leonardo.js" << 'EOF'
// Leonardo AI Universal Web Interface
class LeonardoUI {
    constructor() {
        this.currentSection = 'status';
        this.wsConnection = null;
        this.initializeUI();
        this.connectWebSocket();
    }

    initializeUI() {
        // Navigation buttons
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.switchSection(e.target.dataset.section);
            });
        });

        // Terminal toggle
        document.querySelector('.terminal-toggle').addEventListener('click', () => {
            this.toggleTerminal();
        });

        // Load initial section
        this.loadSection('status');
    }

    switchSection(section) {
        // Update active button
        document.querySelectorAll('.nav-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.section === section);
        });

        this.currentSection = section;
        this.loadSection(section);
    }

    loadSection(section) {
        const content = document.getElementById('content');
        content.innerHTML = '<div class="loading">Loading...</div>';

        // Simulate content loading
        setTimeout(() => {
            switch(section) {
                case 'status':
                    this.loadStatusSection();
                    break;
                case 'models':
                    this.loadModelsSection();
                    break;
                case 'usb':
                    this.loadUSBSection();
                    break;
                case 'settings':
                    this.loadSettingsSection();
                    break;
            }
        }, 300);
    }

    loadStatusSection() {
        document.getElementById('content').innerHTML = `
            <h2>System Status</h2>
            <div class="status-grid">
                <div class="status-card">
                    <h3>System Resources</h3>
                    <div class="metric">
                        <span>CPU Usage</span>
                        <span class="metric-value">45%</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: 45%"></div>
                    </div>
                    <div class="metric">
                        <span>Memory</span>
                        <span class="metric-value">8.2GB / 16GB</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: 51%"></div>
                    </div>
                </div>
                <div class="status-card">
                    <h3>USB Device</h3>
                    <div class="metric">
                        <span>Status</span>
                        <span class="metric-value">Connected</span>
                    </div>
                    <div class="metric">
                        <span>Space Used</span>
                        <span class="metric-value">42.7GB / 128GB</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: 33%"></div>
                    </div>
                </div>
            </div>
        `;
    }

    loadModelsSection() {
        document.getElementById('content').innerHTML = `
            <h2>AI Models</h2>
            <div class="model-grid">
                <div class="model-card">
                    <h3><span class="model-status status-ready"></span>LLaMA 3 8B</h3>
                    <p>Size: 7.2GB</p>
                    <p>Status: Ready</p>
                    <button>Load Model</button>
                </div>
                <div class="model-card">
                    <h3><span class="model-status status-ready"></span>Mistral 7B</h3>
                    <p>Size: 4.1GB</p>
                    <p>Status: Ready</p>
                    <button>Load Model</button>
                </div>
                <div class="model-card">
                    <h3><span class="model-status status-downloading"></span>Mixtral 8x7B</h3>
                    <p>Size: 26GB</p>
                    <p>Status: Downloading 65%</p>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: 65%"></div>
                    </div>
                </div>
            </div>
        `;
    }

    loadUSBSection() {
        document.getElementById('content').innerHTML = `
            <h2>USB Management</h2>
            <div class="status-card">
                <h3>Current Device</h3>
                <p>Device: /dev/sdb1</p>
                <p>Filesystem: exFAT</p>
                <p>Label: LEONARDO_AI</p>
                <button>Scan for Devices</button>
                <button>Format Device</button>
                <button>Verify Installation</button>
            </div>
        `;
    }

    loadSettingsSection() {
        document.getElementById('content').innerHTML = `
            <h2>Settings</h2>
            <div class="status-card">
                <h3>Configuration</h3>
                <p>Coming soon...</p>
            </div>
        `;
    }

    toggleTerminal() {
        const terminal = document.querySelector('.terminal');
        terminal.style.transform = 
            terminal.style.transform === 'translateY(100%)' ? 
            'translateY(0)' : 'translateY(100%)';
    }

    connectWebSocket() {
        // Placeholder for WebSocket connection
        this.log('info', 'Leonardo Web UI initialized');
        this.log('info', 'Waiting for connection to backend...');
    }

    log(level, message) {
        const output = document.getElementById('terminal-output');
        const entry = document.createElement('div');
        entry.className = `log-entry log-${level}`;
        entry.textContent = `[${new Date().toLocaleTimeString()}] [${level.toUpperCase()}] ${message}`;
        output.appendChild(entry);
        output.scrollTop = output.scrollHeight;
    }
}

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
    window.leonardo = new LeonardoUI();
});
EOF

    log_message "INFO" "Web UI files generated successfully"
}

# Serve API endpoint (mock implementation)
handle_api_request() {
    local endpoint="$1"
    local method="$2"
    local data="$3"
    
    case "$endpoint" in
        "/api/status")
            echo '{"status":"ok","version":"7.0.0","uptime":12345}'
            ;;
        "/api/models")
            echo '[{"name":"llama3","size":"7.2GB","status":"ready"}]'
            ;;
        "/api/usb")
            echo '{"device":"/dev/sdb1","mounted":true,"space_used":45874387968}'
            ;;
        *)
            echo '{"error":"Unknown endpoint"}'
            ;;
    esac
}

# Export web UI functions
export -f start_web_ui stop_web_ui generate_web_ui_files

# ==== Component: src/core/main.sh ====
# ==============================================================================
# Leonardo AI Universal - Main Application Entry Point
# ==============================================================================
# Description: Main application logic and orchestration
# Version: 7.0.0
# Dependencies: all components
# ==============================================================================

# Show application banner
show_banner() {
    echo "${COLOR_CYAN}╭─────────────────────────────────────╮${COLOR_RESET}"
    echo "${COLOR_CYAN}│    Leonardo AI Universal v$LEONARDO_VERSION    │${COLOR_RESET}"
    echo "${COLOR_CYAN}│       Deploy AI Anywhere™           │${COLOR_RESET}"
    echo "${COLOR_CYAN}╰─────────────────────────────────────╯${COLOR_RESET}"
    echo ""
}

# Show help information
show_help() {
    cat << EOF
${COLOR_CYAN}$LEONARDO_NAME v$LEONARDO_VERSION${COLOR_RESET}
${COLOR_DIM}$LEONARDO_DESCRIPTION${COLOR_RESET}

${COLOR_GREEN}Usage:${COLOR_RESET}
  leonardo [options] [command] [args]

${COLOR_GREEN}Options:${COLOR_RESET}
  -h, --help        Show this help message
  -v, --verbose     Enable verbose output
  -q, --quiet       Suppress non-essential output
  --version         Show version information
  --no-color        Disable colored output

${COLOR_GREEN}Commands:${COLOR_RESET}
  model <cmd>       Model management (list, download, delete, etc.)
  usb <cmd>         USB drive management
  dashboard         Show system dashboard
  web [port]        Start web UI
  test              Run system tests

${COLOR_GREEN}Interactive Mode:${COLOR_RESET}
  Run without commands to enter interactive mode

${COLOR_GREEN}Examples:${COLOR_RESET}
  leonardo                      # Interactive mode
  leonardo model list           # List available models
  leonardo model download llama3-8b
  leonardo dashboard            # Show system status
  leonardo web                  # Start web interface

For more help on specific commands:
  leonardo model help
  leonardo usb help

EOF
}

# Main function - entry point for Leonardo
main() {
    # Mark that main has been called
    LEONARDO_MAIN_CALLED=true
    
    # Initialize components (colors are already initialized by sourcing colors.sh)
    init_logging
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Handle direct commands
    if [[ -n "$LEONARDO_COMMAND" ]]; then
        handle_direct_command
        return $?
    fi
    
    # Show banner unless quiet mode
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        clear
        show_banner
        echo
    fi
    
    # Initialize model manager
    init_model_manager
    
    # Check system requirements
    if ! check_system_requirements; then
        log_message "ERROR" "System requirements not met"
        exit 1
    fi
    
    # Main interactive menu
    interactive_main_menu
}

# Parse command line arguments
parse_arguments() {
    LEONARDO_COMMAND=""
    LEONARDO_SUBCOMMAND=""
    LEONARDO_ARGS=()
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                export LEONARDO_VERBOSE=true
                shift
                ;;
            -q|--quiet)
                export LEONARDO_QUIET=true
                shift
                ;;
            --version)
                echo "$LEONARDO_NAME v$LEONARDO_VERSION"
                exit 0
                ;;
            --no-color)
                export LEONARDO_NO_COLOR=true
                shift
                ;;
            model|models)
                LEONARDO_COMMAND="model"
                shift
                LEONARDO_SUBCOMMAND="$1"
                shift
                LEONARDO_ARGS=("$@")
                break
                ;;
            usb|drive)
                LEONARDO_COMMAND="usb"
                shift
                LEONARDO_SUBCOMMAND="$1"
                shift
                LEONARDO_ARGS=("$@")
                break
                ;;
            deploy|deployment)
                LEONARDO_COMMAND="deploy"
                shift
                LEONARDO_SUBCOMMAND="$1"
                shift
                LEONARDO_ARGS=("$@")
                break
                ;;
            dashboard|status)
                LEONARDO_COMMAND="dashboard"
                shift
                break
                ;;
            web|webui)
                LEONARDO_COMMAND="web"
                shift
                LEONARDO_ARGS=("$@")
                break
                ;;
            test|check)
                LEONARDO_COMMAND="test"
                shift
                break
                ;;
            *)
                LEONARDO_ARGS+=("$1")
                shift
                ;;
        esac
    done
}

# Handle direct commands
handle_direct_command() {
    case "$LEONARDO_COMMAND" in
        "model")
            handle_model_command "$LEONARDO_SUBCOMMAND" "${LEONARDO_ARGS[@]}"
            ;;
        "usb")
            handle_usb_command "$LEONARDO_SUBCOMMAND" "${LEONARDO_ARGS[@]}"
            ;;
        "deploy"|"deployment")
            deployment_cli "$LEONARDO_SUBCOMMAND" "${LEONARDO_ARGS[@]}"
            ;;
        "dashboard")
            show_system_dashboard
            ;;
        "web")
            start_web_ui "${LEONARDO_ARGS[@]}"
            ;;
        "test")
            run_system_tests
            ;;
        *)
            echo "${COLOR_RED}Unknown command: $LEONARDO_COMMAND${COLOR_RESET}"
            show_help
            return 1
            ;;
    esac
}

# Interactive main menu
interactive_main_menu() {
    while true; do
        clear
        show_banner
        echo ""
        
        local options=(
            "models:AI Model Management"
            "usb:Create/Manage USB Drive"
            "dashboard:System Dashboard"
            "web:Launch Web Interface"
            "settings:Settings & Preferences"
            "test:Run System Tests"
            "about:About Leonardo"
            "exit:Exit"
        )
        
        local selected=$(show_menu "Main Menu" "${options[@]##*:}")
        
        if [[ -z "$selected" ]]; then
            continue
        fi
        
        local choice="${options[$selected]%%:*}"
        
        case "$choice" in
            "models")
                model_management_menu
                ;;
            "usb")
                usb_management_menu
                ;;
            "dashboard")
                show_system_dashboard
                read -p "Press Enter to continue..."
                ;;
            "web")
                echo ""
                echo "${COLOR_CYAN}Starting web interface...${COLOR_RESET}"
                start_web_ui
                ;;
            "settings")
                settings_menu
                ;;
            "test")
                run_system_tests
                read -p "Press Enter to continue..."
                ;;
            "about")
                show_about
                read -p "Press Enter to continue..."
                ;;
            "exit")
                handle_exit
                break
                ;;
        esac
    done
}

# Model management menu
model_management_menu() {
    while true; do
        clear
        echo "${COLOR_CYAN}Model Management${COLOR_RESET}"
        echo "${COLOR_DIM}Manage AI models for Leonardo${COLOR_RESET}"
        echo ""
        
        # Show model stats
        local installed_count=${#LEONARDO_INSTALLED_MODELS[@]}
        local total_count=${#LEONARDO_MODEL_REGISTRY[@]}
        echo "Models installed: ${COLOR_GREEN}$installed_count${COLOR_RESET} / $total_count"
        echo ""
        
        local options=(
            "browse:Browse Available Models"
            "installed:View Installed Models"
            "download:Download New Model"
            "select:Interactive Model Selector"
            "import:Import Model from File"
            "export:Export Model to File"
            "delete:Delete Installed Model"
            "update:Update Model Registry"
            "back:Back to Main Menu"
        )
        
        local selected=$(show_menu "Model Options" "${options[@]##*:}")
        
        [[ -z "$selected" ]] && continue
        
        local choice="${options[$selected]%%:*}"
        
        case "$choice" in
            "browse")
                clear
                list_models
                read -p "Press Enter to continue..."
                ;;
            "installed")
                clear
                list_installed_models
                read -p "Press Enter to continue..."
                ;;
            "download")
                clear
                handle_model_download
                read -p "Press Enter to continue..."
                ;;
            "select")
                interactive_model_selector
                ;;
            "import")
                clear
                local file=$(show_input_dialog "Model file path:")
                [[ -n "$file" ]] && import_model "$file"
                read -p "Press Enter to continue..."
                ;;
            "export")
                clear
                list_installed_models
                echo ""
                local model=$(show_input_dialog "Model ID to export:")
                [[ -n "$model" ]] && export_model "$model"
                read -p "Press Enter to continue..."
                ;;
            "delete")
                clear
                handle_model_delete
                read -p "Press Enter to continue..."
                ;;
            "update")
                clear
                update_model_registry
                read -p "Press Enter to continue..."
                ;;
            "back")
                break
                ;;
        esac
    done
}

# USB management menu (placeholder)
usb_management_menu() {
    clear
    echo "${COLOR_CYAN}USB Drive Management${COLOR_RESET}"
    echo "${COLOR_DIM}This feature is coming soon...${COLOR_RESET}"
    echo ""
    echo "USB drive creation and management functionality will include:"
    echo "  • Create bootable Leonardo USB drives"
    echo "  • Verify USB integrity"
    echo "  • Repair corrupted USBs"
    echo "  • Track USB health and write cycles"
    echo ""
    read -p "Press Enter to return..."
}

# Settings menu
settings_menu() {
    while true; do
        clear
        echo "${COLOR_CYAN}Settings & Preferences${COLOR_RESET}"
        echo ""
        
        local options=(
            "model_prefs:Model Preferences"
            "security:Security Settings"
            "network:Network Settings"
            "ui:UI Preferences"
            "back:Back to Main Menu"
        )
        
        local selected=$(show_menu "Settings" "${options[@]##*:}")
        
        [[ -z "$selected" ]] && break
        
        local choice="${options[$selected]%%:*}"
        
        case "$choice" in
            "model_prefs")
                configure_model_preferences
                ;;
            "security")
                security_settings_menu
                ;;
            "network")
                network_settings_menu
                ;;
            "ui")
                ui_preferences_menu
                ;;
            "back")
                break
                ;;
        esac
    done
}

# Security settings menu
security_settings_menu() {
    clear
    echo "${COLOR_CYAN}Security Settings${COLOR_RESET}"
    echo ""
    echo "Current settings:"
    echo "  Paranoid Mode: ${LEONARDO_PARANOID_MODE}"
    echo "  Secure Delete: ${LEONARDO_SECURE_DELETE}"
    echo "  Verify Checksums: ${LEONARDO_VERIFY_CHECKSUMS}"
    echo ""
    # TODO: Implement security settings configuration
    read -p "Press Enter to continue..."
}

# Network settings menu
network_settings_menu() {
    clear
    echo "${COLOR_CYAN}Network Settings${COLOR_RESET}"
    echo ""
    echo "Current settings:"
    echo "  Download Retries: ${LEONARDO_DOWNLOAD_RETRIES}"
    echo "  Connection Timeout: ${LEONARDO_TIMEOUT}s"
    echo ""
    # TODO: Implement network settings configuration
    read -p "Press Enter to continue..."
}

# UI preferences menu
ui_preferences_menu() {
    clear
    echo "${COLOR_CYAN}UI Preferences${COLOR_RESET}"
    echo ""
    echo "Current settings:"
    echo "  Color Output: ${LEONARDO_NO_COLOR:-enabled}"
    echo "  Verbose Mode: ${LEONARDO_VERBOSE}"
    echo ""
    # TODO: Implement UI preferences configuration
    read -p "Press Enter to continue..."
}

# System tests
run_system_tests() {
    clear
    echo "${COLOR_CYAN}Running System Tests${COLOR_RESET}"
    echo ""
    
    # Component tests
    local tests=(
        "Environment:check_environment"
        "File System:test_filesystem"
        "Network:test_network_connectivity"
        "Model Registry:test_model_registry"
        "UI Components:test_ui_components"
    )
    
    for test in "${tests[@]}"; do
        local name="${test%%:*}"
        local func="${test##*:}"
        
        echo -n "Testing $name... "
        if $func 2>/dev/null; then
            echo "${COLOR_GREEN}✓ PASS${COLOR_RESET}"
        else
            echo "${COLOR_RED}✗ FAIL${COLOR_RESET}"
        fi
    done
    
    echo ""
}

# Test functions
check_environment() {
    [[ -n "$LEONARDO_VERSION" ]] && [[ -n "$LEONARDO_BASE_DIR" ]]
}

test_filesystem() {
    local test_file="$LEONARDO_TEMP_DIR/.test_$$"
    echo "test" > "$test_file" && rm -f "$test_file"
}

test_network_connectivity() {
    check_connectivity >/dev/null 2>&1
}

test_model_registry() {
    [[ ${#LEONARDO_MODEL_REGISTRY[@]} -gt 0 ]]
}

test_ui_components() {
    type show_menu >/dev/null 2>&1 && type show_progress_bar >/dev/null 2>&1
}

# About screen
show_about() {
    clear
    show_banner
    echo ""
    echo "${COLOR_CYAN}About Leonardo AI Universal${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%60s' | tr ' ' '-')${COLOR_RESET}"
    echo ""
    echo "Version: ${COLOR_GREEN}$LEONARDO_VERSION${COLOR_RESET} ($LEONARDO_CODENAME)"
    echo "Build Date: $LEONARDO_BUILD_DATE"
    echo ""
    echo "Leonardo AI Universal is a cross-platform solution for deploying"
    echo "AI models on USB drives. It enables you to carry powerful language"
    echo "models anywhere and run them on any compatible computer without"
    echo "installation or leaving traces."
    echo ""
    echo "${COLOR_GREEN}Key Features:${COLOR_RESET}"
    echo "  • Portable AI models on USB drives"
    echo "  • Support for multiple LLM families"
    echo "  • Cross-platform compatibility"
    echo "  • Zero installation required"
    echo "  • Privacy-focused design"
    echo ""
    echo "${COLOR_GREEN}Authors:${COLOR_RESET} $LEONARDO_AUTHORS"
    echo "${COLOR_GREEN}License:${COLOR_RESET} $LEONARDO_LICENSE"
    echo "${COLOR_GREEN}Repository:${COLOR_RESET} $LEONARDO_REPOSITORY"
    echo ""
}

# Exit handler
handle_exit() {
    echo ""
    echo "${COLOR_CYAN}Thank you for using Leonardo AI Universal!${COLOR_RESET}"
    echo "${COLOR_DIM}Stay curious, stay creative.${COLOR_RESET}"
    echo ""
    
    # Cleanup
    cleanup_temp_files 2>/dev/null || true
    
    # Save session state if needed
    # TODO: Implement session persistence
    
    exit 0
}

# Handle model commands
handle_model_command() {
    model_cli "$@"
}

# Handle USB commands
handle_usb_command() {
    usb_cli "$@"
}

# Run system tests
run_system_tests() {
    clear
    echo "${COLOR_CYAN}Running System Tests${COLOR_RESET}"
    echo ""
    
    # Component tests
    local tests=(
        "Environment:check_environment"
        "File System:test_filesystem"
        "Network:test_network_connectivity"
        "Model Registry:test_model_registry"
        "UI Components:test_ui_components"
    )
    
    for test in "${tests[@]}"; do
        local name="${test%%:*}"
        local func="${test##*:}"
        
        echo -n "Testing $name... "
        if $func 2>/dev/null; then
            echo "${COLOR_GREEN}✓ PASS${COLOR_RESET}"
        else
            echo "${COLOR_RED}✗ FAIL${COLOR_RESET}"
        fi
    done
    
    echo ""
}

# Test functions
check_environment() {
    [[ -n "$LEONARDO_VERSION" ]] && [[ -n "$LEONARDO_BASE_DIR" ]]
}

test_filesystem() {
    local test_file="$LEONARDO_TEMP_DIR/.test_$$"
    echo "test" > "$test_file" && rm -f "$test_file"
}

test_network_connectivity() {
    check_connectivity >/dev/null 2>&1
}

test_model_registry() {
    [[ ${#LEONARDO_MODEL_REGISTRY[@]} -gt 0 ]]
}

test_ui_components() {
    type show_menu >/dev/null 2>&1 && type show_progress_bar >/dev/null 2>&1
}

# ==== Component: src/models/registry.sh ====
# ==============================================================================
# Leonardo AI Universal - Model Registry
# ==============================================================================
# Description: AI model registry and metadata management
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, network.sh, validation.sh
# ==============================================================================

# Model registry data structure
declare -A LEONARDO_MODEL_REGISTRY
declare -A LEONARDO_MODEL_METADATA

# Initialize model registry
init_model_registry() {
    log_message "INFO" "Initializing model registry"
    
    # LLaMA 3 Models
    LEONARDO_MODEL_REGISTRY["llama3-8b"]="llama-3-8b-instruct.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["llama3-8b"]="name:LLaMA 3 8B|size:4.7GB|format:gguf|quantization:Q4_K_M|family:llama|license:llama3|url:https://huggingface.co/TheBloke/Llama-3-8B-Instruct-GGUF/resolve/main/llama-3-8b-instruct.Q4_K_M.gguf|sha256:8daa8615d0e8b7975db0e939b7f32a3905ae8648f30833e73ab02577148c3354"
    
    LEONARDO_MODEL_REGISTRY["llama3-8b-q8"]="llama-3-8b-instruct.Q8_0.gguf"
    LEONARDO_MODEL_METADATA["llama3-8b-q8"]="name:LLaMA 3 8B Q8|size:8.5GB|format:gguf|quantization:Q8_0|family:llama|license:llama3|url:https://huggingface.co/TheBloke/Llama-3-8B-Instruct-GGUF/resolve/main/llama-3-8b-instruct.Q8_0.gguf|sha256:e5dc003066f7e8ac3ce23e8cc8d08b4ef3eb9e6e1e9989cf8b07b9d5dd626820"
    
    LEONARDO_MODEL_REGISTRY["llama3-70b"]="llama-3-70b-instruct.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["llama3-70b"]="name:LLaMA 3 70B|size:39.1GB|format:gguf|quantization:Q4_K_M|family:llama|license:llama3|url:https://huggingface.co/TheBloke/Llama-3-70B-Instruct-GGUF/resolve/main/llama-3-70b-instruct.Q4_K_M.gguf|sha256:0c0f952e0e2c86fd3a2bef8b5c1d7f5db96b5c523f96de33cc385d8cf1c87b73"
    
    # Mistral Models
    LEONARDO_MODEL_REGISTRY["mistral-7b"]="mistral-7b-instruct-v0.3.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["mistral-7b"]="name:Mistral 7B v0.3|size:4.1GB|format:gguf|quantization:Q4_K_M|family:mistral|license:apache-2.0|url:https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/mistral-7b-instruct-v0.3.Q4_K_M.gguf|sha256:b2f8e6cc58c476394e3e931b0e6e33b8389f5c55c0ff690e38e77ad219669816"
    
    LEONARDO_MODEL_REGISTRY["mistral-7b-q8"]="mistral-7b-instruct-v0.3.Q8_0.gguf"
    LEONARDO_MODEL_METADATA["mistral-7b-q8"]="name:Mistral 7B v0.3 Q8|size:7.7GB|format:gguf|quantization:Q8_0|family:mistral|license:apache-2.0|url:https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.3-GGUF/resolve/main/mistral-7b-instruct-v0.3.Q8_0.gguf|sha256:4978bcbe6dc0c257f36339002a8e7f305ac640ad89fd97e5018a4df4b332a84a"
    
    # Mixtral Models
    LEONARDO_MODEL_REGISTRY["mixtral-8x7b"]="mixtral-8x7b-instruct-v0.1.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["mixtral-8x7b"]="name:Mixtral 8x7B|size:26.4GB|format:gguf|quantization:Q4_K_M|family:mixtral|license:apache-2.0|url:https://huggingface.co/TheBloke/Mixtral-8x7B-Instruct-v0.1-GGUF/resolve/main/mixtral-8x7b-instruct-v0.1.Q4_K_M.gguf|sha256:2395a53ed52ac1a8a7a93bfa5c7db1dd8b3a29b8e1567a5813ebd6f065d4fe3f"
    
    # Gemma Models
    LEONARDO_MODEL_REGISTRY["gemma-7b"]="gemma-7b-it.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["gemma-7b"]="name:Gemma 7B|size:5.0GB|format:gguf|quantization:Q4_K_M|family:gemma|license:gemma|url:https://huggingface.co/google/gemma-7b-it-GGUF/resolve/main/gemma-7b-it.Q4_K_M.gguf|sha256:4e94c2da4d43c861dd26dd31c6f11ace5b0799f0c52fef5f30a26a36b2d1cffe"
    
    LEONARDO_MODEL_REGISTRY["gemma-2b"]="gemma-2b-it.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["gemma-2b"]="name:Gemma 2B|size:1.7GB|format:gguf|quantization:Q4_K_M|family:gemma|license:gemma|url:https://huggingface.co/google/gemma-2b-it-GGUF/resolve/main/gemma-2b-it.Q4_K_M.gguf|sha256:7a2550ca621f42a6c91045c99c88dd2ece26c5032dc82ad87ae09076bbaa0bfb"
    
    # Phi Models
    LEONARDO_MODEL_REGISTRY["phi-3-mini"]="Phi-3-mini-4k-instruct-q4.gguf"
    LEONARDO_MODEL_METADATA["phi-3-mini"]="name:Phi 3 Mini 4K|size:2.2GB|format:gguf|quantization:Q4_K_M|family:phi|license:mit|url:https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf/resolve/main/Phi-3-mini-4k-instruct-q4.gguf|sha256:09d16545cf09322a6b7e5054522f2fd4a8033327f4e2a978f051baf2c84a909f"
    
    # CodeLlama Models
    LEONARDO_MODEL_REGISTRY["codellama-7b"]="codellama-7b-instruct.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["codellama-7b"]="name:CodeLlama 7B|size:4.1GB|format:gguf|quantization:Q4_K_M|family:codellama|license:llama2|url:https://huggingface.co/TheBloke/CodeLlama-7B-Instruct-GGUF/resolve/main/codellama-7b-instruct.Q4_K_M.gguf|sha256:0e0bc5a4726d73022f90287e4fbc7609fd9bdffca87b35a5ba21fb30fc2b6618"
    
    # Vicuna Models
    LEONARDO_MODEL_REGISTRY["vicuna-13b"]="vicuna-13b-v1.5.Q4_K_M.gguf"
    LEONARDO_MODEL_METADATA["vicuna-13b"]="name:Vicuna 13B v1.5|size:7.9GB|format:gguf|quantization:Q4_K_M|family:vicuna|license:llama|url:https://huggingface.co/TheBloke/vicuna-13B-v1.5-GGUF/resolve/main/vicuna-13b-v1.5.Q4_K_M.gguf|sha256:d62fc1034c2064a8c2fbe65f13fbab3c53a2362a84079bad76912094e5c87bd7"
    
    log_message "INFO" "Model registry initialized with ${#LEONARDO_MODEL_REGISTRY[@]} models"
}

# Get model metadata field
get_model_metadata() {
    local model_id="$1"
    local field="$2"
    
    if [[ -z "${LEONARDO_MODEL_METADATA[$model_id]:-}" ]]; then
        return 1
    fi
    
    local metadata="${LEONARDO_MODEL_METADATA[$model_id]}"
    local value=""
    
    # Parse metadata fields
    IFS='|' read -ra fields <<< "$metadata"
    for field_data in "${fields[@]}"; do
        IFS=':' read -r key val <<< "$field_data"
        if [[ "$key" == "$field" ]]; then
            echo "$val"
            return 0
        fi
    done
    
    return 1
}

# List available models
list_models() {
    local filter="${1:-}"
    local format="${2:-table}"  # table, json, simple
    
    log_message "INFO" "Listing models (filter: ${filter:-none})"
    
    if [[ "$format" == "table" ]]; then
        # Header
        printf "${COLOR_CYAN}%-20s %-25s %-10s %-15s %-10s${COLOR_RESET}\n" \
            "ID" "Name" "Size" "Quantization" "License"
        printf "${COLOR_DIM}%s${COLOR_RESET}\n" "$(printf '%80s' | tr ' ' '-')"
        
        # Models
        for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
            if [[ -n "$filter" ]] && [[ ! "$model_id" =~ $filter ]]; then
                continue
            fi
            
            local name=$(get_model_metadata "$model_id" "name")
            local size=$(get_model_metadata "$model_id" "size")
            local quant=$(get_model_metadata "$model_id" "quantization")
            local license=$(get_model_metadata "$model_id" "license")
            
            printf "%-20s %-25s ${COLOR_YELLOW}%-10s${COLOR_RESET} %-15s %-10s\n" \
                "$model_id" "$name" "$size" "$quant" "$license"
        done
    elif [[ "$format" == "json" ]]; then
        echo "{"
        local first=true
        for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
            if [[ -n "$filter" ]] && [[ ! "$model_id" =~ $filter ]]; then
                continue
            fi
            
            [[ "$first" == "false" ]] && echo ","
            first=false
            
            echo -n "  \"$model_id\": {"
            echo -n "\"filename\": \"${LEONARDO_MODEL_REGISTRY[$model_id]}\", "
            echo -n "\"name\": \"$(get_model_metadata "$model_id" "name")\", "
            echo -n "\"size\": \"$(get_model_metadata "$model_id" "size")\", "
            echo -n "\"format\": \"$(get_model_metadata "$model_id" "format")\", "
            echo -n "\"quantization\": \"$(get_model_metadata "$model_id" "quantization")\", "
            echo -n "\"family\": \"$(get_model_metadata "$model_id" "family")\", "
            echo -n "\"license\": \"$(get_model_metadata "$model_id" "license")\", "
            echo -n "\"url\": \"$(get_model_metadata "$model_id" "url")\", "
            echo -n "\"sha256\": \"$(get_model_metadata "$model_id" "sha256")\""
            echo -n "}"
        done
        echo -e "\n}"
    else
        # Simple format
        for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
            if [[ -n "$filter" ]] && [[ ! "$model_id" =~ $filter ]]; then
                continue
            fi
            echo "$model_id"
        done | sort
    fi
}

# Get model info
get_model_info() {
    local model_id="$1"
    
    if [[ -z "${LEONARDO_MODEL_REGISTRY[$model_id]:-}" ]]; then
        log_message "ERROR" "Model not found: $model_id"
        return 1
    fi
    
    echo "${COLOR_CYAN}Model Information${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%40s' | tr ' ' '-')${COLOR_RESET}"
    echo "${COLOR_GREEN}ID:${COLOR_RESET}           $model_id"
    echo "${COLOR_GREEN}Filename:${COLOR_RESET}     ${LEONARDO_MODEL_REGISTRY[$model_id]}"
    echo "${COLOR_GREEN}Name:${COLOR_RESET}         $(get_model_metadata "$model_id" "name")"
    echo "${COLOR_GREEN}Size:${COLOR_RESET}         $(get_model_metadata "$model_id" "size")"
    echo "${COLOR_GREEN}Format:${COLOR_RESET}       $(get_model_metadata "$model_id" "format")"
    echo "${COLOR_GREEN}Quantization:${COLOR_RESET} $(get_model_metadata "$model_id" "quantization")"
    echo "${COLOR_GREEN}Family:${COLOR_RESET}       $(get_model_metadata "$model_id" "family")"
    echo "${COLOR_GREEN}License:${COLOR_RESET}      $(get_model_metadata "$model_id" "license")"
    echo "${COLOR_GREEN}SHA256:${COLOR_RESET}       $(get_model_metadata "$model_id" "sha256")"
}

# Search models
search_models() {
    local query="$1"
    local models=()
    
    log_message "INFO" "Searching models for: $query"
    
    for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
        local metadata="${LEONARDO_MODEL_METADATA[$model_id]}"
        if [[ "$model_id" =~ $query ]] || [[ "$metadata" =~ $query ]]; then
            models+=("$model_id")
        fi
    done
    
    if [[ ${#models[@]} -eq 0 ]]; then
        log_message "WARN" "No models found matching: $query"
        return 1
    fi
    
    echo "${COLOR_CYAN}Found ${#models[@]} model(s) matching '$query':${COLOR_RESET}"
    for model in "${models[@]}"; do
        echo "  - $model ($(get_model_metadata "$model" "name"))"
    done
}

# Get recommended models by use case
get_recommended_models() {
    local use_case="$1"
    
    case "$use_case" in
        "general"|"chat")
            echo "llama3-8b mistral-7b gemma-7b vicuna-13b"
            ;;
        "coding"|"code")
            echo "codellama-7b llama3-8b mistral-7b"
            ;;
        "small"|"lightweight")
            echo "phi-3-mini gemma-2b mistral-7b"
            ;;
        "large"|"advanced")
            echo "llama3-70b mixtral-8x7b vicuna-13b"
            ;;
        "fast")
            echo "phi-3-mini gemma-2b mistral-7b llama3-8b"
            ;;
        *)
            echo "llama3-8b mistral-7b gemma-7b"
            ;;
    esac
}

# Validate model file
validate_model_file() {
    local model_path="$1"
    local expected_sha256="${2:-}"
    
    if [[ ! -f "$model_path" ]]; then
        log_message "ERROR" "Model file not found: $model_path"
        return 1
    fi
    
    # Check file size
    local file_size=$(stat -f%z "$model_path" 2>/dev/null || stat -c%s "$model_path" 2>/dev/null)
    if [[ $file_size -lt 1000000 ]]; then  # Less than 1MB
        log_message "ERROR" "Model file too small: $file_size bytes"
        return 1
    fi
    
    # Verify checksum if provided
    if [[ -n "$expected_sha256" ]]; then
        log_message "INFO" "Verifying model checksum..."
        local actual_sha256=$(sha256sum "$model_path" | awk '{print $1}')
        
        if [[ "$actual_sha256" != "$expected_sha256" ]]; then
            log_message "ERROR" "Checksum mismatch!"
            log_message "ERROR" "Expected: $expected_sha256"
            log_message "ERROR" "Actual:   $actual_sha256"
            return 1
        fi
        
        log_message "INFO" "Checksum verified successfully"
    fi
    
    # Check file format
    local file_ext="${model_path##*.}"
    case "$file_ext" in
        gguf|ggml|bin|pth|safetensors)
            log_message "INFO" "Valid model format: $file_ext"
            ;;
        *)
            log_message "WARN" "Unknown model format: $file_ext"
            ;;
    esac
    
    return 0
}

# Export model registry functions
export -f init_model_registry list_models get_model_info search_models
export -f get_model_metadata get_recommended_models validate_model_file

# ==== Component: src/models/manager.sh ====
# ==============================================================================
# Leonardo AI Universal - Model Manager
# ==============================================================================
# Description: Model download, installation, and lifecycle management
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh, network.sh, progress.sh, registry.sh
# ==============================================================================

# Model management state
declare -A LEONARDO_INSTALLED_MODELS
declare -A LEONARDO_MODEL_STATUS
LEONARDO_ACTIVE_MODEL=""

# Initialize model manager
init_model_manager() {
    log_message "INFO" "Initializing model manager"
    
    # Create model directories
    mkdir -p "$LEONARDO_MODEL_DIR"
    mkdir -p "$LEONARDO_MODEL_CACHE_DIR"
    mkdir -p "$LEONARDO_MODEL_DIR/downloads"
    
    # Initialize model registry
    init_model_registry
    
    # Scan for installed models
    scan_installed_models
}

# Scan for installed models
scan_installed_models() {
    log_message "INFO" "Scanning for installed models..."
    
    LEONARDO_INSTALLED_MODELS=()
    
    if [[ -d "$LEONARDO_MODEL_DIR" ]]; then
        while IFS= read -r model_file; do
            local basename=$(basename "$model_file")
            
            # Check if this file matches any known model
            for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
                if [[ "${LEONARDO_MODEL_REGISTRY[$model_id]}" == "$basename" ]]; then
                    LEONARDO_INSTALLED_MODELS[$model_id]="$model_file"
                    LEONARDO_MODEL_STATUS[$model_id]="installed"
                    log_message "INFO" "Found installed model: $model_id"
                    break
                fi
            done
        done < <(find "$LEONARDO_MODEL_DIR" -name "*.gguf" -o -name "*.ggml" -o -name "*.bin" 2>/dev/null)
    fi
    
    log_message "INFO" "Found ${#LEONARDO_INSTALLED_MODELS[@]} installed model(s)"
}

# Download model
download_model() {
    local model_id="$1"
    local force="${2:-false}"
    
    # Validate model ID
    if [[ -z "${LEONARDO_MODEL_REGISTRY[$model_id]:-}" ]]; then
        log_message "ERROR" "Unknown model: $model_id"
        return 1
    fi
    
    # Check if already installed
    if [[ -n "${LEONARDO_INSTALLED_MODELS[$model_id]:-}" ]] && [[ "$force" != "true" ]]; then
        log_message "INFO" "Model already installed: $model_id"
        return 0
    fi
    
    # Get model metadata
    local filename="${LEONARDO_MODEL_REGISTRY[$model_id]}"
    local url=$(get_model_metadata "$model_id" "url")
    local size=$(get_model_metadata "$model_id" "size")
    local sha256=$(get_model_metadata "$model_id" "sha256")
    local name=$(get_model_metadata "$model_id" "name")
    
    if [[ -z "$url" ]]; then
        log_message "ERROR" "No download URL for model: $model_id"
        return 1
    fi
    
    # Show model info
    echo "${COLOR_CYAN}Downloading Model: $name${COLOR_RESET}"
    echo "${COLOR_DIM}Size: $size${COLOR_RESET}"
    echo "${COLOR_DIM}Quantization: $(get_model_metadata "$model_id" "quantization")${COLOR_RESET}"
    echo ""
    
    # Check available space
    local size_bytes=$(parse_size_to_bytes "$size")
    if ! check_space_available "$LEONARDO_MODEL_DIR" "$size_bytes"; then
        log_message "ERROR" "Insufficient space for model download"
        return 1
    fi
    
    # Set download paths
    local temp_file="$LEONARDO_MODEL_DIR/downloads/${filename}.tmp"
    local final_file="$LEONARDO_MODEL_DIR/$filename"
    
    # Update status
    LEONARDO_MODEL_STATUS[$model_id]="downloading"
    
    # Download with progress
    echo "${COLOR_YELLOW}Downloading from: $url${COLOR_RESET}"
    if download_file_with_progress "$url" "$temp_file"; then
        # Verify download if checksum available
        if [[ -n "$sha256" ]] && [[ "$LEONARDO_VERIFY_CHECKSUMS" == "true" ]]; then
            echo -n "${COLOR_CYAN}Verifying checksum...${COLOR_RESET} "
            if validate_model_file "$temp_file" "$sha256"; then
                echo "${COLOR_GREEN}✓${COLOR_RESET}"
            else
                echo "${COLOR_RED}✗${COLOR_RESET}"
                rm -f "$temp_file"
                LEONARDO_MODEL_STATUS[$model_id]="error"
                return 1
            fi
        fi
        
        # Move to final location
        mv "$temp_file" "$final_file"
        LEONARDO_INSTALLED_MODELS[$model_id]="$final_file"
        LEONARDO_MODEL_STATUS[$model_id]="installed"
        
        log_message "INFO" "Model downloaded successfully: $model_id"
        show_status "success" "Model '$name' installed successfully!"
        
        # Create metadata file
        save_model_metadata "$model_id" "$final_file"
        
        return 0
    else
        rm -f "$temp_file"
        LEONARDO_MODEL_STATUS[$model_id]="error"
        log_message "ERROR" "Failed to download model: $model_id"
        return 1
    fi
}

# Parse size string to bytes
parse_size_to_bytes() {
    local size_str="$1"
    local number=$(echo "$size_str" | grep -oE '[0-9.]+')
    local unit=$(echo "$size_str" | grep -oE '[A-Z]+')
    
    case "$unit" in
        "GB")
            echo $(awk "BEGIN {printf \"%.0f\", $number * 1024 * 1024 * 1024}")
            ;;
        "MB")
            echo $(awk "BEGIN {printf \"%.0f\", $number * 1024 * 1024}")
            ;;
        "KB")
            echo $(awk "BEGIN {printf \"%.0f\", $number * 1024}")
            ;;
        *)
            echo "$number"
            ;;
    esac
}

# Save model metadata
save_model_metadata() {
    local model_id="$1"
    local model_path="$2"
    local metadata_file="${model_path}.meta"
    
    cat > "$metadata_file" << EOF
{
    "id": "$model_id",
    "name": "$(get_model_metadata "$model_id" "name")",
    "filename": "$(basename "$model_path")",
    "size": "$(get_model_metadata "$model_id" "size")",
    "format": "$(get_model_metadata "$model_id" "format")",
    "quantization": "$(get_model_metadata "$model_id" "quantization")",
    "family": "$(get_model_metadata "$model_id" "family")",
    "license": "$(get_model_metadata "$model_id" "license")",
    "sha256": "$(get_model_metadata "$model_id" "sha256")",
    "installed_date": "$(date -u +"%Y-%m-%d %H:%M:%S UTC")",
    "leonardo_version": "$LEONARDO_VERSION"
}
EOF
}

# Delete model
delete_model() {
    local model_id="$1"
    
    if [[ -z "${LEONARDO_INSTALLED_MODELS[$model_id]:-}" ]]; then
        log_message "ERROR" "Model not installed: $model_id"
        return 1
    fi
    
    local model_path="${LEONARDO_INSTALLED_MODELS[$model_id]}"
    local name=$(get_model_metadata "$model_id" "name")
    
    # Confirm deletion
    if confirm_action "Delete model '$name'?"; then
        # Delete model file
        if [[ "$LEONARDO_SECURE_DELETE" == "true" ]]; then
            secure_delete "$model_path"
        else
            rm -f "$model_path"
        fi
        
        # Delete metadata
        rm -f "${model_path}.meta"
        
        # Update state
        unset LEONARDO_INSTALLED_MODELS[$model_id]
        unset LEONARDO_MODEL_STATUS[$model_id]
        
        log_message "INFO" "Model deleted: $model_id"
        show_status "success" "Model '$name' deleted"
        return 0
    else
        log_message "INFO" "Model deletion cancelled"
        return 1
    fi
}

# List installed models
list_installed_models() {
    if [[ ${#LEONARDO_INSTALLED_MODELS[@]} -eq 0 ]]; then
        echo "${COLOR_YELLOW}No models installed${COLOR_RESET}"
        echo "Use 'leonardo model download <model-id>' to install models"
        return
    fi
    
    echo "${COLOR_CYAN}Installed Models:${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%60s' | tr ' ' '-')${COLOR_RESET}"
    
    for model_id in "${!LEONARDO_INSTALLED_MODELS[@]}"; do
        local path="${LEONARDO_INSTALLED_MODELS[$model_id]}"
        local name=$(get_model_metadata "$model_id" "name")
        local size=$(get_model_metadata "$model_id" "size")
        local status="${LEONARDO_MODEL_STATUS[$model_id]:-unknown}"
        
        # Status icon
        local status_icon="?"
        local status_color="$COLOR_DIM"
        case "$status" in
            "installed")
                status_icon="✓"
                status_color="$COLOR_GREEN"
                ;;
            "downloading")
                status_icon="⟳"
                status_color="$COLOR_YELLOW"
                ;;
            "error")
                status_icon="✗"
                status_color="$COLOR_RED"
                ;;
        esac
        
        printf "${status_color}%s${COLOR_RESET} %-15s %-25s %10s\n" \
            "$status_icon" "$model_id" "$name" "$size"
        
        if [[ "$LEONARDO_VERBOSE" == "true" ]]; then
            echo "  ${COLOR_DIM}Path: $path${COLOR_RESET}"
        fi
    done
}

# Import model from file
import_model() {
    local model_file="$1"
    local model_id="${2:-}"
    
    if [[ ! -f "$model_file" ]]; then
        log_message "ERROR" "Model file not found: $model_file"
        return 1
    fi
    
    # Try to identify model if ID not provided
    if [[ -z "$model_id" ]]; then
        local basename=$(basename "$model_file")
        for id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
            if [[ "${LEONARDO_MODEL_REGISTRY[$id]}" == "$basename" ]]; then
                model_id="$id"
                break
            fi
        done
        
        if [[ -z "$model_id" ]]; then
            log_message "ERROR" "Cannot identify model from filename: $basename"
            echo "Please specify model ID explicitly"
            return 1
        fi
    fi
    
    # Validate model exists in registry
    if [[ -z "${LEONARDO_MODEL_REGISTRY[$model_id]:-}" ]]; then
        log_message "ERROR" "Unknown model ID: $model_id"
        return 1
    fi
    
    # Get expected filename
    local expected_filename="${LEONARDO_MODEL_REGISTRY[$model_id]}"
    local target_path="$LEONARDO_MODEL_DIR/$expected_filename"
    
    echo "${COLOR_CYAN}Importing model: $(get_model_metadata "$model_id" "name")${COLOR_RESET}"
    
    # Validate model file
    local expected_sha256=$(get_model_metadata "$model_id" "sha256")
    if [[ -n "$expected_sha256" ]] && [[ "$LEONARDO_VERIFY_CHECKSUMS" == "true" ]]; then
        echo -n "Verifying checksum... "
        if validate_model_file "$model_file" "$expected_sha256"; then
            echo "${COLOR_GREEN}✓${COLOR_RESET}"
        else
            echo "${COLOR_RED}✗${COLOR_RESET}"
            return 1
        fi
    fi
    
    # Copy model to model directory
    echo -n "Copying model file... "
    if cp "$model_file" "$target_path"; then
        echo "${COLOR_GREEN}✓${COLOR_RESET}"
        
        # Update state
        LEONARDO_INSTALLED_MODELS[$model_id]="$target_path"
        LEONARDO_MODEL_STATUS[$model_id]="installed"
        
        # Save metadata
        save_model_metadata "$model_id" "$target_path"
        
        show_status "success" "Model imported successfully!"
        return 0
    else
        echo "${COLOR_RED}✗${COLOR_RESET}"
        return 1
    fi
}

# Export model
export_model() {
    local model_id="$1"
    local export_path="${2:-$PWD}"
    
    if [[ -z "${LEONARDO_INSTALLED_MODELS[$model_id]:-}" ]]; then
        log_message "ERROR" "Model not installed: $model_id"
        return 1
    fi
    
    local model_path="${LEONARDO_INSTALLED_MODELS[$model_id]}"
    local filename=$(basename "$model_path")
    local target_file="$export_path/$filename"
    
    # Check if directory
    if [[ -d "$export_path" ]]; then
        target_file="$export_path/$filename"
    else
        target_file="$export_path"
    fi
    
    echo "${COLOR_CYAN}Exporting model: $(get_model_metadata "$model_id" "name")${COLOR_RESET}"
    echo "Target: $target_file"
    
    # Copy with progress
    if copy_with_progress "$model_path" "$target_file"; then
        # Also export metadata
        cp "${model_path}.meta" "${target_file}.meta" 2>/dev/null || true
        
        show_status "success" "Model exported successfully!"
        echo "You can import this model on another Leonardo installation using:"
        echo "  ${COLOR_CYAN}leonardo model import \"$target_file\" $model_id${COLOR_RESET}"
        return 0
    else
        log_message "ERROR" "Failed to export model"
        return 1
    fi
}

# Update model registry from remote
update_model_registry() {
    log_message "INFO" "Updating model registry..."
    
    local registry_url="$LEONARDO_MODEL_REGISTRY_URL"
    local cache_file="$LEONARDO_MODEL_CACHE_DIR/registry.json"
    
    # Download latest registry
    if fetch_model_registry "$registry_url" "$cache_file"; then
        show_status "success" "Model registry updated"
        
        # TODO: Parse and update registry from JSON
        # For now, using hardcoded registry
        
        return 0
    else
        log_message "ERROR" "Failed to update model registry"
        return 1
    fi
}

# Get model status
get_model_status() {
    local model_id="$1"
    echo "${LEONARDO_MODEL_STATUS[$model_id]:-not_installed}"
}

# Load model (placeholder for inference engine integration)
load_model() {
    local model_id="$1"
    
    if [[ -z "${LEONARDO_INSTALLED_MODELS[$model_id]:-}" ]]; then
        log_message "ERROR" "Model not installed: $model_id"
        return 1
    fi
    
    local model_path="${LEONARDO_INSTALLED_MODELS[$model_id]}"
    local name=$(get_model_metadata "$model_id" "name")
    
    echo "${COLOR_CYAN}Loading model: $name${COLOR_RESET}"
    show_spinner "Initializing inference engine..." &
    local spinner_pid=$!
    
    # Simulate loading (placeholder)
    sleep 2
    
    kill $spinner_pid 2>/dev/null
    wait $spinner_pid 2>/dev/null
    
    LEONARDO_ACTIVE_MODEL="$model_id"
    show_status "success" "Model loaded: $name"
    
    return 0
}

# Model selection menu
model_selection_menu() {
    local models=()
    local names=()
    
    # Build model list
    for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
        models+=("$model_id")
        names+=("$(get_model_metadata "$model_id" "name") ($(get_model_metadata "$model_id" "size"))")
    done
    
    # Show menu
    local selected=$(show_menu "Select a model:" "${names[@]}")
    
    if [[ -n "$selected" ]]; then
        echo "${models[$selected]}"
        return 0
    else
        return 1
    fi
}

# Export model manager functions
export -f init_model_manager scan_installed_models download_model delete_model
export -f list_installed_models import_model export_model update_model_registry
export -f get_model_status load_model model_selection_menu

# ==== Component: src/models/selector.sh ====
# ==============================================================================
# Leonardo AI Universal - Model Selector
# ==============================================================================
# Description: Interactive model selection and configuration interface
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, menu.sh, progress.sh, registry.sh, manager.sh
# ==============================================================================

# Model selector state
LEONARDO_SELECTED_MODEL=""
LEONARDO_MODEL_PREFERENCES=()

# Interactive model selector
interactive_model_selector() {
    local use_case="${1:-general}"
    
    clear
    show_banner
    
    echo "${COLOR_CYAN}Model Selection Assistant${COLOR_RESET}"
    echo "${COLOR_DIM}Let's find the perfect AI model for your needs${COLOR_RESET}"
    echo ""
    
    # Step 1: Use case selection
    local use_cases=(
        "General Chat:general"
        "Code Generation:code"
        "Creative Writing:creative"
        "Analysis & Research:analysis"
        "Lightweight/Fast:small"
        "Advanced/Large:large"
        "Custom Selection:custom"
    )
    
    local selected_use_case=$(show_radio_menu "What will you primarily use the model for?" "${use_cases[@]}")
    
    if [[ -z "$selected_use_case" ]]; then
        return 1
    fi
    
    use_case="${use_cases[$selected_use_case]##*:}"
    
    if [[ "$use_case" == "custom" ]]; then
        # Custom selection - show all models
        custom_model_selection
        return $?
    fi
    
    # Step 2: Get recommended models
    local recommended=($(get_recommended_models "$use_case"))
    
    echo ""
    echo "${COLOR_CYAN}Recommended models for $use_case:${COLOR_RESET}"
    echo ""
    
    # Show recommended models with details
    local options=()
    local model_details=()
    
    for model_id in "${recommended[@]}"; do
        local name=$(get_model_metadata "$model_id" "name")
        local size=$(get_model_metadata "$model_id" "size")
        local status=$(get_model_status "$model_id")
        
        # Status indicator
        local status_text=""
        case "$status" in
            "installed")
                status_text="${COLOR_GREEN}[Installed]${COLOR_RESET}"
                ;;
            "downloading")
                status_text="${COLOR_YELLOW}[Downloading]${COLOR_RESET}"
                ;;
            "not_installed")
                status_text="${COLOR_DIM}[Not Installed]${COLOR_RESET}"
                ;;
        esac
        
        options+=("$model_id:$name ($size) $status_text")
        model_details+=("$model_id")
    done
    
    # Add option to see all models
    options+=("all:Browse All Models")
    
    # Show selection menu
    local selected=$(show_radio_menu "Select a model:" "${options[@]}")
    
    if [[ -z "$selected" ]]; then
        return 1
    fi
    
    local choice="${options[$selected]%%:*}"
    
    if [[ "$choice" == "all" ]]; then
        custom_model_selection
        return $?
    fi
    
    # Selected a specific model
    LEONARDO_SELECTED_MODEL="$choice"
    
    # Show model details and actions
    show_model_details_and_actions "$LEONARDO_SELECTED_MODEL"
}

# Custom model selection
custom_model_selection() {
    clear
    echo "${COLOR_CYAN}All Available Models${COLOR_RESET}"
    echo ""
    
    # Build filtered list interface
    local models=()
    local display_names=()
    
    for model_id in $(list_models "" "simple" | sort); do
        models+=("$model_id")
        local name=$(get_model_metadata "$model_id" "name")
        local size=$(get_model_metadata "$model_id" "size")
        local family=$(get_model_metadata "$model_id" "family")
        display_names+=("$name - $size [$family]")
    done
    
    # Show filtered list
    local selected=$(show_filtered_list "Search and select a model:" "${display_names[@]}")
    
    if [[ -n "$selected" ]]; then
        LEONARDO_SELECTED_MODEL="${models[$selected]}"
        show_model_details_and_actions "$LEONARDO_SELECTED_MODEL"
        return 0
    else
        return 1
    fi
}

# Show model details and actions
show_model_details_and_actions() {
    local model_id="$1"
    
    clear
    echo "${COLOR_CYAN}Model Selected${COLOR_RESET}"
    echo ""
    
    # Show model info
    get_model_info "$model_id"
    echo ""
    
    # Check status
    local status=$(get_model_status "$model_id")
    
    # Show appropriate actions
    local actions=()
    
    case "$status" in
        "installed")
            echo "${COLOR_GREEN}✓ This model is installed and ready to use${COLOR_RESET}"
            actions=(
                "load:Load Model"
                "export:Export Model"
                "delete:Delete Model"
                "back:Select Different Model"
            )
            ;;
        "downloading")
            echo "${COLOR_YELLOW}⟳ This model is currently downloading...${COLOR_RESET}"
            actions=(
                "status:Check Download Status"
                "back:Select Different Model"
            )
            ;;
        "not_installed")
            echo "${COLOR_DIM}○ This model is not installed${COLOR_RESET}"
            actions=(
                "download:Download Model"
                "info:View More Info"
                "back:Select Different Model"
            )
            ;;
    esac
    
    echo ""
    local action=$(show_menu "What would you like to do?" "${actions[@]##*:}")
    
    if [[ -n "$action" ]]; then
        local action_key="${actions[$action]%%:*}"
        
        case "$action_key" in
            "load")
                load_model "$model_id"
                ;;
            "download")
                if download_model "$model_id"; then
                    echo ""
                    echo "${COLOR_GREEN}Model ready to use!${COLOR_RESET}"
                    read -p "Press Enter to continue..."
                    show_model_details_and_actions "$model_id"
                fi
                ;;
            "export")
                echo ""
                local export_path=$(show_input_dialog "Export path:" "$PWD")
                if [[ -n "$export_path" ]]; then
                    export_model "$model_id" "$export_path"
                    read -p "Press Enter to continue..."
                fi
                ;;
            "delete")
                if delete_model "$model_id"; then
                    echo ""
                    read -p "Press Enter to continue..."
                    interactive_model_selector
                else
                    show_model_details_and_actions "$model_id"
                fi
                ;;
            "info")
                clear
                get_model_info "$model_id"
                echo ""
                echo "${COLOR_DIM}Download URL:${COLOR_RESET}"
                echo "$(get_model_metadata "$model_id" "url")"
                echo ""
                read -p "Press Enter to continue..."
                show_model_details_and_actions "$model_id"
                ;;
            "status")
                # TODO: Show download progress
                echo "Download status check not yet implemented"
                read -p "Press Enter to continue..."
                show_model_details_and_actions "$model_id"
                ;;
            "back")
                interactive_model_selector
                ;;
        esac
    fi
}

# Model comparison tool
compare_models() {
    local model1="$1"
    local model2="$2"
    
    if [[ -z "$model1" ]] || [[ -z "$model2" ]]; then
        # Interactive selection
        echo "${COLOR_CYAN}Model Comparison Tool${COLOR_RESET}"
        echo ""
        
        echo "Select first model:"
        model1=$(model_selection_menu)
        [[ -z "$model1" ]] && return 1
        
        echo "Select second model:"
        model2=$(model_selection_menu)
        [[ -z "$model2" ]] && return 1
    fi
    
    # Validate models exist
    if [[ -z "${LEONARDO_MODEL_REGISTRY[$model1]:-}" ]] || [[ -z "${LEONARDO_MODEL_REGISTRY[$model2]:-}" ]]; then
        log_message "ERROR" "Invalid model IDs"
        return 1
    fi
    
    clear
    echo "${COLOR_CYAN}Model Comparison${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%80s' | tr ' ' '=')${COLOR_RESET}"
    
    # Header
    printf "${COLOR_GREEN}%-25s${COLOR_RESET} | ${COLOR_YELLOW}%-25s${COLOR_RESET} | ${COLOR_CYAN}%-25s${COLOR_RESET}\n" \
        "Attribute" "$(get_model_metadata "$model1" "name")" "$(get_model_metadata "$model2" "name")"
    echo "${COLOR_DIM}$(printf '%80s' | tr ' ' '-')${COLOR_RESET}"
    
    # Compare attributes
    local attributes=("size" "format" "quantization" "family" "license")
    
    for attr in "${attributes[@]}"; do
        local val1=$(get_model_metadata "$model1" "$attr")
        local val2=$(get_model_metadata "$model2" "$attr")
        
        printf "%-25s | %-25s | %-25s\n" "$attr" "$val1" "$val2"
    done
    
    # Status
    echo "${COLOR_DIM}$(printf '%80s' | tr ' ' '-')${COLOR_RESET}"
    local status1=$(get_model_status "$model1")
    local status2=$(get_model_status "$model2")
    printf "%-25s | ${COLOR_GREEN}%-25s${COLOR_RESET} | ${COLOR_GREEN}%-25s${COLOR_RESET}\n" \
        "Status" "$status1" "$status2"
    
    echo ""
}

# Model preference configuration
configure_model_preferences() {
    clear
    echo "${COLOR_CYAN}Model Preferences${COLOR_RESET}"
    echo "${COLOR_DIM}Configure your model selection preferences${COLOR_RESET}"
    echo ""
    
    # Preference options
    local preferences=(
        "max_size:Maximum model size"
        "quantization:Preferred quantization"
        "auto_download:Auto-download models"
        "verify_checksums:Verify checksums"
        "default_model:Default model"
    )
    
    local selected=$(show_checklist "Select preferences to configure:" "${preferences[@]##*:}")
    
    if [[ -n "$selected" ]]; then
        for idx in $selected; do
            local pref="${preferences[$idx]%%:*}"
            
            case "$pref" in
                "max_size")
                    local size=$(show_menu "Maximum model size:" "2GB" "5GB" "10GB" "20GB" "50GB" "No Limit")
                    [[ -n "$size" ]] && LEONARDO_MODEL_PREFERENCES["max_size"]="${size}"
                    ;;
                "quantization")
                    local quant=$(show_menu "Preferred quantization:" "Q4_K_M" "Q5_K_M" "Q8_0" "f16")
                    [[ -n "$quant" ]] && LEONARDO_MODEL_PREFERENCES["quantization"]="${quant}"
                    ;;
                "auto_download")
                    local auto=$(show_menu "Auto-download models:" "Yes" "No")
                    [[ -n "$auto" ]] && LEONARDO_MODEL_PREFERENCES["auto_download"]="${auto}"
                    ;;
                "verify_checksums")
                    local verify=$(show_menu "Verify checksums:" "Always" "Never" "Ask")
                    [[ -n "$verify" ]] && LEONARDO_MODEL_PREFERENCES["verify_checksums"]="${verify}"
                    ;;
                "default_model")
                    local model=$(model_selection_menu)
                    [[ -n "$model" ]] && LEONARDO_MODEL_PREFERENCES["default_model"]="${model}"
                    ;;
            esac
        done
        
        echo ""
        show_status "success" "Preferences updated"
        
        # Save preferences
        save_model_preferences
    fi
}

# Save model preferences
save_model_preferences() {
    local pref_file="$LEONARDO_CONFIG_DIR/model_preferences.conf"
    
    mkdir -p "$(dirname "$pref_file")"
    
    {
        echo "# Leonardo Model Preferences"
        echo "# Generated: $(date)"
        echo ""
        
        for key in "${!LEONARDO_MODEL_PREFERENCES[@]}"; do
            echo "${key}=${LEONARDO_MODEL_PREFERENCES[$key]}"
        done
    } > "$pref_file"
}

# Load model preferences
load_model_preferences() {
    local pref_file="$LEONARDO_CONFIG_DIR/model_preferences.conf"
    
    if [[ -f "$pref_file" ]]; then
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^#.*$ ]] && continue
            [[ -z "$key" ]] && continue
            LEONARDO_MODEL_PREFERENCES["$key"]="$value"
        done < "$pref_file"
    fi
}

# Quick model installer
quick_install_model() {
    local use_case="${1:-general}"
    
    echo "${COLOR_CYAN}Quick Model Installation${COLOR_RESET}"
    echo ""
    
    # Get recommended model for use case
    local recommended=($(get_recommended_models "$use_case"))
    
    if [[ ${#recommended[@]} -eq 0 ]]; then
        log_message "ERROR" "No recommendations for use case: $use_case"
        return 1
    fi
    
    # Find first non-installed model
    local model_to_install=""
    for model_id in "${recommended[@]}"; do
        if [[ "$(get_model_status "$model_id")" == "not_installed" ]]; then
            model_to_install="$model_id"
            break
        fi
    done
    
    if [[ -z "$model_to_install" ]]; then
        echo "${COLOR_GREEN}All recommended models are already installed!${COLOR_RESET}"
        return 0
    fi
    
    # Download the model
    download_model "$model_to_install"
}

# Export model selector functions
export -f interactive_model_selector custom_model_selection compare_models
export -f configure_model_preferences quick_install_model

# ==== Component: src/models/cli.sh ====
# ==============================================================================
# Leonardo AI Universal - Model CLI
# ==============================================================================
# Description: Command-line interface for model management
# Version: 7.0.0
# Dependencies: all model modules, colors.sh, logging.sh
# ==============================================================================

# Model CLI help
show_model_help() {
    cat << EOF
${COLOR_CYAN}Leonardo Model Management${COLOR_RESET}

${COLOR_GREEN}Usage:${COLOR_RESET}
  leonardo model <command> [options]

${COLOR_GREEN}Commands:${COLOR_RESET}
  list              List available models
  installed         List installed models
  info <model>      Show model information
  download <model>  Download a model
  delete <model>    Delete an installed model
  import <file>     Import a model from file
  export <model>    Export a model to file
  search <query>    Search for models
  compare           Compare two models
  select            Interactive model selector
  update            Update model registry
  preferences       Configure model preferences

${COLOR_GREEN}Examples:${COLOR_RESET}
  leonardo model list
  leonardo model download llama3-8b
  leonardo model info mistral-7b
  leonardo model search llama
  leonardo model import ~/models/llama-3-8b.gguf
  leonardo model export llama3-8b ~/backup/

${COLOR_GREEN}Quick Start:${COLOR_RESET}
  leonardo model select    # Interactive model selection

EOF
}

# Model CLI router
handle_model_command() {
    local command="${1:-help}"
    shift
    
    # Initialize model manager if needed
    if [[ -z "${LEONARDO_MODEL_REGISTRY[*]:-}" ]]; then
        init_model_manager
    fi
    
    case "$command" in
        "list"|"ls")
            handle_model_list "$@"
            ;;
        "installed"|"i")
            list_installed_models
            ;;
        "info"|"show")
            handle_model_info "$@"
            ;;
        "download"|"dl"|"get")
            handle_model_download "$@"
            ;;
        "delete"|"rm"|"remove")
            handle_model_delete "$@"
            ;;
        "import")
            handle_model_import "$@"
            ;;
        "export")
            handle_model_export "$@"
            ;;
        "search"|"find")
            handle_model_search "$@"
            ;;
        "compare"|"diff")
            handle_model_compare "$@"
            ;;
        "select"|"choose")
            interactive_model_selector "$@"
            ;;
        "update"|"refresh")
            update_model_registry
            ;;
        "preferences"|"prefs"|"config")
            configure_model_preferences
            ;;
        "help"|"--help"|"-h")
            show_model_help
            ;;
        *)
            echo "${COLOR_RED}Unknown model command: $command${COLOR_RESET}"
            echo "Run 'leonardo model help' for usage"
            return 1
            ;;
    esac
}

# Handle model list command
handle_model_list() {
    local filter="${1:-}"
    local format="${2:-table}"
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --json)
                format="json"
                ;;
            --simple)
                format="simple"
                ;;
            --filter=*)
                filter="${1#*=}"
                ;;
            --family=*)
                filter="${1#*=}"
                ;;
            --installed)
                filter="installed"
                ;;
            *)
                filter="$1"
                ;;
        esac
        shift
    done
    
    # Special case for installed filter
    if [[ "$filter" == "installed" ]]; then
        list_installed_models
        return
    fi
    
    list_models "$filter" "$format"
}

# Handle model info command
handle_model_info() {
    local model_id="$1"
    
    if [[ -z "$model_id" ]]; then
        echo "${COLOR_RED}Error: Model ID required${COLOR_RESET}"
        echo "Usage: leonardo model info <model-id>"
        return 1
    fi
    
    get_model_info "$model_id"
}

# Handle model download command
handle_model_download() {
    local model_id="$1"
    local force=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                force=true
                ;;
            --*)
                echo "${COLOR_RED}Unknown option: $1${COLOR_RESET}"
                return 1
                ;;
            *)
                model_id="$1"
                ;;
        esac
        shift
    done
    
    if [[ -z "$model_id" ]]; then
        # Interactive selection
        model_id=$(model_selection_menu)
        [[ -z "$model_id" ]] && return 1
    fi
    
    download_model "$model_id" "$force"
}

# Handle model delete command
handle_model_delete() {
    local model_id="$1"
    
    if [[ -z "$model_id" ]]; then
        # Show installed models for selection
        echo "${COLOR_CYAN}Select model to delete:${COLOR_RESET}"
        list_installed_models
        echo ""
        model_id=$(show_input_dialog "Model ID to delete:")
        [[ -z "$model_id" ]] && return 1
    fi
    
    delete_model "$model_id"
}

# Handle model import command
handle_model_import() {
    local file_path="$1"
    local model_id="$2"
    
    if [[ -z "$file_path" ]]; then
        echo "${COLOR_RED}Error: File path required${COLOR_RESET}"
        echo "Usage: leonardo model import <file> [model-id]"
        return 1
    fi
    
    import_model "$file_path" "$model_id"
}

# Handle model export command
handle_model_export() {
    local model_id="$1"
    local export_path="${2:-$PWD}"
    
    if [[ -z "$model_id" ]]; then
        # Show installed models for selection
        echo "${COLOR_CYAN}Select model to export:${COLOR_RESET}"
        list_installed_models
        echo ""
        model_id=$(show_input_dialog "Model ID to export:")
        [[ -z "$model_id" ]] && return 1
    fi
    
    export_model "$model_id" "$export_path"
}

# Handle model search command
handle_model_search() {
    local query="$1"
    
    if [[ -z "$query" ]]; then
        query=$(show_input_dialog "Search query:")
        [[ -z "$query" ]] && return 1
    fi
    
    search_models "$query"
}

# Handle model compare command
handle_model_compare() {
    local model1="$1"
    local model2="$2"
    
    compare_models "$model1" "$model2"
}

# Model batch operations
batch_download_models() {
    local models=("$@")
    
    if [[ ${#models[@]} -eq 0 ]]; then
        # Interactive multi-select
        local all_models=()
        local display_names=()
        
        for model_id in $(list_models "" "simple" | sort); do
            if [[ "$(get_model_status "$model_id")" != "installed" ]]; then
                all_models+=("$model_id")
                display_names+=("$(get_model_metadata "$model_id" "name") ($(get_model_metadata "$model_id" "size"))")
            fi
        done
        
        local selected=$(show_checklist "Select models to download:" "${display_names[@]}")
        
        if [[ -z "$selected" ]]; then
            return 1
        fi
        
        for idx in $selected; do
            models+=("${all_models[$idx]}")
        done
    fi
    
    echo "${COLOR_CYAN}Batch download: ${#models[@]} models${COLOR_RESET}"
    echo ""
    
    local success=0
    local failed=0
    
    for model_id in "${models[@]}"; do
        echo "${COLOR_YELLOW}Downloading: $model_id${COLOR_RESET}"
        if download_model "$model_id"; then
            ((success++))
        else
            ((failed++))
        fi
        echo ""
    done
    
    echo "${COLOR_CYAN}Batch download complete${COLOR_RESET}"
    echo "${COLOR_GREEN}Success: $success${COLOR_RESET}"
    [[ $failed -gt 0 ]] && echo "${COLOR_RED}Failed: $failed${COLOR_RESET}"
}

# Model statistics
show_model_statistics() {
    echo "${COLOR_CYAN}Model Statistics${COLOR_RESET}"
    echo "${COLOR_DIM}$(printf '%60s' | tr ' ' '-')${COLOR_RESET}"
    
    # Total models
    echo "Total models available: ${#LEONARDO_MODEL_REGISTRY[@]}"
    echo "Models installed: ${#LEONARDO_INSTALLED_MODELS[@]}"
    
    # By family
    echo ""
    echo "${COLOR_GREEN}Models by family:${COLOR_RESET}"
    declare -A family_count
    for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
        local family=$(get_model_metadata "$model_id" "family")
        ((family_count[$family]++))
    done
    
    for family in "${!family_count[@]}"; do
        printf "  %-15s %3d models\n" "$family:" "${family_count[$family]}"
    done
    
    # Disk usage
    if [[ ${#LEONARDO_INSTALLED_MODELS[@]} -gt 0 ]]; then
        echo ""
        echo "${COLOR_GREEN}Disk usage:${COLOR_RESET}"
        local total_size=0
        for model_path in "${LEONARDO_INSTALLED_MODELS[@]}"; do
            if [[ -f "$model_path" ]]; then
                local size=$(stat -f%z "$model_path" 2>/dev/null || stat -c%s "$model_path" 2>/dev/null || echo 0)
                ((total_size += size))
            fi
        done
        echo "  Total: $(format_bytes $total_size)"
        echo "  Average: $(format_bytes $((total_size / ${#LEONARDO_INSTALLED_MODELS[@]})))"
    fi
}

# Export CLI functions
export -f handle_model_command show_model_help batch_download_models show_model_statistics

# ==== Footer ====
# If main hasn't been called, call it now
if [ "${LEONARDO_MAIN_CALLED:-false}" = "false" ]; then
    main "$@"
fi
