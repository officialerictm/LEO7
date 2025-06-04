#!/usr/bin/env bash
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
