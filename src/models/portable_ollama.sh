#!/usr/bin/env bash
# Portable Ollama - Run Ollama entirely from USB
# No traces left on host computer

# Source dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../utils/colors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../utils/network.sh"

# Install Ollama to USB
install_ollama_portable() {
    local usb_path="${1:-$LEONARDO_USB_MOUNT}"
    local ollama_dir="$usb_path/leonardo/tools/ollama"
    
    echo -e "${CYAN}Installing Portable Ollama...${COLOR_RESET}"
    echo -e "${DIM}This allows running AI models without installing anything on the host computer${COLOR_RESET}"
    
    # Create directory structure
    mkdir -p "$ollama_dir/bin"
    mkdir -p "$ollama_dir/models"
    mkdir -p "$ollama_dir/data"
    
    # Detect platform
    local platform=""
    local arch=""
    case "$(uname -s)" in
        Linux*)
            platform="linux"
            arch=$(uname -m)
            ;;
        Darwin*)
            platform="darwin"
            arch=$(uname -m)
            ;;
        *)
            echo -e "${RED}Unsupported platform: $(uname -s)${COLOR_RESET}"
            return 1
            ;;
    esac
    
    # Download Ollama binary
    local ollama_url="https://github.com/ollama/ollama/releases/latest/download/ollama-${platform}-${arch}"
    echo "Downloading Ollama for ${platform}-${arch}..."
    
    if download_with_progress "$ollama_url" "$ollama_dir/bin/ollama" "Downloading Ollama"; then
        chmod +x "$ollama_dir/bin/ollama"
        
        # Create portable launcher script
        cat > "$ollama_dir/run-ollama.sh" << 'EOF'
#!/usr/bin/env bash
# Portable Ollama Launcher
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set Ollama to use USB directories
export OLLAMA_MODELS="$SCRIPT_DIR/models"
export OLLAMA_HOST="127.0.0.1:11434"
export OLLAMA_ORIGINS="*"
export OLLAMA_KEEP_ALIVE="5m"
export HOME="$SCRIPT_DIR/data"

# Create required directories
mkdir -p "$OLLAMA_MODELS"
mkdir -p "$HOME"

echo "Starting Portable Ollama..."
echo "Models directory: $OLLAMA_MODELS"
echo "Data directory: $HOME"
echo ""
echo "This instance leaves no traces on the host computer."
echo "All models and data are stored on the USB drive."
echo ""

# Run Ollama
"$SCRIPT_DIR/bin/ollama" "$@"
EOF
        chmod +x "$ollama_dir/run-ollama.sh"
        
        # Create stealth mode script
        cat > "$ollama_dir/stealth-chat.sh" << 'EOF'
#!/usr/bin/env bash
# Stealth Mode Chat - No traces left on host
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Start Ollama in background
echo "Starting stealth mode..."
"$SCRIPT_DIR/run-ollama.sh" serve > /dev/null 2>&1 &
OLLAMA_PID=$!

# Wait for Ollama to start
sleep 3

# Run chat
export OLLAMA_HOST="127.0.0.1:11434"
"$SCRIPT_DIR/bin/ollama" run "${1:-llama3.2:1b}"

# Cleanup
kill $OLLAMA_PID 2>/dev/null
echo "Stealth session ended. No traces left."
EOF
        chmod +x "$ollama_dir/stealth-chat.sh"
        
        echo -e "${GREEN}✓ Portable Ollama installed successfully${COLOR_RESET}"
        echo -e "${CYAN}Usage:${COLOR_RESET}"
        echo "  • Run server: $ollama_dir/run-ollama.sh serve"
        echo "  • Stealth chat: $ollama_dir/stealth-chat.sh [model]"
        echo "  • Direct use: $ollama_dir/bin/ollama [command]"
        
        return 0
    else
        echo -e "${RED}Failed to download Ollama${COLOR_RESET}"
        return 1
    fi
}

# Check if running in portable mode
is_portable_ollama() {
    [[ -n "${OLLAMA_MODELS}" ]] && [[ "${OLLAMA_MODELS}" =~ "leonardo" ]]
}

# Get portable Ollama path
get_portable_ollama() {
    local usb_path="${1:-$LEONARDO_USB_MOUNT}"
    local ollama_bin="$usb_path/leonardo/tools/ollama/bin/ollama"
    
    if [[ -x "$ollama_bin" ]]; then
        echo "$ollama_bin"
        return 0
    else
        return 1
    fi
}

export -f install_ollama_portable
export -f is_portable_ollama
export -f get_portable_ollama
