#!/usr/bin/env bash
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
