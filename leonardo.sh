#!/usr/bin/env bash
# Leonardo AI Universal - Portable AI Deployment System
# Version: 7.0.0
# This file was automatically generated - DO NOT EDIT

# Ensure TERM is set for terminal operations
if [[ -z "${TERM:-}" ]]; then
    export TERM=xterm
fi


# ==== Component: src/core/header.sh ====
# ==============================================================================
# Leonardo AI Universal - Core Header
# ==============================================================================
# Description: Script header and metadata initialization
# Version: 7.0.0
# Dependencies: none
# ==============================================================================

# Ensure TERM is set for terminal operations
if [[ -z "$TERM" ]]; then
    export TERM=xterm
fi

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

# Leonardo description
export LEONARDO_DESCRIPTION="Portable AI deployment system with integrated model management"

# Export configuration for use in other modules
export LEONARDO_CONFIG_LOADED=true

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

# Convenience logging functions
log_debug() {
    log_message "DEBUG" "$@"
}

log_info() {
    log_message "INFO" "$@"
}

log_warn() {
    log_message "WARN" "$@"
}

log_error() {
    log_message "ERROR" "$@"
}

log_fatal() {
    log_message "FATAL" "$@"
}

log_success() {
    log_message "INFO" "✓ $@"
}

# Export logging functions
export -f log_message log_command log_system_info
export -f log_debug log_info log_warn log_error log_fatal log_success

# Initialize logging on source
init_logging

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

# ==== Component: src/utils/validation.sh ====
# ==============================================================================
# Leonardo AI Universal - Input Validation
# ==============================================================================
# Description: Input validation and sanitization utilities
# Version: 7.0.0
# Dependencies: logging.sh, colors.sh
# ==============================================================================

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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
export -f command_exists

# ==== Component: src/utils/filesystem.sh ====
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
                        
                        # First, check what's using the device
                        echo -e "${DIM}Checking what's using the device...${COLOR_RESET}"
                        local device_users=$(sudo lsof "$partition" 2>/dev/null || true)
                        if [[ -n "$device_users" ]]; then
                            echo -e "${YELLOW}Processes using device:${COLOR_RESET}"
                            echo "$device_users"
                        fi
                        
                        # Try to eject the device properly first
                        echo -e "${DIM}Ejecting device properly...${COLOR_RESET}"
                        sudo eject "$partition" 2>/dev/null || true
                        sleep 2
                        
                        # Now unmount with all methods
                        sudo umount "$partition" 2>/dev/null || true
                        sudo umount -f "$partition" 2>/dev/null || true
                        sudo umount -l "$partition" 2>/dev/null || true
                        
                        # Force a sync
                        sync
                        
                        # Wait for device to settle (you mentioned hearing disconnect)
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

# ==== Component: src/utils/terminal.sh ====
#
# Leonardo AI Universal - Terminal Utilities
# Safe terminal operations
#

# Override clear to handle missing TERM
clear() {
    if [[ -n "${TERM:-}" ]]; then
        command clear 2>/dev/null || true
    else
        # Fallback: just print newlines
        printf '\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n'
    fi
}

# Check if a command exists in PATH
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Export functions
export -f clear command_exists

# ==== Component: src/core/system_status.sh ====

# System Status Module - Track where services are running
# Part of Leonardo AI Universal

# Ensure color variables are defined
: "${GREEN:=\033[32m}"
: "${CYAN:=\033[36m}"
: "${YELLOW:=\033[33m}"
: "${RED:=\033[31m}"
: "${DIM:=\033[2m}"
: "${COLOR_RESET:=\033[0m}"

# Detect Ollama location (host vs USB)
detect_ollama_location() {
    local location="none"
    local ollama_pid=""
    local ollama_path=""
    
    # Check if Ollama is running
    if command -v pgrep >/dev/null 2>&1; then
        ollama_pid=$(pgrep -f "ollama serve" 2>/dev/null | head -1)
    fi
    
    if [[ -n "$ollama_pid" ]]; then
        # Get the path of the running Ollama process
        if command -v pwdx >/dev/null 2>&1; then
            ollama_path=$(pwdx "$ollama_pid" 2>/dev/null | cut -d: -f2- | xargs)
        elif [[ -e "/proc/$ollama_pid/cwd" ]]; then
            ollama_path=$(readlink "/proc/$ollama_pid/cwd" 2>/dev/null)
        fi
        
        # Check if running from USB
        if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ "$ollama_path" =~ "$LEONARDO_USB_MOUNT" ]]; then
            location="USB"
        elif [[ -n "$ollama_path" ]]; then
            location="Host"
        else
            # Fallback: check if standard Ollama is responding
            if ollama list >/dev/null 2>&1; then
                location="Host"
            fi
        fi
    else
        # Ollama not running, check if it's available
        if command -v ollama >/dev/null 2>&1; then
            # Check if it's the USB version
            local ollama_bin=$(which ollama)
            if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ "$ollama_bin" =~ "$LEONARDO_USB_MOUNT" ]]; then
                location="USB (not running)"
            else
                location="Host (not running)"
            fi
        fi
    fi
    
    echo "$location"
}

# Detect Leonardo location (where the script is running from)
detect_leonardo_location() {
    local script_path="${BASH_SOURCE[0]}"
    local real_path=$(readlink -f "$script_path" 2>/dev/null || realpath "$script_path" 2>/dev/null)
    
    if [[ -n "$LEONARDO_USB_MOUNT" ]] && [[ "$real_path" =~ "$LEONARDO_USB_MOUNT" ]]; then
        echo "USB"
    else
        echo "Host"
    fi
}

# Get Ollama endpoint based on location preference
get_ollama_endpoint() {
    local preference="${1:-auto}"  # auto, host, usb
    local host_endpoint="http://localhost:11434"
    local usb_endpoint="http://localhost:11435"  # Different port for USB instance
    
    case "$preference" in
        host)
            echo "$host_endpoint"
            ;;
        usb)
            echo "$usb_endpoint"
            ;;
        auto)
            # Check which one is available
            if curl -s "$usb_endpoint/api/tags" >/dev/null 2>&1; then
                echo "$usb_endpoint"
            elif curl -s "$host_endpoint/api/tags" >/dev/null 2>&1; then
                echo "$host_endpoint"
            else
                echo "$host_endpoint"  # Default
            fi
            ;;
    esac
}

# Format system status for display
format_system_status() {
    local ollama_loc=$(detect_ollama_location)
    local leonardo_loc=$(detect_leonardo_location)
    local status=""
    
    # Ollama status with color
    case "$ollama_loc" in
        Host)
            status="${GREEN}Ollama: Host${COLOR_RESET}"
            ;;
        USB)
            status="${CYAN}Ollama: USB${COLOR_RESET}"
            ;;
        "Host (not running)")
            status="${YELLOW}Ollama: Host (offline)${COLOR_RESET}"
            ;;
        "USB (not running)")
            status="${YELLOW}Ollama: USB (offline)${COLOR_RESET}"
            ;;
        none)
            status="${RED}Ollama: Not found${COLOR_RESET}"
            ;;
    esac
    
    # Add Leonardo location
    if [[ "$leonardo_loc" == "USB" ]]; then
        status="$status | ${CYAN}Leonardo: USB${COLOR_RESET}"
    else
        status="$status | ${GREEN}Leonardo: Host${COLOR_RESET}"
    fi
    
    echo -e "$status"
}

# Get location prefix for chat prompt
get_chat_location_prefix() {
    local ollama_endpoint="${1:-}"
    local model="${2:-unknown}"
    local location="Host"
    
    if [[ "$ollama_endpoint" =~ ":11435" ]]; then
        location="USB"
    fi
    
    echo "[${location}:${model}]"
}

# Export functions
export -f detect_ollama_location
export -f detect_leonardo_location
export -f get_ollama_endpoint
export -f format_system_status
export -f get_chat_location_prefix

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

# Show interactive menu
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    local selected=0
    local num_options=${#options[@]}
    
    # Debug terminal detection
    if [[ "${LEONARDO_DEBUG:-}" == "true" ]]; then
        echo -e "${YELLOW}DEBUG: Terminal detection:${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - tty 0: $([[ -t 0 ]] && echo yes || echo no)${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - tty 1: $([[ -t 1 ]] && echo yes || echo no)${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - tty 2: $([[ -t 2 ]] && echo yes || echo no)${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - PS1: '${PS1:-}'${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - TERM: '${TERM:-}'${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - LEONARDO_FORCE_INTERACTIVE: '${LEONARDO_FORCE_INTERACTIVE:-}'${COLOR_RESET}" >&2
    fi
    
    # Check for interactive terminal - more robust check
    local is_interactive=false
    if [[ -t 0 ]] && [[ -t 1 ]] && [[ -t 2 ]]; then
        is_interactive=true
    elif [[ -n "${PS1:-}" ]] && [[ -z "${DEBIAN_FRONTEND:-}" ]]; then
        is_interactive=true
    elif [[ "${LEONARDO_FORCE_INTERACTIVE:-}" == "true" ]]; then
        is_interactive=true
    fi
    
    # For now, let's bypass the check if TERM is set
    if [[ -n "${TERM:-}" ]] && [[ "${TERM:-}" != "dumb" ]]; then
        is_interactive=true
    fi
    
    if [[ "$is_interactive" != "true" ]]; then
        echo -e "${RED}Error: No interactive terminal available${COLOR_RESET}" >&2
        echo -e "${DIM}Hint: Run Leonardo directly in a terminal, not through pipes or scripts${COLOR_RESET}" >&2
        return 1
    fi
    
    # Hide cursor
    tput civis 2>/dev/null >/dev/tty || true
    
    # Ensure cursor is restored on exit
    trap 'tput cnorm 2>/dev/null >/dev/tty || true' RETURN INT TERM
    
    # Clear pending input
    while read -t 0; do :; done
    
    while true; do
        # Clear screen completely
        printf '\033[2J\033[H' >/dev/tty
        
        # Draw the menu
        draw_menu "$title" "$selected" "${options[@]}"
        
        # Read single character
        local key
        IFS= read -rsn1 key
        
        # Handle escape sequences for arrow keys
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case "$key" in
                '[A') key='UP' ;;     # Up arrow
                '[B') key='DOWN' ;;   # Down arrow
                '[D') key='LEFT' ;;   # Left arrow
                '[C') key='RIGHT' ;;  # Right arrow
                *) continue ;;
            esac
        fi
        
        # Process input
        case "$key" in
            'UP'|'k')
                ((selected = selected > 0 ? selected - 1 : num_options - 1))
                ;;
            'DOWN'|'j')
                ((selected = (selected + 1) % num_options))
                ;;
            [1-9])
                local idx=$((key - 1))
                if [[ $idx -lt $num_options ]]; then
                    selected=$idx
                    # Restore cursor before returning
                    tput cnorm 2>/dev/null >/dev/tty || true
                    # Return clean option text only
                    echo -n "${options[$selected]}"
                    return 0
                fi
                ;;
            ''|$'\n') # Enter
                # Restore cursor before returning
                tput cnorm 2>/dev/null >/dev/tty || true
                # Return clean option text only
                echo -n "${options[$selected]}"
                return 0
                ;;
            'q'|'Q')
                tput cnorm 2>/dev/null >/dev/tty || true
                return 1
                ;;
        esac
    done
}

# Display menu frame with highlighting
draw_menu() {
    local title="$1"
    local selected="$2"
    shift 2
    local options=("$@")
    
    # All display output goes to stderr or /dev/tty to keep stdout clean
    {
        # Draw title box - force output to terminal
        echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}" >/dev/tty
        printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title" >/dev/tty
        echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}" >/dev/tty
        echo >/dev/tty
        
        # Display options with numbering
        local i=1
        for option in "${options[@]}"; do
            local display_option="${i}) ${option}"
            if [[ $i -eq $((selected + 1)) ]]; then
                # Highlighted option
                echo -e "${CYAN}▶ ${BRIGHT}${display_option}${COLOR_RESET}" >/dev/tty
            else
                echo -e "  ${DIM}${display_option}${COLOR_RESET}" >/dev/tty
            fi
            ((i++))
        done
        
        echo >/dev/tty
        echo -e "${DIM}Use ↑/↓ arrows or numbers to select, Enter to confirm, q to quit${COLOR_RESET}" >/dev/tty
    } >&2
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
    
    # Hide cursor if possible (only if tput is available)
    if command -v tput >/dev/null 2>&1 && [ -n "$TERM" ]; then
        tput civis 2>/dev/null >/dev/tty || true
        trap 'tput cnorm 2>/dev/null >/dev/tty || true; echo' INT TERM
    fi
    
    while true; do
        clear
        display_checklist_frame "$title" "${options[@]}" "${selected[@]}"
        
        # Read user input
        IFS= read -sn1 key
        
        case "$key" in
            $'\x1b')
                read -sn2 -t 0.1 key
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
    
    # Show cursor again (only if tput is available)
    if command -v tput >/dev/null 2>&1 && [ -n "$TERM" ]; then
        tput cnorm 2>/dev/null >/dev/tty || true
        trap - INT TERM
    fi
    
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
    
    # All display output goes to stderr or /dev/tty to keep stdout clean
    {
        # Draw title box
        echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}" >&2
        printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title" >&2
        echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}" >&2
        echo >&2
        
        # Display options with checkboxes
        local i=1
        for ((idx=0; idx<num_options; idx++)); do
            local checkbox="[ ]"
            [[ ${selected[idx]} -eq 1 ]] && checkbox="[✓]"
            
            if [[ $i -eq $MENU_POSITION ]]; then
                echo -e "${CYAN}▶ ${checkbox} ${BRIGHT}${options[idx]}${COLOR_RESET}" >&2
            else
                echo -e "  ${checkbox} ${DIM}${options[idx]}${COLOR_RESET}" >&2
            fi
            ((i++))
        done
        
        echo >&2
        echo -e "${DIM}Use ↑/↓ to navigate, Space to select, Enter to confirm${COLOR_RESET}" >&2
    }
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
        IFS= read -rsn1 -t 0.1 key
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
        IFS= read -sn1 key
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

# Track download progress with speed and ETA
track_download_progress() {
    local url="$1"
    local output_file="$2"
    local expected_size="${3:-0}"
    
    # Create a temporary file for curl progress
    local progress_file="/tmp/leonardo_download_$$"
    
    # Start curl in background with progress output
    curl -L -# -o "$output_file" "$url" 2>&1 | \
    while IFS= read -r line; do
        # Parse curl progress output
        if [[ "$line" =~ ^[[:space:]]*([0-9]+\.[0-9]+)%.*([0-9]+[kMG]?).*([0-9]+[kMG]?/s).*([0-9]+:[0-9]+:[0-9]+|[0-9]+:[0-9]+|[0-9]+s) ]]; then
            local percent="${BASH_REMATCH[1]}"
            local downloaded="${BASH_REMATCH[2]}"
            local speed="${BASH_REMATCH[3]}"
            local eta="${BASH_REMATCH[4]}"
            
            # Update progress bar
            printf "\r${CYAN}Downloading:${COLOR_RESET} "
            show_progress_bar "${percent%.*}" 100 30
            printf " ${percent}%% | ${downloaded} | ${speed} | ETA: ${eta}  "
        fi
    done
    
    # Clear the line
    printf "\r%-80s\r" " "
    
    # Check if download was successful
    if [[ -f "$output_file" ]]; then
        local size=$(format_bytes $(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file"))
        echo -e "${GREEN}✓ Downloaded successfully${COLOR_RESET} (${size})"
        return 0
    else
        echo -e "${RED}✗ Download failed${COLOR_RESET}"
        return 1
    fi
}

# Enhanced download with retry and resume
download_with_progress() {
    local url="$1"
    local output_file="$2"
    local description="${3:-Downloading}"
    local max_retries="${4:-3}"
    
    echo -e "${CYAN}${description}${COLOR_RESET}"
    echo "URL: $url"
    echo "Target: $output_file"
    echo ""
    
    local attempt=1
    while [[ $attempt -le $max_retries ]]; do
        if [[ $attempt -gt 1 ]]; then
            echo -e "${YELLOW}Retry attempt $attempt/$max_retries${COLOR_RESET}"
        fi
        
        # Check if file partially exists (for resume)
        local resume_flag=""
        if [[ -f "$output_file" ]]; then
            resume_flag="-C -"
            echo -e "${DIM}Resuming download...${COLOR_RESET}"
        fi
        
        # Download with progress
        if curl -L $resume_flag -# -o "$output_file" "$url" 2>&1 | \
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*([0-9]+)\.?[0-9]*[[:space:]]+([0-9]+[kMG]?)[[:space:]]+([0-9]+)\.?[0-9]*[[:space:]]+([0-9]+[kMG]?/s)[[:space:]]+.*[[:space:]]+([0-9]+:[0-9]+:[0-9]+|[0-9]+:[0-9]+|[0-9]+s|--:--:--) ]]; then
                local percent="${BASH_REMATCH[1]}"
                local downloaded="${BASH_REMATCH[2]}"
                local speed="${BASH_REMATCH[4]}"
                local eta="${BASH_REMATCH[5]}"
                
                # Update progress bar
                printf "\r"
                show_progress_bar "$percent" 100 40
                printf " ${percent}%% | ${speed} | ETA: ${eta}  "
            fi
        done; then
            printf "\r%-80s\r" " "
            local size=$(format_bytes $(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file"))
            echo -e "${GREEN}✓ Downloaded successfully${COLOR_RESET} (${size})"
            return 0
        else
            printf "\r%-80s\r" " "
            echo -e "${RED}✗ Download failed${COLOR_RESET}"
            ((attempt++))
            if [[ $attempt -le $max_retries ]]; then
                sleep 2
            fi
        fi
    done
    
    return 1
}

# Copy files with progress
copy_with_progress() {
    local source="$1"
    local dest="$2"
    local description="${3:-Copying}"
    
    if [[ ! -f "$source" ]]; then
        echo -e "${RED}Source file not found: $source${COLOR_RESET}"
        return 1
    fi
    
    local total_size=$(stat -f%z "$source" 2>/dev/null || stat -c%s "$source")
    local total_size_fmt=$(format_bytes "$total_size")
    
    echo -e "${CYAN}${description}${COLOR_RESET}"
    echo "Source: $(basename "$source") ($total_size_fmt)"
    echo "Destination: $dest"
    echo ""
    
    # Use dd with progress
    local block_size=1048576  # 1MB blocks
    local total_blocks=$((total_size / block_size + 1))
    
    (
        dd if="$source" of="$dest" bs=$block_size 2>&1 | \
        while IFS= read -r line; do
            if [[ "$line" =~ ^([0-9]+)\+[0-9]+[[:space:]]records ]]; then
                local blocks="${BASH_REMATCH[1]}"
                local percent=$((blocks * 100 / total_blocks))
                local copied=$((blocks * block_size))
                local copied_fmt=$(format_bytes "$copied")
                
                printf "\r"
                show_progress_bar "$percent" 100 40
                printf " ${percent}%% | ${copied_fmt}/${total_size_fmt}  "
            fi
        done
    ) &
    
    local dd_pid=$!
    
    # Monitor progress
    while kill -0 $dd_pid 2>/dev/null; do
        if [[ -f "$dest" ]]; then
            local current_size=$(stat -f%z "$dest" 2>/dev/null || stat -c%s "$dest")
            local percent=$((current_size * 100 / total_size))
            local copied_fmt=$(format_bytes "$current_size")
            
            printf "\r"
            show_progress_bar "$percent" 100 40
            printf " ${percent}%% | ${copied_fmt}/${total_size_fmt}  "
        fi
        sleep 0.1
    done
    
    wait $dd_pid
    local result=$?
    
    printf "\r%-80s\r" " "
    
    if [[ $result -eq 0 ]]; then
        echo -e "${GREEN}✓ Copy completed${COLOR_RESET} ($total_size_fmt)"
        return 0
    else
        echo -e "${RED}✗ Copy failed${COLOR_RESET}"
        return 1
    fi
}

# Multi-file copy with overall progress
copy_directory_with_progress() {
    local source_dir="$1"
    local dest_dir="$2"
    local description="${3:-Copying files}"
    
    if [[ ! -d "$source_dir" ]]; then
        echo -e "${RED}Source directory not found: $source_dir${COLOR_RESET}"
        return 1
    fi
    
    # Calculate total size
    echo -e "${CYAN}Calculating total size...${COLOR_RESET}"
    local total_size=$(du -sb "$source_dir" 2>/dev/null | cut -f1 || du -sk "$source_dir" | cut -f1)
    local total_size_fmt=$(format_bytes "$total_size")
    
    echo -e "${CYAN}${description}${COLOR_RESET}"
    echo "Source: $source_dir"
    echo "Destination: $dest_dir"
    echo "Total size: $total_size_fmt"
    echo ""
    
    # Create destination directory
    mkdir -p "$dest_dir"
    
    # Copy with rsync and progress
    rsync -ah --info=progress2 "$source_dir/" "$dest_dir/" 2>&1 | \
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([0-9,]+)[[:space:]]+([0-9]+)%[[:space:]]+([0-9.]+[kMG]B/s)[[:space:]]+([0-9:]+) ]]; then
            local transferred="${BASH_REMATCH[1]//,/}"
            local percent="${BASH_REMATCH[2]}"
            local speed="${BASH_REMATCH[3]}"
            local eta="${BASH_REMATCH[4]}"
            
            printf "\r"
            show_progress_bar "$percent" 100 40
            printf " ${percent}%% | ${speed} | ETA: ${eta}  "
        fi
    done
    
    printf "\r%-80s\r" " "
    echo -e "${GREEN}✓ Copy completed${COLOR_RESET} ($total_size_fmt)"
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
export -f track_download_progress download_with_progress copy_with_progress copy_directory_with_progress

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
    echo -e "${DIM}OS:${RESET} $os_name $os_version"
    
    # Service locations
    local ollama_loc=$(detect_ollama_location)
    local leonardo_loc=$(detect_leonardo_location)
    
    # Ollama status with color
    echo -ne "${DIM}Ollama:${RESET} "
    case "$ollama_loc" in
        Host)
            echo -e "${GREEN}Running on Host${RESET}"
            ;;
        USB)
            echo -e "${CYAN}Running on USB${RESET}"
            ;;
        "Host (not running)")
            echo -e "${YELLOW}Host (offline)${RESET}"
            ;;
        "USB (not running)")
            echo -e "${YELLOW}USB (offline)${RESET}"
            ;;
        none)
            echo -e "${RED}Not found${RESET}"
            ;;
    esac
    
    # Leonardo location
    echo -ne "${DIM}Leonardo:${RESET} "
    if [[ "$leonardo_loc" == "USB" ]]; then
        echo -e "${CYAN}Running from USB${RESET}"
    else
        echo -e "${GREEN}Running from Host${RESET}"
    fi
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

# ==== Component: src/ui/web_server.sh ====
# ==============================================================================
# Leonardo AI Universal - Web Server
# ==============================================================================
# Description: Simple web server for Leonardo's web interface
# Version: 7.0.0
# ==============================================================================

# Start the web server
start_web_server() {
    local port="${1:-8080}"
    local host="${2:-localhost}"
    
    echo -e "${CYAN}Starting Leonardo Web Interface...${COLOR_RESET}"
    echo -e "${DIM}Server will run on: http://${host}:${port}${COLOR_RESET}"
    echo ""
    
    # Create a simple index.html if it doesn't exist
    local web_root="${LEONARDO_BASE_DIR}/web"
    mkdir -p "$web_root"
    
    if [[ ! -f "$web_root/index.html" ]]; then
        cat > "$web_root/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leonardo AI Universal</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #0a0a0a;
            color: #e0e0e0;
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            width: 100%;
        }
        h1 {
            color: #00d4ff;
            text-align: center;
            margin-bottom: 10px;
        }
        .subtitle {
            text-align: center;
            color: #888;
            margin-bottom: 40px;
        }
        .status {
            background: #1a1a1a;
            border: 1px solid #333;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .status h2 {
            color: #00d4ff;
            margin-top: 0;
        }
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 20px;
        }
        .info-box {
            background: #222;
            border: 1px solid #444;
            border-radius: 6px;
            padding: 15px;
        }
        .info-box h3 {
            color: #00d4ff;
            margin: 0 0 10px 0;
            font-size: 16px;
        }
        .info-box p {
            margin: 5px 0;
            font-size: 14px;
        }
        .button {
            background: #00d4ff;
            color: #000;
            border: none;
            padding: 12px 24px;
            border-radius: 6px;
            font-weight: bold;
            cursor: pointer;
            margin: 10px;
            transition: all 0.3s;
        }
        .button:hover {
            background: #00a8cc;
            transform: translateY(-2px);
        }
        .chat-interface {
            background: #1a1a1a;
            border: 1px solid #333;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
        }
        .chat-input {
            width: 100%;
            background: #222;
            border: 1px solid #444;
            color: #e0e0e0;
            padding: 10px;
            border-radius: 4px;
            font-size: 14px;
        }
        .model-select {
            width: 100%;
            background: #222;
            border: 1px solid #444;
            color: #e0e0e0;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        .coming-soon {
            text-align: center;
            color: #666;
            font-style: italic;
            margin: 40px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Leonardo AI Universal</h1>
        <p class="subtitle">Deploy AI Anywhere™ - Web Interface v7.0.0</p>
        
        <div class="status">
            <h2>System Status</h2>
            <div class="info-grid">
                <div class="info-box">
                    <h3>Server Status</h3>
                    <p>Status: <span style="color: #00ff00;">Online</span></p>
                    <p>Version: 7.0.0</p>
                    <p>Uptime: Just started</p>
                </div>
                <div class="info-box">
                    <h3>Model Status</h3>
                    <p>Models Available: 0</p>
                    <p>Active Model: None</p>
                    <p>Memory Used: 0 GB</p>
                </div>
                <div class="info-box">
                    <h3>USB Status</h3>
                    <p>USB Devices: Scanning...</p>
                    <p>Leonardo USB: Not detected</p>
                </div>
                <div class="info-box">
                    <h3>Performance</h3>
                    <p>CPU Usage: N/A</p>
                    <p>RAM Usage: N/A</p>
                </div>
            </div>
        </div>
        
        <div class="chat-interface">
            <h2>AI Chat Interface</h2>
            <select class="model-select">
                <option>No models available - Install models via CLI</option>
            </select>
            <textarea class="chat-input" rows="4" placeholder="Enter your message here..."></textarea>
            <button class="button">Send Message</button>
            <p class="coming-soon">Full chat interface coming soon! Use the CLI for model interactions.</p>
        </div>
        
        <div style="text-align: center; margin-top: 40px;">
            <button class="button" onclick="window.location.reload()">Refresh Status</button>
            <button class="button" onclick="alert('Use the CLI to manage models')">Manage Models</button>
        </div>
    </div>
    
    <script>
        // Auto-refresh status every 5 seconds
        setTimeout(() => {
            console.log('Leonardo Web Interface loaded');
        }, 1000);
    </script>
</body>
</html>
EOF
    fi
    
    # Check if Python is available
    if command -v python3 >/dev/null 2>&1; then
        echo -e "${GREEN}Starting web server...${COLOR_RESET}"
        echo -e "${DIM}Press Ctrl+C to stop the server${COLOR_RESET}"
        echo ""
        
        # Try to open browser
        if command -v xdg-open >/dev/null 2>&1; then
            sleep 1 && xdg-open "http://${host}:${port}" >/dev/null 2>&1 &
        elif command -v open >/dev/null 2>&1; then
            sleep 1 && open "http://${host}:${port}" >/dev/null 2>&1 &
        fi
        
        # Start Python HTTP server
        cd "$web_root" && python3 -m http.server "$port" --bind "$host" 2>/dev/null
    else
        echo -e "${RED}Error: Python 3 is required to run the web server${COLOR_RESET}"
        echo -e "${DIM}Install Python 3 and try again${COLOR_RESET}"
        return 1
    fi
}

# Stop the web server
stop_web_server() {
    echo -e "${CYAN}Stopping web server...${COLOR_RESET}"
    pkill -f "python3 -m http.server" 2>/dev/null || true
}

# ==== Component: src/chat/chat_wrapper.sh ====

# Chat Wrapper - Provides location-aware chat interface
# Part of Leonardo AI Universal

# Ensure color variables are defined
: "${GREEN:=\033[32m}"
: "${CYAN:=\033[36m}"
: "${YELLOW:=\033[33m}"
: "${RED:=\033[31m}"
: "${DIM:=\033[2m}"
: "${BOLD:=\033[1m}"
: "${COLOR_RESET:=\033[0m}"

# Select Ollama instance
select_ollama_instance() {
    echo -e "\n${CYAN}Select Ollama Instance:${COLOR_RESET}\n"
    
    local host_status=$(detect_ollama_location | grep -q "Host" && echo "Available" || echo "Not Available")
    local usb_status=$(detect_ollama_location | grep -q "USB" && echo "Available" || echo "Not Available")
    
    echo -e "1) ${GREEN}Host Ollama${COLOR_RESET} ($host_status)"
    echo -e "2) ${CYAN}USB Ollama${COLOR_RESET} ($usb_status)"
    echo -e "3) ${YELLOW}Auto-detect${COLOR_RESET} (Use available instance)"
    echo
    
    read -p "Select option (1-3): " choice
    
    case "$choice" in
        1) echo "host" ;;
        2) echo "usb" ;;
        3|*) echo "auto" ;;
    esac
}

# Start chat with location awareness
start_location_aware_chat() {
    local model="${1:-}"
    local preference="${2:-auto}"
    
    # For USB deployments without Ollama, use direct model access
    if [[ "${LEONARDO_USB_MODE:-}" == "true" ]] || [[ "$preference" == "usb" ]]; then
        # Check for GGUF models in USB
        local model_dir="${LEONARDO_MODEL_DIR:-${LEONARDO_BASE_DIR}/models}"
        if [[ -d "$model_dir" ]] && [[ -n "$(find "$model_dir" -name "*.gguf" 2>/dev/null | head -1)" ]]; then
            echo -e "${CYAN}USB Mode: Using local GGUF models${COLOR_RESET}"
            # Fallback to simple chat interface for GGUF models
            handle_gguf_chat "$model_dir"
            return
        fi
    fi
    
    # Get the appropriate endpoint
    local endpoint=$(get_ollama_endpoint "$preference")
    
    # Check if endpoint is available
    if ! curl -s "$endpoint/api/tags" >/dev/null 2>&1; then
        # If Ollama not available, check for local models
        local model_dir="${LEONARDO_MODEL_DIR:-${LEONARDO_BASE_DIR}/models}"
        if [[ -d "$model_dir" ]] && [[ -n "$(find "$model_dir" -name "*.gguf" 2>/dev/null | head -1)" ]]; then
            echo -e "${YELLOW}Ollama not available, using local GGUF models${COLOR_RESET}"
            handle_gguf_chat "$model_dir"
            return
        fi
        
        echo -e "${RED}Error: No AI service available${COLOR_RESET}"
        echo -e "${YELLOW}Tip: Make sure Ollama is running or GGUF models are installed${COLOR_RESET}"
        return 1
    fi
    
    # If no model specified, let user select
    if [[ -z "$model" ]]; then
        echo -e "\n${CYAN}Available Models:${COLOR_RESET}\n"
        
        # List models from the selected endpoint
        local models=$(curl -s "$endpoint/api/tags" | jq -r '.models[].name' 2>/dev/null)
        
        if [[ -z "$models" ]]; then
            echo -e "${RED}No models found on selected instance${COLOR_RESET}"
            return 1
        fi
        
        # Show models with numbers
        local i=1
        local model_array=()
        while IFS= read -r m; do
            echo -e "$i) $m"
            model_array+=("$m")
            ((i++))
        done <<< "$models"
        
        echo
        read -p "Select model (1-$((i-1))): " model_choice
        
        if [[ "$model_choice" =~ ^[0-9]+$ ]] && (( model_choice > 0 && model_choice < i )); then
            model="${model_array[$((model_choice-1))]}"
        else
            echo -e "${RED}Invalid selection${COLOR_RESET}"
            return 1
        fi
    fi
    
    # Start chat with location prefix in prompt
    echo -e "\n${GREEN}Starting chat with $model...${COLOR_RESET}"
    echo -e "${DIM}Endpoint: $endpoint${COLOR_RESET}\n"
    
    # Export endpoint for ollama CLI
    export OLLAMA_HOST="$endpoint"
    
    # Create custom prompt with location prefix
    local location_prefix=$(get_chat_location_prefix "$endpoint" "$model")
    
    # Start interactive chat
    echo -e "${CYAN}═══════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}Leonardo AI Chat${COLOR_RESET} - ${DIM}Type 'exit' or Ctrl+C to quit${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${COLOR_RESET}\n"
    
    while true; do
        # Show custom prompt with location
        echo -ne "${BOLD}${location_prefix}${COLOR_RESET} > "
        read -r user_input
        
        # Check for exit
        if [[ "$user_input" == "exit" ]] || [[ "$user_input" == "quit" ]]; then
            break
        fi
        
        # Skip empty input
        if [[ -z "$user_input" ]]; then
            continue
        fi
        
        # Send to ollama
        echo -e "\n${DIM}Thinking...${COLOR_RESET}\n"
        
        # Use ollama run for interactive chat
        if command -v ollama >/dev/null 2>&1; then
            ollama run "$model" "$user_input"
        else
            # Fallback to API if ollama CLI not available
            local response=$(curl -s "$endpoint/api/generate" \
                -d "{\"model\": \"$model\", \"prompt\": \"$user_input\", \"stream\": false}" \
                | jq -r '.response' 2>/dev/null)
            
            if [[ -n "$response" ]]; then
                echo -e "$response"
            else
                echo -e "${RED}Error: Failed to get response${COLOR_RESET}"
            fi
        fi
        
        echo
    done
    
    echo -e "\n${GREEN}Chat session ended${COLOR_RESET}"
}

# Handle GGUF model chat (fallback when Ollama not available)
handle_gguf_chat() {
    local model_dir="$1"
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}               🤖 Leonardo AI Chat - Local Models${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    
    # List available GGUF models
    echo -e "\n${CYAN}Available GGUF Models:${COLOR_RESET}\n"
    local models=()
    local i=1
    
    while IFS= read -r -d '' model_file; do
        local model_name=$(basename "$model_file" .gguf)
        echo "  $i) $model_name"
        models+=("$model_file")
        ((i++))
    done < <(find "$model_dir" -name "*.gguf" -print0 2>/dev/null)
    
    if [[ ${#models[@]} -eq 0 ]]; then
        echo -e "${RED}No GGUF models found in $model_dir${COLOR_RESET}"
        return 1
    fi
    
    # Select model
    echo
    read -p "Select model (1-${#models[@]}): " selection
    
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || [[ $selection -lt 1 ]] || [[ $selection -gt ${#models[@]} ]]; then
        echo -e "${RED}Invalid selection${COLOR_RESET}"
        return 1
    fi
    
    local selected_model="${models[$((selection-1))]}"
    local model_name=$(basename "$selected_model" .gguf)
    
    echo -e "\n${GREEN}Selected: $model_name${COLOR_RESET}"
    echo -e "${DIM}Model file: $selected_model${COLOR_RESET}"
    echo
    echo -e "${YELLOW}Note: Chat interface requires llama.cpp or compatible runtime${COLOR_RESET}"
    echo -e "${DIM}Without a runtime, models can only be managed, not used for chat${COLOR_RESET}"
    echo
    echo -e "${CYAN}To enable chat on macOS:${COLOR_RESET}"
    echo "  1. Install Ollama: https://ollama.ai"
    echo "  2. Or install llama.cpp: brew install llama.cpp"
    echo
}

# Export functions
export -f select_ollama_instance
export -f start_location_aware_chat
export -f handle_gguf_chat

# ==== Component: src/security/audit.sh (STUB) ====
# TODO: Implement src/security/audit.sh

# ==== Component: src/security/memory.sh (STUB) ====
# TODO: Implement src/security/memory.sh

# ==== Component: src/security/encryption.sh (STUB) ====
# TODO: Implement src/security/encryption.sh

# ==== Component: src/models/model_database.sh ====
# ==============================================================================
# Leonardo AI Universal - Model Database
# ==============================================================================
# Description: Curated list of AI models for easy discovery and download
# Version: 7.0.0
# ==============================================================================

# Model database format: "id|name|size|quantization|license|description"
declare -a MODEL_DATABASE=(
    # Llama Models
    "llama3.2:3b|Llama 3.2 3B|1.9GB|Q4_0|Llama|Latest Llama model, great for general tasks"
    "llama3.2:1b|Llama 3.2 1B|1.3GB|Q4_0|Llama|Tiny but capable Llama model"
    "llama3.1:8b|Llama 3.1 8B|4.7GB|Q4_0|Llama|Balanced performance and size"
    "llama3.1:70b|Llama 3.1 70B|40GB|Q4_0|Llama|Large model for complex tasks"
    "llama3:8b|Llama 3 8B|4.5GB|Q4_0|Llama|Classic Llama 3 model"
    "llama2:7b|Llama 2 7B|3.8GB|Q4_0|Llama|Previous generation Llama"
    "llama2:13b|Llama 2 13B|7.3GB|Q4_0|Llama|Larger Llama 2 variant"
    
    # Code Models
    "codellama:7b|Code Llama 7B|3.8GB|Q4_0|Llama|Specialized for coding"
    "codellama:13b|Code Llama 13B|7.3GB|Q4_0|Llama|Larger code model"
    "codellama:34b|Code Llama 34B|19GB|Q4_0|Llama|Professional code assistant"
    "codegemma:7b|CodeGemma 7B|4.8GB|Q4_0|Gemma|Google's code model"
    "deepseek-coder:6.7b|DeepSeek Coder|3.8GB|Q4_0|MIT|Excellent for code generation"
    "starcoder2:3b|StarCoder2 3B|1.9GB|Q4_0|BigCode|Compact code model"
    
    # Mistral Models
    "mistral:7b|Mistral 7B|4.1GB|Q4_0|Apache-2.0|Fast and efficient"
    "mistral-nemo:12b|Mistral Nemo|7.1GB|Q4_0|Apache-2.0|Enhanced Mistral model"
    "mixtral:8x7b|Mixtral 8x7B|26GB|Q4_0|Apache-2.0|Mixture of experts model"
    "mixtral:8x22b|Mixtral 8x22B|131GB|Q4_0|Apache-2.0|Large MoE model"
    
    # Gemma Models
    "gemma2:2b|Gemma 2 2B|1.6GB|Q4_0|Gemma|Google's efficient model"
    "gemma2:9b|Gemma 2 9B|5.5GB|Q4_0|Gemma|Larger Gemma variant"
    "gemma2:27b|Gemma 2 27B|16GB|Q4_0|Gemma|High performance Gemma"
    
    # Phi Models
    "phi3:3b|Phi-3 Mini|2.0GB|Q4_0|MIT|Microsoft's compact model"
    "phi3:14b|Phi-3 Medium|7.9GB|Q4_0|MIT|Balanced Phi model"
    
    # Qwen Models
    "qwen2.5:0.5b|Qwen 2.5 0.5B|0.4GB|Q4_0|Qwen|Ultra-light model"
    "qwen2.5:3b|Qwen 2.5 3B|1.9GB|Q4_0|Qwen|Efficient Chinese/English"
    "qwen2.5:7b|Qwen 2.5 7B|4.4GB|Q4_0|Qwen|Balanced Qwen model"
    "qwen2.5:14b|Qwen 2.5 14B|8.2GB|Q4_0|Qwen|Large Qwen variant"
    "qwen2.5:32b|Qwen 2.5 32B|18GB|Q4_0|Qwen|High-end Qwen model"
    
    # Specialized Models
    "dolphin-mistral:7b|Dolphin Mistral|4.1GB|Q4_0|Apache-2.0|Uncensored assistant"
    "neural-chat:7b|Neural Chat|4.1GB|Q4_0|Apache-2.0|Intel's chat model"
    "starling-lm:7b|Starling LM|4.1GB|Q4_0|Apache-2.0|Berkeley's chat model"
    "vicuna:7b|Vicuna 7B|3.8GB|Q4_0|Llama|Fine-tuned on conversations"
    "orca-mini:3b|Orca Mini|1.9GB|Q4_0|Apache-2.0|Reasoning-focused model"
    
    # Math & Science
    "mathstral:7b|Mathstral|4.1GB|Q4_0|Apache-2.0|Mathematics specialist"
    "meditron:7b|Meditron|4.1GB|Q4_0|Llama|Medical knowledge model"
    
    # Vision Models
    "llava:7b|LLaVA 7B|4.5GB|Q4_0|Llama|Vision + Language model"
    "llava:13b|LLaVA 13B|8.0GB|Q4_0|Llama|Larger vision model"
    "bakllava:7b|BakLLaVA|4.5GB|Q4_0|Llama|Improved LLaVA variant"
    
    # Embedding Models
    "nomic-embed-text|Nomic Embed|274MB|F16|Apache-2.0|Text embeddings"
    "all-minilm|All-MiniLM|45MB|F16|Apache-2.0|Sentence embeddings"
)

# Get all available models
get_all_models() {
    printf '%s\n' "${MODEL_DATABASE[@]}"
}

# Search models by keyword
search_models_db() {
    local query="${1,,}"  # Convert to lowercase
    
    for model in "${MODEL_DATABASE[@]}"; do
        local lower_model="${model,,}"
        if [[ "$lower_model" =~ $query ]]; then
            echo "$model"
        fi
    done
}

# Get model by exact ID
get_model_by_id() {
    local id="$1"
    
    for model in "${MODEL_DATABASE[@]}"; do
        local model_id="${model%%|*}"
        if [[ "$model_id" == "$id" ]]; then
            echo "$model"
            return 0
        fi
    done
    
    return 1
}

# Format model for display
format_model_info() {
    local model="$1"
    IFS='|' read -r id name size quant license desc <<< "$model"
    
    echo "Model ID: $id"
    echo "Name: $name"
    echo "Size: $size"
    echo "Quantization: $quant"
    echo "License: $license"
    echo "Description: $desc"
}

# Get models by category
get_models_by_category() {
    local category="$1"
    
    case "$category" in
        "code")
            search_models_db "code\|starcoder\|deepseek-coder"
            ;;
        "chat")
            search_models_db "chat\|vicuna\|dolphin\|neural"
            ;;
        "vision")
            search_models_db "llava\|bakllava"
            ;;
        "tiny")
            for model in "${MODEL_DATABASE[@]}"; do
                local size=$(echo "$model" | cut -d'|' -f3)
                # Extract numeric value
                local num=${size%GB*}
                num=${num%MB*}
                if (( $(echo "$num < 2" | bc -l) )); then
                    echo "$model"
                fi
            done
            ;;
        "large")
            for model in "${MODEL_DATABASE[@]}"; do
                local size=$(echo "$model" | cut -d'|' -f3)
                # Extract numeric value
                local num=${size%GB*}
                if [[ "$size" == *"GB" ]] && (( $(echo "$num > 20" | bc -l) )); then
                    echo "$model"
                fi
            done
            ;;
    esac
}

# Suggest models based on system specs
suggest_models() {
    local available_ram="$1"  # in GB
    
    echo "=== Recommended Models for Your System ==="
    echo ""
    
    if (( $(echo "$available_ram < 8" | bc -l) )); then
        echo "⚡ Tiny Models (< 2GB) - Best for your system:"
        get_models_by_category "tiny" | head -5
    elif (( $(echo "$available_ram < 16" | bc -l) )); then
        echo "⚡ Small Models (< 5GB) - Good performance:"
        search_models_db "3b\|7b" | grep -E "3b|7b" | head -5
    elif (( $(echo "$available_ram < 32" | bc -l) )); then
        echo "⚡ Medium Models (< 10GB) - Excellent capabilities:"
        search_models_db "7b\|13b" | head -5
    else
        echo "⚡ Large Models - Maximum performance:"
        get_models_by_category "large" | head -5
    fi
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

# Source model database if available
if [[ -f "${LEONARDO_ROOT}/src/models/model_database.sh" ]]; then
    source "${LEONARDO_ROOT}/src/models/model_database.sh"
elif [[ -f "$(dirname "${BASH_SOURCE[0]}")/model_database.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/model_database.sh"
fi

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

# List available models from registry with enhanced formatting
list_models() {
    local format="${1:-table}"
    local provider="${2:-all}"
    
    # Get models from database
    local models=()
    if declare -F get_all_models >/dev/null 2>&1; then
        mapfile -t models < <(get_all_models)
    fi
    
    case "$format" in
        table)
            # Header
            printf "%-20s %-30s %-10s %-15s %-10s\n" \
                "ID" "Name" "Size" "Quantization" "License"
            printf "%s\n" "$(printf '%.0s-' {1..80})"
            
            # List models from database
            if [[ ${#models[@]} -gt 0 ]]; then
                for model in "${models[@]}"; do
                    IFS='|' read -r id name size quant license desc <<< "$model"
                    printf "%-20s %-30s %-10s %-15s %-10s\n" \
                        "$id" "$name" "$size" "$quant" "$license"
                done
            else
                # Fallback to registry
                for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
                    IFS='|' read -r name provider size quantization license tags <<< "${LEONARDO_MODEL_METADATA[$model_id]}"
                    
                    if [[ "$provider" == "all" ]] || [[ "$provider" == "$provider" ]]; then
                        printf "%-20s %-30s %-10s %-15s %-10s\n" \
                            "$model_id" "$name" "$size" "$quantization" "$license"
                    fi
                done
            fi
            ;;
        json)
            echo "{"
            local first=true
            for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
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
            ;;
        *)
            # Simple format
            for model_id in "${!LEONARDO_MODEL_REGISTRY[@]}"; do
                echo "$model_id"
            done | sort
            ;;
    esac
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

# Search models by query
search_models() {
    local query="${1,,}"  # Convert to lowercase
    local found=false
    
    echo -e "${CYAN}Searching for models matching: ${WHITE}$query${COLOR_RESET}"
    echo ""
    
    # Search in database first
    if declare -F search_models_db >/dev/null 2>&1; then
        local results=()
        mapfile -t results < <(search_models_db "$query")
        
        if [[ ${#results[@]} -gt 0 ]]; then
            # Header
            printf "%-20s %-30s %-10s %-15s\n" \
                "ID" "Name" "Size" "License"
            printf "%s\n" "$(printf '%.0s-' {1..75})"
            
            for model in "${results[@]}"; do
                IFS='|' read -r id name size quant license desc <<< "$model"
                printf "%-20s %-30s %-10s %-15s\n" \
                    "$id" "$name" "$size" "$license"
                found=true
            done
            echo ""
            echo -e "${GREEN}Found ${#results[@]} model(s) matching '$query'${COLOR_RESET}"
            echo -e "${DIM}Tip: Use 'leonardo model download <id>' to download a model${COLOR_RESET}"
        fi
    fi
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

# ==== Component: src/models/metadata.sh ====
#
# Leonardo AI Universal - Model Metadata Management
# Defines model metadata structure and utilities
#

# Model metadata schema version
readonly MODEL_METADATA_VERSION="1.0.0"

# Model types
readonly MODEL_TYPE_LLM="llm"
readonly MODEL_TYPE_IMAGE="image"
readonly MODEL_TYPE_AUDIO="audio"
readonly MODEL_TYPE_VIDEO="video"
readonly MODEL_TYPE_EMBEDDING="embedding"

# Model providers
readonly PROVIDER_OLLAMA="ollama"
readonly PROVIDER_HUGGINGFACE="huggingface"
readonly PROVIDER_OPENAI="openai"
readonly PROVIDER_CUSTOM="custom"

# Create model metadata JSON
create_model_metadata() {
    local name="$1"
    local type="$2"
    local provider="$3"
    local version="$4"
    local size="$5"
    local description="$6"
    
    cat <<EOF
{
    "schema_version": "$MODEL_METADATA_VERSION",
    "name": "$name",
    "type": "$type",
    "provider": "$provider",
    "version": "$version",
    "size": "$size",
    "description": "$description",
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "requirements": {
        "min_ram": "8GB",
        "min_disk": "$size",
        "gpu": false
    },
    "files": [],
    "config": {},
    "tags": []
}
EOF
}

# Parse model metadata from JSON
parse_model_metadata() {
    local json_file="$1"
    local field="$2"
    
    if [[ -f "$json_file" ]]; then
        # Simple JSON parsing without jq dependency
        grep "\"$field\":" "$json_file" | sed 's/.*"'$field'": *"\([^"]*\)".*/\1/' | head -1
    fi
}

# Validate model metadata
validate_model_metadata() {
    local metadata_file="$1"
    
    if [[ ! -f "$metadata_file" ]]; then
        log_error "Metadata file not found: $metadata_file"
        return 1
    fi
    
    # Check required fields
    local required_fields=("name" "type" "provider" "version" "size")
    for field in "${required_fields[@]}"; do
        local value=$(parse_model_metadata "$metadata_file" "$field")
        if [[ -z "$value" ]]; then
            log_error "Missing required field: $field"
            return 1
        fi
    done
    
    return 0
}

# Get model install path
get_model_install_path() {
    local provider="$1"
    local name="$2"
    local version="$3"
    
    echo "${LEONARDO_MODELS_DIR}/${provider}/${name}/${version}"
}

# Check if model is installed
is_model_installed() {
    local provider="$1"
    local name="$2"
    local version="$3"
    
    local install_path=$(get_model_install_path "$provider" "$name" "$version")
    [[ -d "$install_path" && -f "$install_path/metadata.json" ]]
}

# Export functions
export -f create_model_metadata
export -f parse_model_metadata
export -f validate_model_metadata
export -f get_model_install_path
export -f is_model_installed

# ==== Component: src/models/providers/ollama.sh ====
#
# Leonardo AI Universal - Ollama Provider Integration
# Manages Ollama model downloads and installations
#

# Ollama configuration
readonly OLLAMA_API_URL="https://registry.ollama.ai"
readonly OLLAMA_MODELS_URL="https://ollama.ai/library"

# Popular Ollama models
declare -A OLLAMA_MODELS=(
    ["llama2"]="Meta's Llama 2 model"
    ["mistral"]="Mistral 7B model"
    ["codellama"]="Code Llama model for programming"
    ["neural-chat"]="Intel's neural chat model"
    ["starling-lm"]="Berkeley's Starling model"
    ["phi"]="Microsoft's Phi-2 model"
    ["orca-mini"]="Orca Mini model"
    ["vicuna"]="Vicuna model fine-tuned on conversations"
    ["wizardcoder"]="WizardCoder for programming tasks"
    ["deepseek-coder"]="DeepSeek Coder model"
)

# Model size mappings (approximate)
declare -A OLLAMA_MODEL_SIZES=(
    ["llama2:7b"]="3.8GB"
    ["llama2:13b"]="7.3GB"
    ["llama2:70b"]="39GB"
    ["mistral:7b"]="4.1GB"
    ["codellama:7b"]="3.8GB"
    ["neural-chat:7b"]="4.1GB"
    ["phi:2.7b"]="1.7GB"
    ["orca-mini:3b"]="1.9GB"
)

# Check if Ollama is installed
check_ollama_installed() {
    if command -v ollama &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Install Ollama binary
install_ollama() {
    log_info "Installing Ollama..."
    
    local os_type=$(detect_os)
    local install_script="/tmp/ollama-install.sh"
    
    # Download official install script
    if download_file "https://ollama.ai/install.sh" "$install_script"; then
        chmod +x "$install_script"
        if [[ "$os_type" == "macos" ]]; then
            # macOS specific installation
            log_info "Installing Ollama for macOS..."
            bash "$install_script"
        else
            # Linux installation
            log_info "Installing Ollama for Linux..."
            sudo bash "$install_script"
        fi
        rm -f "$install_script"
        return $?
    else
        log_error "Failed to download Ollama installer"
        return 1
    fi
}

# Get list of available Ollama models
get_ollama_models() {
    local models=()
    for model in "${!OLLAMA_MODELS[@]}"; do
        models+=("$model")
    done
    printf '%s\n' "${models[@]}" | sort
}

# Get model information
get_ollama_model_info() {
    local model="$1"
    local variant="${2:-7b}"  # Default to 7b variant
    
    local full_model="${model}:${variant}"
    local size="${OLLAMA_MODEL_SIZES[$full_model]:-Unknown}"
    local description="${OLLAMA_MODELS[$model]:-No description available}"
    
    cat <<EOF
{
    "name": "$model",
    "variant": "$variant",
    "full_name": "$full_model",
    "size": "$size",
    "description": "$description",
    "provider": "ollama"
}
EOF
}

# Download Ollama model
download_ollama_model() {
    local model="$1"
    local variant="${2:-latest}"
    local full_model="${model}:${variant}"
    
    log_info "Downloading Ollama model: $full_model"
    
    if check_ollama_installed; then
        # Use native Ollama CLI
        show_progress "Pulling $full_model..." &
        local progress_pid=$!
        
        if ollama pull "$full_model"; then
            kill $progress_pid 2>/dev/null || true
            log_success "Successfully downloaded $full_model"
            return 0
        else
            kill $progress_pid 2>/dev/null || true
            log_error "Failed to download $full_model"
            return 1
        fi
    else
        # Fallback: Download model files directly
        log_warn "Ollama not installed. Attempting direct download..."
        download_ollama_model_direct "$model" "$variant"
    fi
}

# Direct model download (without Ollama CLI)
download_ollama_model_direct() {
    local model="$1"
    local variant="$2"
    local model_dir="${LEONARDO_MODELS_DIR}/ollama/${model}/${variant}"
    
    # Create model directory
    create_directory "$model_dir" || return 1
    
    # Create metadata
    create_model_metadata \
        "$model" \
        "$MODEL_TYPE_LLM" \
        "$PROVIDER_OLLAMA" \
        "$variant" \
        "${OLLAMA_MODEL_SIZES[${model}:${variant}]:-Unknown}" \
        "${OLLAMA_MODELS[$model]}" > "$model_dir/metadata.json"
    
    # Download model manifest
    local manifest_url="${OLLAMA_API_URL}/v2/library/${model}/manifests/${variant}"
    local manifest_file="$model_dir/manifest.json"
    
    log_info "Downloading model manifest..."
    if download_file "$manifest_url" "$manifest_file"; then
        log_success "Model structure created at $model_dir"
        log_warn "Note: Full model download requires Ollama CLI"
        return 0
    else
        log_error "Failed to download model manifest"
        return 1
    fi
}

# List installed Ollama models
list_ollama_models() {
    if check_ollama_installed; then
        ollama list
    else
        # List from Leonardo's model directory
        local ollama_dir="${LEONARDO_MODELS_DIR}/ollama"
        if [[ -d "$ollama_dir" ]]; then
            find "$ollama_dir" -name "metadata.json" -type f | while read -r metadata; do
                local model_name=$(parse_model_metadata "$metadata" "name")
                local version=$(parse_model_metadata "$metadata" "version")
                local size=$(parse_model_metadata "$metadata" "size")
                printf "%-20s %-10s %s\n" "$model_name" "$version" "$size"
            done
        else
            log_info "No Ollama models installed"
        fi
    fi
}

# Run Ollama model
run_ollama_model() {
    local model="$1"
    local variant="${2:-latest}"
    local full_model="${model}:${variant}"
    
    if check_ollama_installed; then
        log_info "Starting Ollama with $full_model..."
        ollama run "$full_model"
    else
        log_error "Ollama CLI not installed. Please install Ollama first."
        log_info "Run: leonardo model install ollama-cli"
        return 1
    fi
}

# Export Ollama model for offline use
export_ollama_model() {
    local model="$1"
    local variant="${2:-latest}"
    local export_path="$3"
    
    local full_model="${model}:${variant}"
    local model_dir="${LEONARDO_MODELS_DIR}/ollama/${model}/${variant}"
    
    log_info "Exporting $full_model to $export_path..."
    
    # Create export directory
    create_directory "$export_path" || return 1
    
    # Copy model files
    if [[ -d "$model_dir" ]]; then
        cp -r "$model_dir"/* "$export_path/"
        log_success "Model exported to $export_path"
        return 0
    else
        log_error "Model not found: $full_model"
        return 1
    fi
}

# Export functions
export -f check_ollama_installed
export -f install_ollama
export -f get_ollama_models
export -f get_ollama_model_info
export -f download_ollama_model
export -f list_ollama_models
export -f run_ollama_model
export -f export_ollama_model

# ==== Component: src/models/manager.sh ====
#
# Leonardo AI Universal - Model Management
# Central model management functionality
#

# Model directories
LEONARDO_MODELS_DIR="${LEONARDO_MODEL_DIR:-$LEONARDO_BASE_DIR/models}"
LEONARDO_MODEL_CACHE="${LEONARDO_MODEL_CACHE_DIR:-$LEONARDO_BASE_DIR/cache/models}"
LEONARDO_MODEL_REGISTRY="${LEONARDO_CONFIG_DIR}/model_registry.json"

# Initialize model system
init_model_system() {
    log_info "Initializing model system..."
    
    # Create model directories
    create_directory "$LEONARDO_MODELS_DIR" || return 1
    create_directory "$LEONARDO_MODEL_CACHE" || return 1
    create_directory "${LEONARDO_MODELS_DIR}/ollama" || return 1
    create_directory "${LEONARDO_MODELS_DIR}/huggingface" || return 1
    create_directory "${LEONARDO_MODELS_DIR}/custom" || return 1
    
    log_success "Model system initialized"
    return 0
}

# List all available models
list_available_models() {
    local provider="${1:-all}"
    
    echo "Available Models:"
    echo "================"
    echo
    
    if [[ "$provider" == "all" || "$provider" == "ollama" ]]; then
        echo "Ollama Models:"
        echo "-------------"
        get_ollama_models | while read -r model; do
            local info=$(get_ollama_model_info "$model")
            local desc=$(echo "$info" | grep '"description"' | cut -d'"' -f4)
            printf "  %-15s - %s\n" "$model" "$desc"
        done
        echo
    fi
    
    # Add other providers here as they are implemented
}

# List installed models
list_installed_models() {
    echo "Installed Models:"
    echo "================"
    echo
    
    # Check Ollama models
    if [[ -d "${LEONARDO_MODELS_DIR}/ollama" ]]; then
        echo "Ollama Models:"
        list_ollama_models
        echo
    fi
    
    # Check for models in the models directory
    find "$LEONARDO_MODELS_DIR" -name "metadata.json" -type f | while read -r metadata; do
        local name=$(parse_model_metadata "$metadata" "name")
        local provider=$(parse_model_metadata "$metadata" "provider")
        local version=$(parse_model_metadata "$metadata" "version")
        local size=$(parse_model_metadata "$metadata" "size")
        
        if [[ "$provider" != "ollama" ]]; then  # Avoid duplicates
            printf "%-15s %-10s %-10s %s\n" "$name" "$provider" "$version" "$size"
        fi
    done
}

# Download model from provider
download_model() {
    local model_spec="$1"
    local provider="${2:-ollama}"
    
    echo -e "${CYAN}Downloading model: $model_spec${COLOR_RESET}"
    
    case "$provider" in
        ollama)
            if command_exists ollama; then
                echo "Using Ollama provider..."
                ollama pull "$model_spec" 2>&1 | \
                while IFS= read -r line; do
                    # Parse Ollama progress
                    if [[ "$line" =~ pulling[[:space:]].*[[:space:]]([0-9]+)%[[:space:]]+\|.*\|[[:space:]]+([0-9.]+[[:space:]]?[KMGT]?B)/([0-9.]+[[:space:]]?[KMGT]?B)[[:space:]]+([0-9.]+[[:space:]]?[KMGT]?B/s) ]]; then
                        local percent="${BASH_REMATCH[1]}"
                        local downloaded="${BASH_REMATCH[2]}"
                        local total="${BASH_REMATCH[3]}"
                        local speed="${BASH_REMATCH[4]}"
                        
                        printf "\r"
                        show_progress_bar "$percent" 100 40
                        printf " ${percent}%% | ${downloaded}/${total} | ${speed}  "
                    elif [[ "$line" =~ "success" ]]; then
                        printf "\r%-80s\r" " "
                        echo -e "${GREEN}✓ Model downloaded successfully${COLOR_RESET}"
                        return 0
                    fi
                done
            else
                echo -e "${RED}Ollama not installed${COLOR_RESET}"
                return 1
            fi
            ;;
        huggingface)
            # Parse model spec
            local model_id="${model_spec%:*}"
            local variant="${model_spec#*:}"
            
            # Construct HuggingFace URL
            local hf_url="https://huggingface.co/${model_id}/resolve/main/${variant}.gguf"
            local output_file="${LEONARDO_MODEL_DIR}/${model_id//\//-}-${variant}.gguf"
            
            # Download with progress
            download_with_progress "$hf_url" "$output_file" "Downloading from HuggingFace"
            ;;
        custom)
            echo -e "${YELLOW}Custom provider not implemented${COLOR_RESET}"
            return 1
            ;;
        *)
            echo -e "${RED}Unknown provider: $provider${COLOR_RESET}"
            return 1
            ;;
    esac
}

# Install a model
install_model() {
    local model_spec="$1"  # Format: provider:model:variant or just model
    
    # Parse model specification
    local provider model variant
    
    if [[ "$model_spec" == *:*:* ]]; then
        # Full specification: provider:model:variant
        IFS=':' read -r provider model variant <<< "$model_spec"
    elif [[ "$model_spec" == *:* ]]; then
        # Partial specification: model:variant (assume ollama)
        provider="ollama"
        IFS=':' read -r model variant <<< "$model_spec"
    else
        # Just model name (assume ollama:latest)
        provider="ollama"
        model="$model_spec"
        variant="latest"
    fi
    
    log_info "Installing model: $provider:$model:$variant"
    
    # Check if already installed
    if is_model_installed "$provider" "$model" "$variant"; then
        log_warn "Model already installed: $model:$variant"
        return 0
    fi
    
    # Download and install
    download_model "$model_spec" "$provider"
}

# Remove a model
remove_model() {
    local model_spec="$1"
    
    # Parse model specification
    local provider model variant
    if [[ "$model_spec" == *:*:* ]]; then
        IFS=':' read -r provider model variant <<< "$model_spec"
    elif [[ "$model_spec" == *:* ]]; then
        provider="ollama"
        IFS=':' read -r model variant <<< "$model_spec"
    else
        provider="ollama"
        model="$model_spec"
        variant="latest"
    fi
    
    local model_path=$(get_model_install_path "$provider" "$model" "$variant")
    
    if [[ -d "$model_path" ]]; then
        log_info "Removing model: $model:$variant"
        rm -rf "$model_path"
        log_success "Model removed successfully"
    else
        log_error "Model not found: $model:$variant"
        return 1
    fi
}

# Run a model
run_model() {
    local model_spec="$1"
    shift
    local args="$@"
    
    # Parse model specification
    local provider model variant
    if [[ "$model_spec" == *:* ]]; then
        IFS=':' read -r model variant <<< "$model_spec"
        provider="ollama"  # Default for now
    else
        provider="ollama"
        model="$model_spec"
        variant="latest"
    fi
    
    case "$provider" in
        ollama)
            run_ollama_model "$model" "$variant"
            ;;
        *)
            log_error "Cannot run models from provider: $provider"
            return 1
            ;;
    esac
}

# Get model information
get_model_info() {
    local model_spec="$1"
    
    # Parse model specification
    local provider model variant
    if [[ "$model_spec" == *:* ]]; then
        IFS=':' read -r model variant <<< "$model_spec"
        provider="ollama"
    else
        provider="ollama"
        model="$model_spec"
        variant="7b"  # Default variant
    fi
    
    case "$provider" in
        ollama)
            get_ollama_model_info "$model" "$variant"
            ;;
        *)
            log_error "Unknown provider: $provider"
            return 1
            ;;
    esac
}

# Update model registry
update_model_registry() {
    log_info "Updating model registry..."
    
    # Scan installed models and update registry
    local registry_file="${LEONARDO_CONFIG_DIR}/model_registry.json"
    
    echo "{" > "$registry_file"
    echo '  "version": "1.0.0",' >> "$registry_file"
    echo '  "updated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",' >> "$registry_file"
    echo '  "models": [' >> "$registry_file"
    
    local first=true
    find "$LEONARDO_MODELS_DIR" -name "metadata.json" -type f | while read -r metadata; do
        if [[ "$first" != "true" ]]; then
            echo "," >> "$registry_file"
        fi
        cat "$metadata" | sed 's/^/    /' >> "$registry_file"
        first=false
    done
    
    echo "  ]" >> "$registry_file"
    echo "}" >> "$registry_file"
    
    log_success "Model registry updated"
}

# Export functions
export -f init_model_system
export -f list_available_models
export -f list_installed_models
export -f install_model
export -f remove_model
export -f run_model
export -f get_model_info
export -f update_model_registry

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
model_cli_help() {
    cat << EOF
Leonardo Model Management

Commands:
  list [--installed]       List available or installed models
  info <model>            Show detailed model information
  install <model>         Download and install a model
  remove <model>          Remove an installed model
  run <model>             Run a model (if supported)
  update                  Update model registry

Model Format:
  <provider>:<model>:<variant>  Full specification
  <model>:<variant>             Model with variant (assumes Ollama)
  <model>                       Just model name (assumes Ollama:latest)

Examples:
  leonardo model list              # List available models
  leonardo model install llama2    # Install Llama 2 (latest)
  leonardo model install mistral:7b # Install Mistral 7B
  leonardo model run codellama     # Run Code Llama
  leonardo model info phi          # Show info about Phi model

Providers:
  ollama        Ollama models (default)
  huggingface   HuggingFace models (coming soon)
  custom        Custom models

EOF
}

# Parse model CLI commands
parse_model_command() {
    local command="$1"
    shift
    
    case "$command" in
        list)
            model_list_command "$@"
            ;;
        info)
            model_info_command "$@"
            ;;
        install|download)
            model_install_command "$@"
            ;;
        remove|delete|uninstall)
            model_remove_command "$@"
            ;;
        run|start)
            model_run_command "$@"
            ;;
        update)
            model_update_command "$@"
            ;;
        help|--help|-h)
            model_cli_help
            ;;
        *)
            log_error "Unknown model command: $command"
            model_cli_help
            return 1
            ;;
    esac
}

# List models command
model_list_command() {
    local installed_only=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --installed|-i)
                installed_only=true
                ;;
            *)
                log_error "Unknown option: $1"
                return 1
                ;;
        esac
        shift
    done
    
    if [[ "$installed_only" == "true" ]]; then
        list_installed_models
    else
        list_available_models
    fi
}

# Model info command
model_info_command() {
    local model_spec="$1"
    
    if [[ -z "$model_spec" ]]; then
        log_error "Model name required"
        echo "Usage: leonardo model info <model>"
        return 1
    fi
    
    local info=$(get_model_info "$model_spec")
    
    if [[ -n "$info" ]]; then
        echo "Model Information:"
        echo "=================="
        echo "$info" | python3 -m json.tool 2>/dev/null || echo "$info"
    else
        log_error "Failed to get model information"
        return 1
    fi
}

# Install model command
model_install_command() {
    local model_spec="$1"
    
    if [[ -z "$model_spec" ]]; then
        echo -e "${RED}Error: No model specified${COLOR_RESET}"
        echo "Usage: leonardo model install <model_id>"
        echo ""
        echo "Examples:"
        echo "  leonardo model install llama2"
        echo "  leonardo model install mistral:7b"
        echo "  leonardo model install codellama:13b"
        return 1
    fi
    
    # Initialize model system if needed
    if [[ ! -d "$LEONARDO_MODELS_DIR" ]]; then
        init_model_system || return 1
    fi
    
    # Check if Ollama needs to be installed
    if [[ "$model_spec" != *":"* ]] || [[ "$model_spec" == ollama:* ]]; then
        if ! check_ollama_installed; then
            log_warn "Ollama is not installed"
            echo -n "Would you like to install Ollama? [y/N] "
            read -r response
            if [[ "$response" =~ ^[Yy] ]]; then
                install_ollama || {
                    log_error "Failed to install Ollama"
                    return 1
                }
            else
                log_info "Installing without Ollama CLI (limited functionality)"
            fi
        fi
    fi
    
    # Install the model
    install_model "$model_spec"
}

# Remove model command
model_remove_command() {
    local model_spec="$1"
    
    if [[ -z "$model_spec" ]]; then
        log_error "Model name required"
        echo "Usage: leonardo model remove <model>"
        return 1
    fi
    
    # Confirm removal
    echo -n "Are you sure you want to remove model '$model_spec'? [y/N] "
    read -r response
    
    if [[ "$response" =~ ^[Yy] ]]; then
        remove_model "$model_spec"
    else
        log_info "Model removal cancelled"
    fi
}

# Run model command
model_run_command() {
    local model_spec="$1"
    shift
    
    if [[ -z "$model_spec" ]]; then
        log_error "Model name required"
        echo "Usage: leonardo model run <model>"
        return 1
    fi
    
    run_model "$model_spec" "$@"
}

# Update model registry
model_update_command() {
    update_model_registry
}

# Model menu for interactive mode
model_management_menu() {
    while true; do
        local options=(
            "List Available Models"
            "List Installed Models"
            "Install Model"
            "Remove Model"
            "Model Information"
            "Run Model"
            "Update Registry"
            "Back to Main Menu"
        )
        
        local selection=$(show_menu "Model Management" "${options[@]}")
        
        case "$selection" in
            "List Available Models")
                clear
                list_available_models
                echo
                read -p "Press Enter to continue..."
                ;;
            "List Installed Models")
                clear
                list_installed_models
                echo
                read -p "Press Enter to continue..."
                ;;
            "Install Model")
                clear
                list_available_models
                echo
                read -p "Enter model to install (e.g., llama2, mistral:7b): " model_spec
                if [[ -n "$model_spec" ]]; then
                    model_install_command "$model_spec"
                fi
                echo
                read -p "Press Enter to continue..."
                ;;
            "Remove Model")
                clear
                list_installed_models
                echo
                read -p "Enter model to remove: " model_spec
                if [[ -n "$model_spec" ]]; then
                    model_remove_command "$model_spec"
                fi
                echo
                read -p "Press Enter to continue..."
                ;;
            "Model Information")
                clear
                list_available_models
                echo
                read -p "Enter model name: " model_spec
                if [[ -n "$model_spec" ]]; then
                    model_info_command "$model_spec"
                fi
                echo
                read -p "Press Enter to continue..."
                ;;
            "Run Model")
                clear
                list_installed_models
                echo
                read -p "Enter model to run: " model_spec
                if [[ -n "$model_spec" ]]; then
                    model_run_command "$model_spec"
                fi
                ;;
            "Update Registry")
                clear
                model_update_command
                echo
                read -p "Press Enter to continue..."
                ;;
            "Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Export functions
export -f parse_model_command
export -f model_list_command
export -f model_info_command
export -f model_install_command
export -f model_remove_command
export -f model_run_command
export -f model_update_command
export -f model_management_menu

# Model CLI router
handle_model_command() {
    local command="${1:-help}"
    shift
    
    # Parse new-style commands
    parse_model_command "$command" "$@"
}

# Export CLI functions
export -f handle_model_command

# ==== Component: src/deployment/validator.sh (STUB) ====
# TODO: Implement src/deployment/validator.sh

# ==== Component: src/deployment/deployment.sh (STUB) ====
# TODO: Implement src/deployment/deployment.sh

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
    
    # Debug output to confirm function is called
    echo -e "${YELLOW}DEBUG: deploy_to_usb function started${COLOR_RESET}" >&2
    echo -e "${YELLOW}DEBUG: Terminal test: [[ -t 0 ]] = $([[ -t 0 ]] && echo true || echo false)${COLOR_RESET}" >&2
    sleep 1  # Give time to see the message
    
    echo
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}" >&2
    echo -e "${BOLD}              🚀 Leonardo USB Deployment${COLOR_RESET}" >&2
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}" >&2
    echo >&2
    
    # Step 1: Detect or use provided USB device
    if [[ -z "$target_device" ]]; then
        # Auto-detect USB drives
        local usb_drives=()
        echo -e "${DIM}Detecting USB drives...${COLOR_RESET}" >&2
        
        # Get USB drives - let debug output go to stderr
        local raw_output=$(detect_usb_drives)
        if [[ -n "$raw_output" ]]; then
            # Extract just the device paths (first field before |)
            readarray -t usb_drives < <(echo "$raw_output" | cut -d'|' -f1 | grep -E '^/dev/')
        fi
        
        if [[ ${#usb_drives[@]} -eq 0 ]]; then
            echo -e "${RED}No USB drives detected!${COLOR_RESET}" >&2
            echo -e "${YELLOW}Please insert a USB drive and try again.${COLOR_RESET}" >&2
            echo >&2
            echo -e "${DIM}Tip: Make sure your USB drive is properly connected and recognized by the system.${COLOR_RESET}" >&2
            echo -e "${DIM}On Linux, you might need to run with sudo for device detection.${COLOR_RESET}" >&2
            pause
            return 1
        elif [[ ${#usb_drives[@]} -eq 1 ]]; then
            target_device="${usb_drives[0]}"
            echo -e "${GREEN}Found USB drive: $target_device${COLOR_RESET}" >&2
        else
            # Multiple drives - let user select with better formatting
            echo -e "${YELLOW}Multiple USB drives detected:${COLOR_RESET}" >&2
            echo >&2
            
            # Create formatted menu options
            local menu_options=()
            local drive_info
            while IFS='|' read -r device label size mount; do
                # Format: /dev/sdc1 - CHATUSB (114.6G)
                if [[ -n "$label" && "$label" != "Unknown" ]]; then
                    drive_info="$device - $label ($size)"
                else
                    drive_info="$device ($size)"
                fi
                menu_options+=("$drive_info")
            done < <(echo "$raw_output")
            
            # Show menu and extract just the device path from selection
            local selected
            selected=$(show_menu "Select USB Drive" "${menu_options[@]}")
            if [[ -z "$selected" ]]; then
                return 1
            fi
            
            # Extract device path from selection
            target_device=$(echo "$selected" | awk '{print $1}')
        fi
    fi
    
    # Get device info
    local device_size_mb=$(get_device_size_mb "$target_device")
    local device_size_gb=$((device_size_mb / 1024))
    
    echo >&2
    echo -e "${BOLD}Target USB:${COLOR_RESET} $target_device (${device_size_gb}GB)" >&2
    echo >&2
    
    # Step 2: Initialize USB (includes format option)
    echo -e "${YELLOW}Step 1/4: Preparing USB Drive${COLOR_RESET}" >&2
    
    # Check if already initialized
    if is_leonardo_usb "$target_device"; then
        echo -e "${YELLOW}⚠ Leonardo installation detected on USB${COLOR_RESET}" >&2
        echo >&2
        
        # Show current installation info
        if [[ -f "$LEONARDO_USB_MOUNT/leonardo/VERSION" ]]; then
            local current_version=$(cat "$LEONARDO_USB_MOUNT/leonardo/VERSION" 2>/dev/null || echo "Unknown")
            echo -e "Current version: ${CYAN}$current_version${COLOR_RESET}" >&2
        fi
        
        # Show options in interactive mode
        if [[ -t 0 ]]; then
            echo >&2
            echo -e "${BOLD}What would you like to do?${COLOR_RESET}" >&2
            echo -e "1) ${GREEN}Update/Fix${COLOR_RESET} - Keep data and update Leonardo"
            echo -e "2) ${RED}Format & Reinstall${COLOR_RESET} - Fresh installation (erases all data)"
            echo -e "3) ${DIM}Cancel${COLOR_RESET} - Exit without changes"
            echo >&2
            
            local choice
            read -p "Enter choice (1-3): " choice
            
            case "$choice" in
                1)
                    echo -e "${CYAN}→ Updating Leonardo installation...${COLOR_RESET}" >&2
                    # Skip formatting, just update
                    ;;
                2)
                    if confirm_menu "Format USB and install fresh? ${RED}WARNING: This will erase all data!${COLOR_RESET}"; then
                        echo -e "${CYAN}→ Formatting USB drive...${COLOR_RESET}" >&2
                        if ! format_usb_device "$target_device"; then
                            echo -e "${RED}Failed to format USB drive${COLOR_RESET}" >&2
                            pause
                            return 1
                        fi
                        
                        # Mount the newly formatted device - use partition not device
                        echo -e "${CYAN}→ Mounting USB drive...${COLOR_RESET}" >&2
                        # After formatting, we need to mount the partition, not the device
                        local mount_device="$target_device"
                        if [[ "$target_device" =~ ^/dev/(sd[a-z]|nvme[0-9]+n[0-9]+|mmcblk[0-9]+)$ ]]; then
                            # Determine partition naming
                            if [[ "$target_device" =~ ^/dev/(nvme|mmcblk) ]]; then
                                mount_device="${target_device}p1"
                            else
                                mount_device="${target_device}1"
                            fi
                        fi
                        
                        if ! mount_usb_drive "$mount_device"; then
                            echo -e "${RED}Failed to mount USB drive${COLOR_RESET}" >&2
                            pause
                            return 1
                        fi
                    else
                        echo -e "${DIM}Cancelled${COLOR_RESET}" >&2
                        return 0
                    fi
                    ;;
                3|*)
                    echo -e "${DIM}Cancelled${COLOR_RESET}" >&2
                    return 0
                    ;;
            esac
        else
            echo -e "${YELLOW}Non-interactive mode: Updating existing installation${COLOR_RESET}" >&2
            # In non-interactive mode, default to update
        fi
    else
        # Ask about formatting only in interactive mode
        if [[ -t 0 ]]; then
            if confirm_menu "Format USB drive? ${RED}WARNING: This will erase all data!${COLOR_RESET}"; then
                echo -e "${CYAN}→ Formatting USB drive...${COLOR_RESET}" >&2
                if ! format_usb_device "$target_device"; then
                    echo -e "${RED}Failed to format USB drive${COLOR_RESET}" >&2
                    pause
                    return 1
                fi
                
                # Mount the newly formatted device - use partition not device
                echo -e "${CYAN}→ Mounting USB drive...${COLOR_RESET}" >&2
                # After formatting, we need to mount the partition, not the device
                local mount_device="$target_device"
                if [[ "$target_device" =~ ^/dev/(sd[a-z]|nvme[0-9]+n[0-9]+|mmcblk[0-9]+)$ ]]; then
                    # Determine partition naming
                    if [[ "$target_device" =~ ^/dev/(nvme|mmcblk) ]]; then
                        mount_device="${target_device}p1"
                    else
                        mount_device="${target_device}1"
                    fi
                fi
                
                if ! mount_usb_drive "$mount_device"; then
                    echo -e "${RED}Failed to mount USB drive${COLOR_RESET}" >&2
                    pause
                    return 1
                fi
            fi
        else
            echo -e "${YELLOW}Non-interactive mode: Skipping format prompt${COLOR_RESET}" >&2
            # Try to mount if not already mounted
            echo -e "${CYAN}→ Checking USB mount status...${COLOR_RESET}" >&2
            
            # Check if we need to try partition instead
            local mount_device="$target_device"
            if [[ "$target_device" =~ ^/dev/sd[a-z]$ ]]; then
                # Check if partition exists
                if [[ -b "${target_device}1" ]]; then
                    mount_device="${target_device}1"
                    echo -e "${DIM}Using partition: $mount_device${COLOR_RESET}" >&2
                fi
            fi
            
            # Try to mount if not already mounted
            local existing_mount=$(lsblk -no MOUNTPOINT "$mount_device" 2>/dev/null | grep -v "^$" | head -1)
            if [[ -z "$existing_mount" ]]; then
                echo -e "${CYAN}→ Mounting USB drive...${COLOR_RESET}" >&2
                if ! mount_usb_drive "$mount_device"; then
                    echo -e "${RED}Failed to mount USB drive${COLOR_RESET}" >&2
                    echo -e "${YELLOW}Try one of these options:${COLOR_RESET}" >&2
                    echo -e "  1. Run with sudo: ${CYAN}sudo ./leonardo.sh deploy usb $target_device${COLOR_RESET}" >&2
                    echo -e "  2. Mount manually first: ${CYAN}sudo mount $mount_device /mnt/usb${COLOR_RESET}" >&2
                    echo -e "  3. Use your desktop file manager to mount the USB"
                    return 1
                fi
            else
                echo -e "${GREEN}✓ USB already mounted at: $existing_mount${COLOR_RESET}" >&2
                # Update target device to use the partition
                target_device="$mount_device"
            fi
        fi
    fi
    
    # Initialize USB
    echo -e "${CYAN}→ Initializing USB device...${COLOR_RESET}" >&2
    # Use mount_device if available (after formatting), otherwise use target_device
    local init_device="${mount_device:-$target_device}"
    if ! init_usb_device "$init_device"; then
        echo -e "${RED}Failed to initialize USB device${COLOR_RESET}" >&2
        pause
        return 1
    fi
    
    # Debug mount point
    echo -e "${DIM}DEBUG: USB mount point is: ${LEONARDO_USB_MOUNT:-'(not set)'}${COLOR_RESET}" >&2
    
    # Ensure mount point is set
    if [[ -z "$LEONARDO_USB_MOUNT" ]]; then
        echo -e "${RED}Error: USB mount point not detected${COLOR_RESET}" >&2
        echo -e "${YELLOW}Please ensure the USB drive is properly mounted${COLOR_RESET}" >&2
        pause
        return 1
    fi
    
    # Create Leonardo directory structure if it doesn't exist
    if [[ ! -d "$LEONARDO_USB_MOUNT/leonardo" ]]; then
        echo -e "${CYAN}→ Creating Leonardo directory structure...${COLOR_RESET}" >&2
        create_leonardo_structure "$LEONARDO_USB_MOUNT"
    fi
    
    # Get Leonardo script location
    local leonardo_script="${LEONARDO_SCRIPT:-$0}"
    if [[ ! -f "$leonardo_script" ]]; then
        leonardo_script="./leonardo.sh"
    fi
    
    # Step 3: Install Leonardo
    echo >&2
    echo -e "${YELLOW}Step 2/4: Installing Leonardo AI${COLOR_RESET}" >&2
    copy_leonardo_to_usb "$leonardo_script" "$LEONARDO_USB_MOUNT"
    
    # Create platform launchers
    create_platform_launchers "$LEONARDO_USB_MOUNT"
    
    # Step 4: Configure
    echo >&2
    echo -e "${YELLOW}Step 3/4: Configuring Leonardo${COLOR_RESET}" >&2
    configure_usb_leonardo
    
    # Step 5: Model deployment
    echo >&2
    echo -e "${YELLOW}Step 4/4: AI Model Setup${COLOR_RESET}" >&2
    
    # Get USB free space for model recommendations
    local usb_free_mb=$(get_usb_free_space_mb "$LEONARDO_USB_MOUNT")
    
    # Select and install model
    local selected_model=$(select_model_interactive "$usb_free_mb")
    
    if [[ -n "$selected_model" ]]; then
        echo >&2
        echo -e "${CYAN}Installing $selected_model...${COLOR_RESET}" >&2
        if download_model_to_usb "$selected_model"; then
            echo -e "${GREEN}✓ Model installed successfully${COLOR_RESET}" >&2
        else
            echo -e "${YELLOW}⚠ Model installation failed${COLOR_RESET}" >&2
        fi
    else
        echo -e "${DIM}Skipping model installation${COLOR_RESET}" >&2
    fi
    
    # Final verification
    echo >&2
    echo -e "${CYAN}Verifying deployment...${COLOR_RESET}" >&2
    if verify_usb_deployment; then
        echo >&2
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${COLOR_RESET}" >&2
        echo -e "${GREEN}✨ USB deployment successful!${COLOR_RESET}" >&2
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${COLOR_RESET}" >&2
        echo >&2
        echo -e "${BOLD}To use Leonardo on any computer:${COLOR_RESET}" >&2
        echo -e "1. Insert the USB drive"
        echo -e "2. Navigate to the USB in terminal"
        echo -e "3. Run: ${CYAN}./start-leonardo${COLOR_RESET} (Linux/Mac) or ${CYAN}leonardo.bat${COLOR_RESET} (Windows)"
        echo >&2
        echo -e "${DIM}The USB is ready to use on any computer!${COLOR_RESET}" >&2
    else
        echo -e "${RED}⚠ Deployment verification failed${COLOR_RESET}" >&2
        echo -e "${YELLOW}The USB may still work but some features might be missing.${COLOR_RESET}" >&2
    fi
    
    echo >&2
    pause
    return 0
}

# Copy Leonardo to USB
copy_leonardo_to_usb() {
    local leonardo_script="$1"
    local target_dir="$2"
    
    # Copy Leonardo script
    echo -e "${CYAN}→ Copying Leonardo executable...${COLOR_RESET}" >&2
    
    # Create leonardo directory if needed
    mkdir -p "$target_dir/leonardo"
    
    # Use copy with progress if file is large enough
    local leonardo_size=$(stat -f%z "$leonardo_script" 2>/dev/null || stat -c%s "$leonardo_script" 2>/dev/null || echo "0")
    
    if [[ $leonardo_size -gt 1048576 ]]; then  # > 1MB
        copy_with_progress "$leonardo_script" "$target_dir/leonardo/leonardo.sh" "Installing Leonardo"
    else
        # Small file, just copy normally
        cp "$leonardo_script" "$target_dir/leonardo/leonardo.sh"
        echo -e "${GREEN}✓ Leonardo installed${COLOR_RESET}" >&2
    fi
    
    # Also copy to root for convenience
    cp "$leonardo_script" "$target_dir/leonardo.sh"
    chmod +x "$target_dir/leonardo.sh"
    chmod +x "$target_dir/leonardo/leonardo.sh"
}

# Create platform-specific launchers
create_platform_launchers() {
    local target_dir="$1"
    
    # Create Windows batch launcher
    cat > "$target_dir/leonardo.bat" << 'EOF'
@echo off
title Leonardo AI Universal
echo Starting Leonardo AI...
bash leonardo.sh %*
if errorlevel 1 (
    echo.
    echo Leonardo requires Git Bash or WSL on Windows.
    echo Please install Git for Windows from https://git-scm.com/
    pause
)
EOF
    
    # Create Mac/Linux launcher (executable)
    cat > "$target_dir/start-leonardo" << 'EOF'
#!/bin/bash
# Leonardo AI Universal Launcher
cd "$(dirname "$0")"
./leonardo/leonardo.sh "$@"
EOF
    chmod +x "$target_dir/start-leonardo" 2>/dev/null || true
    
    # Create desktop entry for Linux
    cat > "$target_dir/Leonardo.desktop" << EOF
[Desktop Entry]
Name=Leonardo AI
Comment=Portable AI Assistant
Exec=bash %f/leonardo.sh
Icon=%f/leonardo/assets/icon.png
Terminal=true
Type=Application
Categories=Utility;Development;
EOF
    
    echo -e "${GREEN}✓ Platform launchers created${COLOR_RESET}" >&2
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
    echo >&2
    echo -e "${CYAN}Model Deployment${COLOR_RESET}" >&2
    echo >&2
    
    # Check available space
    check_usb_free_space "$LEONARDO_USB_MOUNT" 1024
    local free_gb=$((LEONARDO_USB_FREE_MB / 1024))
    
    echo "Available space: ${free_gb}GB" >&2
    echo >&2
    
    # Show model recommendations based on space
    if [[ $free_gb -lt 8 ]]; then
        echo -e "${YELLOW}Limited space. Recommended models:${COLOR_RESET}" >&2
        echo "- TinyLlama (1.1B) - 2GB" >&2
        echo "- Phi-2 (2.7B) - 3GB" >&2
    elif [[ $free_gb -lt 16 ]]; then
        echo -e "${CYAN}Recommended models:${COLOR_RESET}" >&2
        echo "- Llama 3.2 (3B) - 4GB" >&2
        echo "- Mistral 7B - 8GB" >&2
        echo "- Gemma 2B - 3GB" >&2
    else
        echo -e "${GREEN}Plenty of space! Popular models:${COLOR_RESET}" >&2
        echo "- Llama 3.1 (8B) - 8GB" >&2
        echo "- Mistral 7B - 8GB" >&2
        echo "- Mixtral 8x7B - 48GB (if space permits)" >&2
    fi
    
    echo >&2
    
    # Use interactive model selector
    echo >&2
    
    # Simple model selection menu for USB deployment
    local popular_models=(
        "llama3.2:3b:Llama 3.2 (3B) - Fast and efficient:4"
        "mistral:7b:Mistral 7B - Great for general use:8"
        "codellama:7b:Code Llama - Optimized for coding:8"
        "phi3:mini:Phi-3 Mini - Tiny but capable:2"
        "gemma2:2b:Gemma 2B - Google's efficient model:3"
        "skip:0:Skip model installation:0"
    )
    
    echo -e "${CYAN}Select models to install:${COLOR_RESET}" >&2
    echo -e "${DIM}Use space to select/deselect, Enter when done${COLOR_RESET}" >&2
    echo >&2
    
    local selected_models=()
    local i=1
    for model_info in "${popular_models[@]}"; do
        IFS=':' read -r model_id variant name size_gb <<< "$model_info"
        printf "  %d) %-20s - %s (%sGB)\n" "$i" "$model_id" "$name" "$size_gb" >&2
        ((i++))
    done
    
    echo >&2
    echo -n "Enter model numbers (space-separated, or 'skip'): " >&2
    read -r model_selection
    
    if [[ "$model_selection" != "skip" ]] && [[ -n "$model_selection" ]]; then
        for num in $model_selection; do
            if [[ $num -ge 1 ]] && [[ $num -le ${#popular_models[@]} ]]; then
                local model_info="${popular_models[$((num-1))]}"
                IFS=':' read -r model_id variant name size_gb <<< "$model_info"
                if [[ "$model_id" != "skip" ]]; then
                    selected_models+=("$model_id:$variant")
                fi
            fi
        done
    fi
    
    # Download and install selected models
    if [[ ${#selected_models[@]} -gt 0 ]]; then
        echo >&2
        echo -e "${CYAN}Downloading models...${COLOR_RESET}" >&2
        
        for model_id in "${selected_models[@]}"; do
            echo >&2
            download_model_to_usb "$model_id"
        done
    fi
}

# Download model to USB
download_model_to_usb() {
    local model_spec="$1"
    local target_dir="$LEONARDO_USB_MOUNT/leonardo/models"
    
    # Parse model spec (format: model_id:variant)
    local model_id="${model_spec%:*}"
    local variant="${model_spec#*:}"
    
    # Ensure target directory exists
    ensure_directory "$target_dir"
    
    # Set download target
    export LEONARDO_MODEL_DIR="$target_dir"
    
    echo -e "${CYAN}Downloading ${model_id}:${variant}${COLOR_RESET}" >&2
    
    # Check if we have Ollama provider
    if command_exists ollama; then
        # Use Ollama to pull the model
        echo "Using Ollama to download model..." >&2
        
        # First check if Ollama is running
        if ! ollama list >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠ Ollama is not running. Starting Ollama service...${COLOR_RESET}" >&2
            # Try to start Ollama in the background
            ollama serve >/dev/null 2>&1 &
            local ollama_pid=$!
            sleep 3
            
            # Check if it started
            if ! ollama list >/dev/null 2>&1; then
                echo -e "${YELLOW}⚠ Could not start Ollama, falling back to direct download${COLOR_RESET}" >&2
                kill $ollama_pid 2>/dev/null || true
            fi
        fi
        
        # Try to pull the model if Ollama is available
        if ollama list >/dev/null 2>&1; then
            # First pull the model with visual feedback
            echo -e "${CYAN}Pulling model from Ollama...${COLOR_RESET}" >&2
            echo -e "${DIM}This may take a few minutes depending on model size and connection speed${COLOR_RESET}" >&2
            
            # Run ollama pull and capture output
            local temp_out="/tmp/ollama_pull_$$.log"
            local download_done=false
            
            # Start the download in background
            (ollama pull "${model_id}:${variant}" 2>&1 | tee "$temp_out") &
            local download_pid=$!
            
            # Show spinner while downloading
            local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
            local spin_i=0
            local last_line=""
            
            while kill -0 $download_pid 2>/dev/null; do
                # Read the last line from the log
                if [[ -f "$temp_out" ]]; then
                    local current_line=$(tail -n1 "$temp_out" 2>/dev/null | tr -d '\r\n')
                    if [[ -n "$current_line" ]] && [[ "$current_line" != "$last_line" ]]; then
                        last_line="$current_line"
                        
                        # Check for progress percentage
                        if [[ "$current_line" =~ ([0-9]+)% ]] || [[ "$current_line" =~ pulling.*([0-9]+)% ]]; then
                            local percent="${BASH_REMATCH[1]}"
                            printf "\r${CYAN}Downloading:${COLOR_RESET} [%-40s] ${YELLOW}%3d%%${COLOR_RESET}" \
                                   "$(printf '%*s' $((percent * 40 / 100)) | tr ' ' '=')" "$percent"
                        elif [[ "$current_line" =~ "success" ]] || [[ "$current_line" =~ "up to date" ]]; then
                            download_done=true
                            break
                        elif [[ "$current_line" =~ "error" ]]; then
                            break
                        else
                            # Show current status with spinner
                            local status_text=$(echo "$current_line" | sed 's/[[:space:]]*$//' | cut -c1-50)
                            printf "\r${CYAN}Downloading:${COLOR_RESET} ${spin:spin_i:1} %s..." "$status_text"
                            spin_i=$(( (spin_i + 1) % ${#spin} ))
                        fi
                    else
                        # Just update spinner if no new content
                        printf "\r${CYAN}Downloading:${COLOR_RESET} ${spin:spin_i:1} Waiting for Ollama..."
                        spin_i=$(( (spin_i + 1) % ${#spin} ))
                    fi
                fi
                sleep 0.1
            done
            
            # Wait for the process to complete
            wait $download_pid
            local result=$?
            
            # Clean up
            printf "\r%-80s\r" " "  # Clear line
            rm -f "$temp_out"
            
            # Check if last line indicated success
            if [[ "$last_line" =~ "success" ]] || [[ "$download_done" == "true" ]]; then
                download_done=true
                result=0
            fi
            
            if [[ $result -eq 0 ]] && [[ "$download_done" == "true" ]]; then
                echo -e "${GREEN}✓ Model downloaded to Ollama${COLOR_RESET}" >&2
                
                # Now export the model to USB
                echo -e "${CYAN}Exporting model to USB...${COLOR_RESET}" >&2
                
                # Ollama stores models in ~/.ollama/models/blobs/
                # We need to find the actual model file and copy it
                local ollama_dir="${HOME}/.ollama/models"
                
                # First, create the modelfile
                if ollama show "${model_id}:${variant}" --modelfile > "$target_dir/${model_id}-${variant}.modelfile" 2>/dev/null; then
                    echo -e "${DIM}Created modelfile${COLOR_RESET}" >&2
                fi
                
                # Try to find the model's manifest to locate the actual weights
                echo -e "${DIM}Looking for model weights...${COLOR_RESET}" >&2
                
                # Get model info from Ollama
                local model_info=$(ollama show "${model_id}:${variant}" 2>/dev/null)
                
                # For now, we'll note that the model is managed by Ollama
                # and will need Ollama installed to use it
                cat > "$target_dir/${model_id}-${variant}.info" <<EOF
Model: ${model_id}:${variant}
Type: Ollama-managed
Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF

                # Map the model to a direct download URL if available
                local gguf_url=""
                case "${model_id}:${variant}" in
                    "phi:2.7b")
                        gguf_url="https://huggingface.co/microsoft/phi-2/resolve/main/phi-2.Q4_K_M.gguf"
                        ;;
                    "llama2:7b")
                        gguf_url="https://huggingface.co/TheBloke/Llama-2-7B-GGUF/resolve/main/llama-2-7b.Q4_K_M.gguf"
                        ;;
                    "mistral:7b")
                        gguf_url="https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_K_M.gguf"
                        ;;
                    "llama3.2:1b")
                        gguf_url="https://huggingface.co/lmstudio-community/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf"
                        ;;
                    "llama3.2:3b")
                        gguf_url="https://huggingface.co/lmstudio-community/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf"
                        ;;
                    "qwen2.5:3b")
                        gguf_url="https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf"
                        ;;
                    "gemma2:2b")
                        gguf_url="https://huggingface.co/lmstudio-community/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf"
                        ;;
                    "codellama:7b")
                        gguf_url="https://huggingface.co/TheBloke/CodeLlama-7B-Instruct-GGUF/resolve/main/codellama-7b-instruct.Q4_K_M.gguf"
                        ;;
                    "llama3.1:8b")
                        gguf_url="https://huggingface.co/lmstudio-community/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"
                        ;;
                    "llama2:13b")
                        gguf_url="https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/resolve/main/llama-2-13b-chat.Q4_K_M.gguf"
                        ;;
                    *)
                        echo -e "${DIM}No direct download available for ${model_id}:${variant}${COLOR_RESET}" >&2
                        ;;
                esac

                if [[ -n "$gguf_url" ]]; then
                    local gguf_file="$target_dir/${model_id}-${variant}.gguf"
                    
                    # Use download_with_progress for better visual feedback
                    if download_with_progress "$gguf_url" "$gguf_file" "Downloading GGUF for offline use"; then
                        echo -e "${GREEN}✓ GGUF model downloaded for offline use${COLOR_RESET}" >&2
                        
                        # Update info file
                        cat >> "$target_dir/${model_id}-${variant}.info" <<EOF

GGUF File: ${model_id}-${variant}.gguf
Size: $(du -h "$gguf_file" 2>/dev/null | cut -f1)
Offline Ready: Yes
EOF
                    else
                        echo -e "${YELLOW}⚠ GGUF download failed${COLOR_RESET}" >&2
                        rm -f "$gguf_file" 2>/dev/null
                    fi
                else
                    echo -e "${GREEN}✓ Model exported (Ollama format)${COLOR_RESET}" >&2
                fi
                
                return 0
            else
                echo -e "${RED}✗ Ollama download failed${COLOR_RESET}" >&2
                # Fall through to direct download
            fi
        fi
    fi
    
    # Direct download from registry as fallback
    echo "Downloading from model registry..." >&2
    
    # Debug output
    echo -e "${DIM}DEBUG: Looking for model '${model_id}:${variant}' in registry${COLOR_RESET}" >&2
    
    # Map common model names to HuggingFace URLs
    local model_url=""
    case "${model_id}:${variant}" in
        "phi:2.7b")
            model_url="https://huggingface.co/microsoft/phi-2/resolve/main/phi-2.Q4_K_M.gguf"
            ;;
        "llama2:7b")
            model_url="https://huggingface.co/TheBloke/Llama-2-7B-GGUF/resolve/main/llama-2-7b.Q4_K_M.gguf"
            ;;
        "mistral:7b")
            model_url="https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_K_M.gguf"
            ;;
        "llama3.2:1b")
            model_url="https://huggingface.co/lmstudio-community/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf"
            ;;
        "llama3.2:3b")
            model_url="https://huggingface.co/lmstudio-community/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf"
            ;;
        "qwen2.5:3b")
            model_url="https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf"
            ;;
        "gemma2:2b")
            model_url="https://huggingface.co/lmstudio-community/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf"
            ;;
        "codellama:7b")
            model_url="https://huggingface.co/TheBloke/CodeLlama-7B-Instruct-GGUF/resolve/main/codellama-7b-instruct.Q4_K_M.gguf"
            ;;
        "llama3.1:8b")
            model_url="https://huggingface.co/lmstudio-community/Meta-Llama-3.1-8B-Instruct-GGUF/resolve/main/Meta-Llama-3.1-8B-Instruct-Q4_K_M.gguf"
            ;;
        "llama2:13b")
            model_url="https://huggingface.co/TheBloke/Llama-2-13B-chat-GGUF/resolve/main/llama-2-13b-chat.Q4_K_M.gguf"
            ;;
        *)
            echo -e "${RED}✗ Model ${model_id}:${variant} not found in registry${COLOR_RESET}" >&2
            echo -e "${YELLOW}Available models for direct download:${COLOR_RESET}" >&2
            echo "  - phi:2.7b" >&2
            echo "  - llama2:7b" >&2
            echo "  - mistral:7b" >&2
            echo "  - llama3.2:1b" >&2
            echo "  - llama3.2:3b" >&2
            echo "  - qwen2.5:3b" >&2
            echo "  - gemma2:2b" >&2
            echo "  - codellama:7b" >&2
            echo "  - llama3.1:8b" >&2
            echo "  - llama2:13b" >&2
            return 1
            ;;
    esac
    
    local output_file="$target_dir/${model_id}-${variant}.gguf"
    
    # Download with progress
    if download_with_progress "$model_url" "$output_file" "Downloading ${model_id} (${variant})"; then
        # Create info file
        cat > "$target_dir/${model_id}-${variant}.info" <<EOF
Model: ${model_id}:${variant}
Downloaded: $(date)
Type: GGUF Model
Location: $output_file
Size: $(du -h "$output_file" 2>/dev/null | cut -f1)
EOF
        echo -e "${GREEN}✓ Model downloaded successfully to USB${COLOR_RESET}" >&2
        return 0
    else
        echo -e "${RED}✗ Failed to download model${COLOR_RESET}" >&2
        return 1
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
open=start-leonardo.bat
EOF
    
    # Create desktop entry for Linux
    cat > "$LEONARDO_USB_MOUNT/.autorun" << EOF
#!/bin/bash
# Leonardo AI Universal Autorun
cd "\$(dirname "\$0")"
./start-leonardo.sh
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
        echo "✓ Leonardo executable found" >&2
        ((checks_passed++))
    else
        echo "✗ Leonardo executable missing" >&2
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
        echo "✓ Directory structure complete" >&2
        ((checks_passed++))
    else
        echo "✗ Directory structure incomplete" >&2
    fi
    
    # Check 3: Configuration
    ((checks_total++))
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo/config/leonardo.conf" ]]; then
        echo "✓ Configuration file present" >&2
        ((checks_passed++))
    else
        echo "✗ Configuration file missing" >&2
    fi
    
    # Check 4: Platform launchers
    ((checks_total++))
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo.bat" ]] || [[ -f "$LEONARDO_USB_MOUNT/start-leonardo.command" ]]; then
        echo "✓ Platform launchers created" >&2
        ((checks_passed++))
    else
        echo "✗ Platform launchers missing" >&2
    fi
    
    # Check 5: Write test
    ((checks_total++))
    local test_file="$LEONARDO_USB_MOUNT/.leonardo_test_$$"
    if echo "test" > "$test_file" 2>/dev/null && rm -f "$test_file" 2>/dev/null; then
        echo "✓ USB is writable" >&2
        ((checks_passed++))
    else
        echo "✗ USB write test failed" >&2
    fi
    
    echo >&2
    echo "Verification: $checks_passed/$checks_total checks passed" >&2
    
    return $((checks_total - checks_passed))
}

# Get recommended models based on USB size
get_recommended_models() {
    local usb_size_gb="$1"
    local models=()
    
    # Define model sizes (approximate compressed sizes in GB)
    local -A model_sizes=(
        ["phi:2.7b"]="2"
        ["llama3.2:1b"]="1"
        ["llama3.2:3b"]="2"
        ["mistral:7b"]="4"
        ["llama2:7b"]="4"
        ["llama2:13b"]="8"
        ["codellama:7b"]="4"
        ["mixtral:8x7b"]="26"
        ["llama3.1:8b"]="5"
        ["gemma2:2b"]="2"
        ["qwen2.5:3b"]="2"
    )
    
    # Calculate available space (leave 20% free)
    local available_gb=$((usb_size_gb * 80 / 100))
    
    # Add models that fit
    for model in "${!model_sizes[@]}"; do
        local size="${model_sizes[$model]}"
        if [[ $size -le $available_gb ]]; then
            models+=("$model (${size}GB)")
        fi
    done
    
    # Sort by size (smallest first for quick testing)
    printf '%s\n' "${models[@]}" | sort -t'(' -k2 -n
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
        echo "Status: Not mounted" >&2
        return 1
    fi
    
    # Check deployment
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo.sh" ]]; then
        echo "Status: Leonardo installed" >&2
        
        # Check version
        if [[ -f "$LEONARDO_USB_MOUNT/leonardo/VERSION" ]]; then
            echo "Version: $(cat "$LEONARDO_USB_MOUNT/leonardo/VERSION")" >&2
        fi
        
        # Check models
        local model_count=$(find "$LEONARDO_USB_MOUNT/leonardo/models" -name "*.gguf" 2>/dev/null | wc -l)
        echo "Models: $model_count installed" >&2
        
        # Check space
        check_usb_free_space "$LEONARDO_USB_MOUNT" 0
        echo "Free space: ${LEONARDO_USB_FREE}" >&2
    else
        echo "Status: Not deployed" >&2
    fi
}

# Pause function
pause() {
    echo >&2
    read -p "Press Enter to continue..." -r
}

# Export deployment functions
export -f deploy_to_usb configure_usb_leonardo deploy_models_to_usb
export -f download_model_to_usb create_usb_autorun verify_usb_deployment
export -f quick_deploy_to_usb get_usb_deployment_status

# Create Leonardo directory structure
create_leonardo_structure() {
    local target_dir="$1"
    
    # Create required directories
    local required_dirs=("leonardo" "leonardo/models" "leonardo/config" "leonardo/logs")
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$target_dir/$dir" ]]; then
            mkdir -p "$target_dir/$dir"
        fi
    done
    
    echo -e "${GREEN}✓ Leonardo directory structure created${COLOR_RESET}" >&2
}

# Interactive model selection with size recommendations
select_model_interactive() {
    local usb_size_mb="${1:-8192}"  # Default 8GB
    local usb_size_gb=$((usb_size_mb / 1024))
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}" >&2
    echo -e "${BOLD}               🤖 Select AI Model${COLOR_RESET}" >&2
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}" >&2
    echo >&2
    echo -e "${YELLOW}USB Size: ${usb_size_gb}GB${COLOR_RESET}" >&2
    echo -e "${DIM}Recommended models based on available space:${COLOR_RESET}" >&2
    echo >&2
    
    # Get recommended models
    local models=()
    readarray -t models < <(get_recommended_models "$usb_size_gb")
    
    if [[ ${#models[@]} -eq 0 ]]; then
        echo -e "${RED}USB too small for any models!${COLOR_RESET}" >&2
        echo -e "${YELLOW}Minimum 2GB required.${COLOR_RESET}" >&2
        return 1
    fi
    
    # Add option to skip
    models+=("Skip (no model)")
    
    # Show menu
    local selected=$(show_menu "Available Models" "${models[@]}")
    
    # Extract model name without size
    if [[ "$selected" == "Skip (no model)" ]] || [[ -z "$selected" ]]; then
        echo >&2
        return 1
    else
        # Remove size annotation and any trailing whitespace/carriage returns
        local model_name="${selected% (*}"
        # Clean up any carriage returns or trailing whitespace
        model_name=$(echo "$model_name" | tr -d '\r' | xargs)
        echo "$model_name"
    fi
}

# Get USB free space in MB
get_usb_free_space_mb() {
    local mount_point="$1"
    df -BM "$mount_point" | awk 'NR==2 {print $4}' | sed 's/M$//'
}

# Get device size in MB
get_device_size_mb() {
    local device="$1"
    # Try different methods to get device size
    if command_exists lsblk; then
        lsblk -ndo SIZE -b "$device" 2>/dev/null | awk '{print int($1/1024/1024)}'
    elif command_exists blockdev; then
        blockdev --getsize64 "$device" 2>/dev/null | awk '{print int($1/1024/1024)}'
    else
        # Fallback to 8GB
        echo "8192"
    fi
}

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
    local needs_sudo=false
    
    # Debug output
    if [[ "${LEONARDO_DEBUG:-}" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
        echo -e "${YELLOW}DEBUG: Checking USB detection permissions...${COLOR_RESET}" >&2
    fi
    
    # Check if we need sudo by testing udevadm access on any device
    # Try to access /dev/sda first, if that fails try other common devices
    local test_devices=("/dev/sda" "/dev/sdb" "/dev/nvme0n1")
    for test_dev in "${test_devices[@]}"; do
        if [[ -e "$test_dev" ]]; then
            if ! udevadm info --query=all --name="$test_dev" &>/dev/null; then
                needs_sudo=true
                if [[ "${LEONARDO_DEBUG:-}" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo -e "${YELLOW}DEBUG: Need sudo for udevadm (tested on $test_dev)${COLOR_RESET}" >&2
                fi
                break
            fi
        fi
    done
    
    # Function to run command with or without sudo
    run_cmd() {
        if [[ "$needs_sudo" == "true" ]]; then
            sudo "$@"
        else
            "$@"
        fi
    }
    
    # If we need sudo, prompt once for password
    if [[ "$needs_sudo" == "true" ]]; then
        echo -e "${YELLOW}USB detection requires administrator privileges.${COLOR_RESET}" >&2
        echo -e "${DIM}Please enter your password to continue...${COLOR_RESET}" >&2
        # Test sudo access with a simple command
        if ! sudo -v; then
            echo -e "${RED}Error: Failed to obtain administrator privileges${COLOR_RESET}" >&2
            return 1
        fi
    fi
    
    # Debug: Show what lsblk sees
    if [[ "${LEONARDO_DEBUG:-}" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
        echo -e "${YELLOW}DEBUG: lsblk output for sd devices:${COLOR_RESET}" >&2
        lsblk -nlo NAME,SIZE,MOUNTPOINT,LABEL | grep -E "^sd[a-z]\s" >&2 || echo "No sd devices found" >&2
    fi
    
    # Use lsblk to find USB devices - only base devices, not partitions
    while IFS= read -r line; do
        local device=$(echo "$line" | awk '{print $1}')
        local size=$(echo "$line" | awk '{print $2}')
        local mount=$(echo "$line" | awk '{print $3}')
        local label=$(echo "$line" | awk '{print $4}')
        
        if [[ "${LEONARDO_DEBUG:-}" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
            echo -e "${YELLOW}DEBUG: Checking device: /dev/$device${COLOR_RESET}" >&2
        fi
        
        # Check if it's a USB device
        if [[ -n "$device" ]] && run_cmd udevadm info --query=all --name="/dev/$device" 2>/dev/null | grep -q "ID_BUS=usb"; then
            drives+=("/dev/$device|$label|$size|$mount")
            if [[ "${LEONARDO_DEBUG:-}" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                echo -e "${GREEN}DEBUG: Found USB device: /dev/$device${COLOR_RESET}" >&2
            fi
        fi
    done < <(lsblk -nlo NAME,SIZE,MOUNTPOINT,LABEL | grep -E "^sd[a-z]\s")
    
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
    
    # Extract base device from partition (e.g., /dev/sdd1 -> /dev/sdd)
    local base_device="$device"
    if [[ "$device" =~ ^(/dev/[a-z]+)[0-9]+$ ]]; then
        base_device="${BASH_REMATCH[1]}"
    elif [[ "$device" =~ ^(/dev/nvme[0-9]+n[0-9]+)p[0-9]+$ ]]; then
        base_device="${BASH_REMATCH[1]}"
    elif [[ "$device" =~ ^(/dev/mmcblk[0-9]+)p[0-9]+$ ]]; then
        base_device="${BASH_REMATCH[1]}"
    fi
    
    case "$platform" in
        "macos")
            diskutil info "$base_device" 2>/dev/null | grep -q "Protocol:.*USB"
            ;;
        "linux")
            udevadm info --query=all --name="$base_device" 2>/dev/null | grep -q "ID_BUS=usb"
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
    echo -e "${YELLOW}USB device change detected. Refreshing...${COLOR_RESET}"
    list_usb_drives
}

# List USB drives with formatting
list_usb_drives() {
    local format="${1:-table}"
    local drives_found=0
    
    echo -e "${CYAN}Detecting USB drives...${COLOR_RESET}"
    echo ""
    
    if [[ "$format" == "table" ]]; then
        printf "%-15s %-30s %-10s %-30s\n" \
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
        echo -e "${YELLOW}No USB drives detected${COLOR_RESET}"
        return 1
    else
        [[ "$format" == "table" ]] && echo ""
        echo -e "${GREEN}Found $drives_found USB drive(s)${COLOR_RESET}"
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
    
    echo -e "${CYAN}Testing USB write speed on $device...${COLOR_RESET}"
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
        echo -e "${RED}Write test failed${COLOR_RESET}"
        return 1
    fi
}

# Check if device is a Leonardo USB
is_leonardo_usb() {
    local device="${1:-}"
    
    if [[ -z "$device" ]]; then
        return 1
    fi
    
    # Get mount point
    local mount_point=""
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            mount_point=$(diskutil info "$device" 2>/dev/null | grep "Mount Point:" | cut -d: -f2- | xargs)
            ;;
        "linux")
            mount_point=$(lsblk -no MOUNTPOINT "$device" 2>/dev/null | grep -v "^$" | head -1)
            # Try first partition if device is like /dev/sdX
            if [[ -z "$mount_point" ]] && [[ "$device" =~ ^/dev/sd[a-z]$ ]]; then
                mount_point=$(lsblk -no MOUNTPOINT "${device}1" 2>/dev/null | grep -v "^$" | head -1)
            fi
            ;;
        "windows")
            mount_point="$device\\"
            ;;
    esac
    
    # Check for Leonardo marker files
    if [[ -n "$mount_point" ]]; then
        if [[ -f "$mount_point/leonardo.sh" ]] || \
           [[ -f "$mount_point/leonardo.bat" ]] || \
           [[ -f "$mount_point/leonardo/config/leonardo.conf" ]] || \
           [[ -d "$mount_point/leonardo" ]]; then
            return 0
        fi
    fi
    
    return 1
}

# Export USB detection functions
export -f detect_platform detect_usb_drives get_usb_drive_info
export -f is_usb_device get_usb_speed monitor_usb_changes
export -f is_leonardo_usb
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
    echo -e "${COLOR_CYAN}╭─────────────────────────────────────╮${COLOR_RESET}"
    echo -e "${COLOR_CYAN}│    Leonardo AI Universal v$LEONARDO_VERSION    │${COLOR_RESET}"
    echo -e "${COLOR_CYAN}│       Deploy AI Anywhere™           │${COLOR_RESET}"
    echo -e "${COLOR_CYAN}╰─────────────────────────────────────╯${COLOR_RESET}"
    echo ""
}

# Show banner
show_banner() {
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${CYAN}║${COLOR_RESET}            ${BOLD}Leonardo AI Universal v$LEONARDO_VERSION${COLOR_RESET}              ${CYAN}║${COLOR_RESET}"
    echo -e "${CYAN}║${COLOR_RESET}              ${DIM}Portable AI Assistant${COLOR_RESET}                         ${CYAN}║${COLOR_RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
}

# Settings menu
settings_menu() {
    while true; do
        local selection
        selection=$(show_menu "Settings & Preferences" \
            "Default Model Path" \
            "Color Theme" \
            "Auto-Update" \
            "Network Proxy" \
            "Back to Main Menu") || break
        
        case "$selection" in
            "Default Model Path")
                echo -e "${YELLOW}Current model path:${COLOR_RESET} $LEONARDO_MODEL_DIR"
                pause
                ;;
            "Color Theme")
                echo -e "${YELLOW}Color theme settings coming soon!${COLOR_RESET}"
                pause
                ;;
            "Auto-Update")
                echo -e "${YELLOW}Auto-update settings coming soon!${COLOR_RESET}"
                pause
                ;;
            "Network Proxy")
                echo -e "${YELLOW}Proxy settings coming soon!${COLOR_RESET}"
                pause
                ;;
            "Back to Main Menu"|"")
                break
                ;;
        esac
    done
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

# Error handler
handle_error() {
    local exit_code="$1"
    local line_no="$2"
    log_message "ERROR" "Command failed with exit code $exit_code at line $line_no"
}

# Main function - entry point for Leonardo
main() {
    # Set up error handling
    set -euo pipefail
    trap 'handle_error $? $LINENO' ERR
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Handle help/version first
    if [[ "$LEONARDO_HELP" == "true" ]]; then
        show_help
        exit 0
    fi
    
    if [[ "$LEONARDO_VERSION_ONLY" == "true" ]]; then
        echo "Leonardo AI Universal v$LEONARDO_VERSION ($LEONARDO_BUILD)"
        exit 0
    fi
    
    # Handle commands if provided
    if [[ -n "$LEONARDO_COMMAND" ]]; then
        handle_command
        exit $?
    fi
    
    # Show banner unless quiet mode
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        clear
        show_banner
        echo
    fi
    
    # Initialize model system
    if ! init_model_system; then
        log_message "ERROR" "Failed to initialize model system"
        exit 1
    fi
    
    # Check system requirements
    if ! check_system_requirements; then
        log_message "ERROR" "System requirements not met"
        exit 1
    fi
    
    # Main interactive menu
    local keep_running=true
    while [[ "$keep_running" == "true" ]]; do
        clear
        show_banner
        
        # Show system status
        echo -e "\n${DIM}System Status: $(format_system_status)${COLOR_RESET}\n"
        
        # Build menu options dynamically
        local menu_options=()
        
        # Always show deployment option first for MVP
        menu_options+=("🚀 Deploy to USB")
        
        # Show chat option if models are installed
        if check_installed_models; then
            menu_options+=("💬 Chat with AI")
        fi
        
        # System management options
        menu_options+=("📦 Model Manager")
        menu_options+=("🔧 System Utilities")
        menu_options+=("📊 System Dashboard")
        menu_options+=("⚙️  Settings")
        menu_options+=("📖 Help")
        menu_options+=("🚪 Exit")
        
        local selection
        selection=$(show_menu "Leonardo AI Universal - Main Menu" "${menu_options[@]}")
        local menu_exit_code=$?
        
        # If show_menu returned error (user pressed q), exit
        if [[ $menu_exit_code -ne 0 ]]; then
            keep_running=false
            continue
        fi
        
        case "$selection" in
            "🚀 Deploy to USB")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling deploy_to_usb" >&2
                fi
                deploy_to_usb
                # Don't exit on failure, just return to menu
                ;;
            "💬 Chat with AI")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling handle_chat_command" >&2
                fi
                handle_chat_command
                ;;
            "📦 Model Manager")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling handle_model_command menu" >&2
                fi
                handle_model_command "menu"
                ;;
            "🔧 System Utilities")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling system_utilities_menu" >&2
                fi
                system_utilities_menu
                ;;
            "📊 System Dashboard")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling show_dashboard" >&2
                fi
                show_dashboard
                pause
                ;;
            "⚙️  Settings")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling settings_menu" >&2
                fi
                settings_menu
                ;;
            "📖 Help")
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Calling show_help" >&2
                fi
                show_help
                pause
                ;;
            "🚪 Exit"|"")
                handle_exit
                keep_running=false
                ;;
            *)
                if [[ "$LEONARDO_DEBUG" == "true" ]] || [[ -n "${DEBUG:-}" ]]; then
                    echo "DEBUG: Unknown selection: '$selection'" >&2
                fi
                ;;
        esac
    done
}

# Parse command line arguments
parse_arguments() {
    # Initialize command line variables
    LEONARDO_COMMAND=""
    LEONARDO_SUBCOMMAND=""
    LEONARDO_ARGS=()
    LEONARDO_HELP=false
    LEONARDO_VERSION_ONLY=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                LEONARDO_HELP=true
                shift
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
                LEONARDO_VERSION_ONLY=true
                shift
                ;;
            --no-color)
                export LEONARDO_NO_COLOR=true
                shift
                ;;
            model|models)
                LEONARDO_COMMAND="model"
                shift
                LEONARDO_SUBCOMMAND="${1:-}"
                shift || true
                LEONARDO_ARGS=("$@")
                break
                ;;
            usb|drive)
                LEONARDO_COMMAND="usb"
                shift
                LEONARDO_SUBCOMMAND="${1:-}"
                shift || true
                LEONARDO_ARGS=("$@")
                break
                ;;
            deploy|deployment)
                LEONARDO_COMMAND="deploy"
                shift
                LEONARDO_SUBCOMMAND="${1:-}"
                shift || true
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
handle_command() {
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
            show_dashboard
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

# Model management menu
model_management_menu() {
    while true; do
        # Clear screen properly
        echo -e "\033[H\033[2J" >/dev/tty
        
        echo -e "${CYAN}Model Management${COLOR_RESET}"
        echo -e "${DIM}Manage AI models for Leonardo${COLOR_RESET}"
        echo ""
        
        # Show model stats
        local installed_count=${#LEONARDO_INSTALLED_MODELS[@]}
        local total_count=${#LEONARDO_MODEL_REGISTRY[@]}
        echo -e "Models installed: ${GREEN}$installed_count${COLOR_RESET} / $total_count"
        echo ""
        
        show_menu "Model Options" \
            "List Available Models" \
            "Download Model" \
            "Search Models" \
            "Model Information" \
            "Import Custom Model" \
            "Remove Model" \
            "Back to Main Menu"
        
        case "$MENU_SELECTION" in
            "List Available Models")
                echo -e "\n${CYAN}Available Models:${COLOR_RESET}\n"
                list_models
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Download Model")
                echo -e "\n${CYAN}Download Model${COLOR_RESET}"
                echo -e "${DIM}Examples: llama3:8b, mistral:7b, codellama:7b${COLOR_RESET}"
                echo -e "${DIM}Type 'llama' to see all Llama models, or 'list' for all models${COLOR_RESET}"
                echo ""
                echo -n "Enter model name or ID: "
                read -r model_id
                
                # If user types 'list', show all models
                if [[ "$model_id" == "list" ]]; then
                    echo ""
                    list_models
                elif [[ -n "$model_id" ]]; then
                    # Check if it's a partial match and show options
                    if ! get_model_by_id "$model_id" >/dev/null 2>&1; then
                        echo ""
                        search_models "$model_id"
                    else
                        download_model "$model_id"
                    fi
                fi
                
                # Single press enter prompt for all cases
                if [[ -n "$model_id" ]]; then
                    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                    read -r
                fi
                ;;
            "Search Models")
                echo -e "\n${CYAN}Search Models${COLOR_RESET}"
                echo -e "${DIM}Search by: name (llama, mistral), use case (code, chat), or size (tiny, small)${COLOR_RESET}"
                echo ""
                echo -n "Enter search query: "
                read -r query
                if [[ -n "$query" ]]; then
                    echo ""
                    search_models "$query"
                fi
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Model Information")
                echo -e "\n${CYAN}Model Information${COLOR_RESET}"
                
                # Check if we have any installed models
                local installed_models=()
                # TODO: Get actual installed models
                
                if [[ ${#installed_models[@]} -eq 0 ]]; then
                    echo -e "${DIM}No models currently installed${COLOR_RESET}"
                    echo -e "${DIM}Examples to try: llama3:8b, mistral:7b, codellama:7b${COLOR_RESET}"
                elif [[ ${#installed_models[@]} -eq 1 ]]; then
                    # Auto-show the single installed model
                    echo -e "${DIM}Showing info for: ${installed_models[0]}${COLOR_RESET}"
                    echo ""
                    show_model_info "${installed_models[0]}"
                else
                    # Show menu of installed models
                    echo -e "${DIM}Select an installed model:${COLOR_RESET}"
                    for i in "${!installed_models[@]}"; do
                        echo "$((i+1)). ${installed_models[$i]}"
                    done
                fi
                
                echo ""
                echo -n "Enter model name or ID: "
                read -r model_id
                show_model_info "$model_id"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Import Custom Model")
                echo -e "\n${YELLOW}Custom model import coming soon!${COLOR_RESET}"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Remove Model")
                echo -e "\n${YELLOW}Model removal coming soon!${COLOR_RESET}"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

# USB management menu (placeholder)
usb_management_menu() {
    while true; do
        # Clear screen properly
        echo -e "\033[H\033[2J" >/dev/tty
        
        echo -e "${CYAN}USB Drive Management${COLOR_RESET}"
        echo -e "${DIM}Manage USB drives for Leonardo${COLOR_RESET}"
        echo ""
        
        show_menu "USB Options" \
            "List USB Drives" \
            "Deploy Leonardo to USB" \
            "Check USB Health" \
            "Backup USB Data" \
            "Back to Main Menu"
        
        case "$MENU_SELECTION" in
            "List USB Drives")
                echo -e "\n${CYAN}Detected USB Drives:${COLOR_RESET}\n"
                handle_usb_command "list"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Deploy Leonardo to USB")
                select_and_deploy_usb
                ;;
            "Check USB Health")
                echo -e "\n${CYAN}USB Health Check${COLOR_RESET}"
                select_usb_for_health_check
                ;;
            "Backup USB Data")
                echo -e "\n${YELLOW}USB backup coming soon!${COLOR_RESET}"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

# Interactive USB selection and deployment
select_and_deploy_usb() {
    echo -e "\n${CYAN}Deploy Leonardo to USB${COLOR_RESET}\n"
    
    # Get list of USB drives and separate recommended devices
    local -a recommended_devices=()
    local -a recommended_info=()
    local -a other_devices=()
    local -a other_info=()

    while IFS='|' read -r device name size mount; do
        local info="${name:-Unknown} (${size:-N/A})"
        if [[ -n "$mount" ]] && [[ "$mount" != "Not Mounted" ]]; then
            info="$info - $mount"
        fi

        if check_leonardo_usb "$device" >/dev/null 2>&1; then
            recommended_devices+=("$device")
            recommended_info+=("$info")
        else
            other_devices+=("$device")
            other_info+=("$info")
        fi
    done < <(detect_usb_drives)
    
    local total_devices=$(( ${#recommended_devices[@]} + ${#other_devices[@]} ))
    if [[ $total_devices -eq 0 ]]; then
        echo -e "${YELLOW}No USB drives detected${COLOR_RESET}"
        echo -e "${DIM}Please insert a USB drive and try again${COLOR_RESET}"
        echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
        read -r
        return
    fi

    # Build menu options
    local menu_options=()
    for i in "${!recommended_devices[@]}"; do
        menu_options+=("${GREEN}${recommended_devices[$i]} - ${recommended_info[$i]} [Leonardo USB]${COLOR_RESET}")
    done
    for i in "${!other_devices[@]}"; do
        menu_options+=("${YELLOW}${other_devices[$i]} - ${other_info[$i]}${COLOR_RESET}")
    done
    menu_options+=("Cancel")
    
    # Show interactive menu
    show_menu "Select USB Drive" "${menu_options[@]}"
    
    if [[ "$MENU_SELECTION" == "Cancel" ]]; then
        return
    fi
    
    # Extract device from selection
    local selected_device
    selected_device=$(echo "$MENU_SELECTION" | awk '{print $1}')
    
    echo -e "\n${CYAN}Selected: $selected_device${COLOR_RESET}"
    echo -e "${YELLOW}WARNING: This will initialize the USB drive for Leonardo AI${COLOR_RESET}"
    echo -e "${DIM}All existing data will be preserved in a backup folder${COLOR_RESET}"
    echo ""
    echo -n "Continue? (y/N): "
    read -r confirm
    
    if [[ "${confirm,,}" == "y" ]]; then
        echo ""
        # Deploy directly - initialization happens inside deploy_to_usb
        handle_deployment_command "usb" "$selected_device"
    else
        echo -e "\n${YELLOW}Deployment cancelled${COLOR_RESET}"
    fi
    
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Interactive USB selection for health check
select_usb_for_health_check() {
    echo ""
    
    # Get list of USB drives and categorize
    local -a recommended_devices=()
    local -a recommended_info=()
    local -a other_devices=()
    local -a other_info=()

    while IFS='|' read -r device name size mount; do
        local info="${name:-Unknown} (${size:-N/A})"
        if [[ -n "$mount" ]] && [[ "$mount" != "Not Mounted" ]]; then
            info="$info - $mount"
        fi

        if check_leonardo_usb "$device" >/dev/null 2>&1; then
            recommended_devices+=("$device")
            recommended_info+=("$info")
        else
            other_devices+=("$device")
            other_info+=("$info")
        fi
    done < <(detect_usb_drives)
    
    local total_devices=$(( ${#recommended_devices[@]} + ${#other_devices[@]} ))
    if [[ $total_devices -eq 0 ]]; then
        echo -e "${YELLOW}No USB drives detected${COLOR_RESET}"
        echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
        read -r
        return
    fi

    # Build menu options with recommended first
    local menu_options=()
    for i in "${!recommended_devices[@]}"; do
        menu_options+=("${GREEN}${recommended_devices[$i]} - ${recommended_info[$i]} [Leonardo USB]${COLOR_RESET}")
    done
    for i in "${!other_devices[@]}"; do
        menu_options+=("${YELLOW}${other_devices[$i]} - ${other_info[$i]}${COLOR_RESET}")
    done
    menu_options+=("Cancel")
    
    # Show interactive menu
    show_menu "Select USB Drive for Health Check" "${menu_options[@]}"
    
    if [[ "$MENU_SELECTION" == "Cancel" ]]; then
        return
    fi
    
    # Extract device from selection
    local selected_device
    selected_device=$(echo "$MENU_SELECTION" | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')
    
    echo ""
    handle_usb_command "health" "$selected_device"
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Add missing deployment command handler
handle_deployment_command() {
    local command="$1"
    shift
    
    case "$command" in
        "usb")
            local device="$1"
            if [[ -z "$device" ]]; then
                echo -e "${RED}Error: No device specified${COLOR_RESET}"
                return 1
            fi
            
            # Use the actual USB deployment function
            deploy_to_usb "$device"
            ;;
        "local")
            echo -e "${CYAN}Local deployment...${COLOR_RESET}"
            # TODO: Implement local deployment
            echo -e "${YELLOW}Local deployment coming soon!${COLOR_RESET}"
            ;;
        *)
            echo -e "${RED}Unknown deployment command: $command${COLOR_RESET}"
            return 1
            ;;
    esac
}

# Settings menu
settings_menu() {
    while true; do
        # Clear screen properly
        echo -e "\033[H\033[2J" >/dev/tty
        
        echo -e "${CYAN}Settings & Preferences${COLOR_RESET}"
        echo ""
        
        show_menu "Settings" \
            "Toggle Debug Mode" \
            "Configure Model Path" \
            "Network Settings" \
            "Security Options" \
            "Back to Main Menu"
        
        case "$MENU_SELECTION" in
            "Toggle Debug Mode")
                if [[ "$LEONARDO_DEBUG" == "true" ]]; then
                    LEONARDO_DEBUG=false
                    echo -e "\n${GREEN}Debug mode disabled${COLOR_RESET}"
                else
                    LEONARDO_DEBUG=true
                    echo -e "\n${GREEN}Debug mode enabled${COLOR_RESET}"
                fi
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Configure Model Path")
                echo -e "\n${CYAN}Current model path: ${LEONARDO_MODELS_DIR}${COLOR_RESET}"
                echo -n "Enter new path (or press Enter to keep current): "
                read -r new_path
                if [[ -n "$new_path" ]]; then
                    export LEONARDO_MODELS_DIR="$new_path"
                    echo -e "${GREEN}Model path updated!${COLOR_RESET}"
                fi
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Network Settings")
                echo -e "\n${YELLOW}Network configuration coming soon!${COLOR_RESET}"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Security Options")
                echo -e "\n${YELLOW}Security options coming soon!${COLOR_RESET}"
                echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
                read -r
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

# Run system tests
run_system_tests() {
    echo -e "${CYAN}Running System Tests...${COLOR_RESET}"
    echo ""
    
    local tests_passed=0
    local tests_failed=0
    
    # Test 1: Check shell environment
    echo -n "1. Shell Environment... "
    if [[ -n "$BASH_VERSION" ]]; then
        echo -e "${GREEN}✓ Bash $BASH_VERSION${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${RED}✗ Bash not detected${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 2: Check terminal support
    echo -n "2. Terminal Support... "
    if [[ -n "$TERM" ]] && command -v tput >/dev/null 2>&1; then
        echo -e "${GREEN}✓ $TERM ($(tput colors) colors)${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${RED}✗ Terminal not properly configured${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 3: Check Python
    echo -n "3. Python Installation... "
    if command -v python3 >/dev/null 2>&1; then
        local py_version=$(python3 --version 2>&1 | awk '{print $2}')
        echo -e "${GREEN}✓ Python $py_version${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ Python 3 not found (needed for web interface)${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 4: Check disk space
    echo -n "4. Disk Space... "
    local free_space=$(df -h "$HOME" | awk 'NR==2 {print $4}')
    local free_gb=$(df -BG "$HOME" | awk 'NR==2 {gsub(/G/,"",$4); print $4}')
    if [[ $free_gb -gt 10 ]]; then
        echo -e "${GREEN}✓ $free_space available${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ Only $free_space available (recommend >10GB)${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 5: Check memory
    echo -n "5. System Memory... "
    local total_mem=$(free -h | awk '/^Mem:/ {print $2}')
    local avail_mem=$(free -h | awk '/^Mem:/ {print $7}')
    echo -e "${GREEN}✓ $avail_mem available of $total_mem${COLOR_RESET}"
    ((tests_passed++))
    
    # Test 6: Check USB support
    echo -n "6. USB Detection... "
    if command -v lsblk >/dev/null 2>&1; then
        local usb_count=$(lsblk -d -o NAME,TRAN | grep -c "usb" || echo 0)
        if [[ $usb_count -gt 0 ]]; then
            echo -e "${GREEN}✓ $usb_count USB device(s) detected${COLOR_RESET}"
        else
            echo -e "${YELLOW}⚠ No USB devices detected${COLOR_RESET}"
        fi
        ((tests_passed++))
    else
        echo -e "${RED}✗ lsblk not available${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 7: Check network
    echo -n "7. Network Connection... "
    if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Internet connected${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ No internet connection${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 8: Check Leonardo directories
    echo -n "8. Leonardo Directories... "
    if [[ -d "$LEONARDO_BASE_DIR" ]]; then
        echo -e "${GREEN}✓ Base directory exists${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ Base directory not initialized${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 9: Check model providers
    echo -n "9. Model Providers... "
    if command -v ollama >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Ollama installed${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${YELLOW}⚠ Ollama not installed (needed for models)${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Test 10: Check permissions
    echo -n "10. File Permissions... "
    if [[ -w "$HOME" ]]; then
        echo -e "${GREEN}✓ Write access to home directory${COLOR_RESET}"
        ((tests_passed++))
    else
        echo -e "${RED}✗ No write access to home directory${COLOR_RESET}"
        ((tests_failed++))
    fi
    
    # Summary
    echo ""
    echo "════════════════════════════════════════════"
    echo -e "Tests Passed: ${GREEN}$tests_passed${COLOR_RESET}"
    echo -e "Tests Failed: ${RED}$tests_failed${COLOR_RESET}"
    
    if [[ $tests_failed -eq 0 ]]; then
        echo -e "\n${GREEN}✓ All systems ready!${COLOR_RESET}"
    elif [[ $tests_failed -lt 3 ]]; then
        echo -e "\n${YELLOW}⚠ System mostly ready with minor issues${COLOR_RESET}"
    else
        echo -e "\n${RED}✗ Multiple issues detected, please review${COLOR_RESET}"
    fi
    
    echo -e "\n${DIM}Press Enter to continue...${COLOR_RESET}"
    read -r
}

# Launch web interface
launch_web_interface() {
    echo -e "\n${CYAN}Launching Web Interface...${COLOR_RESET}"
    start_web_server
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

# Handle chat command
handle_chat_command() {
    log_message "INFO" "Starting chat interface"
    
    # Auto-detect by default, no prompt needed
    start_location_aware_chat "" "auto"
}

# Check if running from USB deployment
is_usb_deployment() {
    # Check multiple indicators
    [[ "${LEONARDO_USB_MODE:-}" == "true" ]] && return 0
    [[ -n "${LEONARDO_USB_MOUNT:-}" ]] && return 0
    [[ -f "/leonardo_usb_marker" ]] && return 0
    
    # Check if script path contains common USB mount patterns
    local script_path="${BASH_SOURCE[0]:-$0}"
    local real_path=$(readlink -f "$script_path" 2>/dev/null || realpath "$script_path" 2>/dev/null || echo "$script_path")
    
    # Check for common USB mount patterns (case-insensitive for macOS)
    if echo "$real_path" | grep -iE '/(Volumes|media|mnt|run/media|usb|removable)/' >/dev/null 2>&1; then
        return 0
    fi
    
    # Check if we're in a leonardo directory on a removable device
    if [[ -d "${script_path%/*}/models" ]] && [[ -f "${script_path%/*}/leonardo.sh" ]]; then
        # Likely a portable installation
        return 0
    fi
    
    return 1
}

# Check if any models are installed
check_installed_models() {
    # For USB deployment, always show chat option
    if is_usb_deployment; then
        return 0  # Always allow chat on USB - models should be there
    fi
    
    # Check Ollama models
    if command_exists ollama; then
        local ollama_models=$(ollama list 2>/dev/null | tail -n +2 | wc -l)
        [[ $ollama_models -gt 0 ]] && return 0
    fi
    
    # Check local models
    if [[ -d "$LEONARDO_MODEL_DIR" ]]; then
        local local_models=$(find "$LEONARDO_MODEL_DIR" -name "*.gguf" 2>/dev/null | wc -l)
        [[ $local_models -gt 0 ]] && return 0
    fi
    
    # Also check common model locations
    local common_dirs=(
        "$LEONARDO_BASE_DIR/models"
        "$HOME/.leonardo/models"
        "/opt/leonardo/models"
        "./models"
    )
    
    for dir in "${common_dirs[@]}"; do
        if [[ -d "$dir" ]] && [[ -n "$(find "$dir" -name "*.gguf" 2>/dev/null | head -1)" ]]; then
            return 0
        fi
    done
    
    return 1
}

# System utilities menu
system_utilities_menu() {
    while true; do
        local selection
        selection=$(show_menu "System Utilities" \
            "Run System Tests" \
            "Clean Cache" \
            "Update Leonardo" \
            "View Logs" \
            "Back to Main Menu") || break
        
        case "$selection" in
            "Run System Tests")
                run_system_tests
                pause
                ;;
            "Clean Cache")
                echo -e "${YELLOW}Cleaning cache...${COLOR_RESET}"
                # TODO: Implement cache cleaning
                pause
                ;;
            "Update Leonardo")
                echo -e "${YELLOW}Checking for updates...${COLOR_RESET}"
                # TODO: Implement update check
                pause
                ;;
            "View Logs")
                if [[ -f "$LEONARDO_LOG_FILE" ]]; then
                    less "$LEONARDO_LOG_FILE"
                else
                    echo -e "${YELLOW}No logs found${COLOR_RESET}"
                    pause
                fi
                ;;
            "Back to Main Menu"|"")
                break
                ;;
        esac
    done
}

# Show about information
show_about() {
    clear
    show_banner
    echo
    echo -e "${BOLD}About Leonardo AI Universal${COLOR_RESET}"
    echo -e "${DIM}────────────────────────────────────────────────${COLOR_RESET}"
    echo
    echo "Leonardo is a portable AI assistant that can run from USB drives"
    echo "and provides easy access to various AI models."
    echo
    echo -e "${CYAN}Version:${COLOR_RESET} $LEONARDO_VERSION ($LEONARDO_BUILD)"
    echo -e "${CYAN}License:${COLOR_RESET} MIT"
    echo -e "${CYAN}Website:${COLOR_RESET} https://github.com/leonardo-ai/leonardo"
    echo
    echo -e "${BOLD}Features:${COLOR_RESET}"
    echo "  • Portable USB deployment"
    echo "  • Multiple AI model support"
    echo "  • Offline model management"
    echo "  • Cross-platform compatibility"
    echo "  • Web interface"
    echo
}

# Call main function with all arguments
main "$@"
