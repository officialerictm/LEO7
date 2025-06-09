#!/bin/bash
# Setup script for Leonardo USB Chat with automatic llama.cpp installation

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}Leonardo AI USB Chat Setup${NC}"
echo -e "${CYAN}=========================${NC}\n"

# Detect USB mount point
USB_MOUNT="${LEONARDO_USB_MOUNT:-/media/$USER/LEONARDO}"

if [[ ! -d "$USB_MOUNT" ]]; then
    echo -e "${RED}Error: USB drive not mounted at $USB_MOUNT${NC}"
    echo -e "${YELLOW}Please mount your USB drive first or set LEONARDO_USB_MOUNT${NC}"
    exit 1
fi

echo -e "${GREEN}✓ USB drive found at: $USB_MOUNT${NC}"

# Create directory structure
echo -e "\n${CYAN}Creating directory structure...${NC}"
mkdir -p "$USB_MOUNT/leonardo/bin"
mkdir -p "$USB_MOUNT/leonardo/models"
mkdir -p "$USB_MOUNT/leonardo/tmp"
mkdir -p "$USB_MOUNT/leonardo/config"

# Check if llama.cpp is already installed
if [[ -f "$USB_MOUNT/leonardo/bin/llama-server" ]]; then
    echo -e "${GREEN}✓ llama.cpp already installed${NC}"
else
    echo -e "\n${CYAN}Installing portable llama.cpp...${NC}"
    
    # Option 1: Try to copy from host system
    if command -v llama-server >/dev/null 2>&1; then
        echo -e "${YELLOW}Found llama.cpp on host system, copying...${NC}"
        cp $(which llama-server) "$USB_MOUNT/leonardo/bin/"
        [[ -f $(which llama-cli) ]] && cp $(which llama-cli) "$USB_MOUNT/leonardo/bin/"
        chmod +x "$USB_MOUNT/leonardo/bin/llama-"*
        echo -e "${GREEN}✓ Copied from host system${NC}"
    else
        # Option 2: Build from source
        echo -e "${YELLOW}Building llama.cpp from source (this may take a few minutes)...${NC}"
        cd "$USB_MOUNT/leonardo/tmp"
        
        # Clone repository
        if [[ ! -d "llama.cpp" ]]; then
            git clone https://github.com/ggerganov/llama.cpp.git
        fi
        
        cd llama.cpp
        git pull origin master
        
        # Build with minimal dependencies
        make clean
        make -j$(nproc) LLAMA_PORTABLE=1 llama-server llama-cli
        
        # Copy binaries
        cp llama-server "$USB_MOUNT/leonardo/bin/"
        cp llama-cli "$USB_MOUNT/leonardo/bin/"
        chmod +x "$USB_MOUNT/leonardo/bin/llama-"*
        
        # Clean up
        cd "$USB_MOUNT/leonardo"
        rm -rf tmp/llama.cpp
        
        echo -e "${GREEN}✓ Built and installed llama.cpp${NC}"
    fi
fi

# Check for models
echo -e "\n${CYAN}Checking for models...${NC}"
MODEL_COUNT=$(find "$USB_MOUNT/leonardo/models" -name "*.gguf" -type f 2>/dev/null | wc -l)

if [[ $MODEL_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}No models found on USB drive${NC}"
    echo -e "${YELLOW}You need to download a GGUF model to: $USB_MOUNT/leonardo/models/${NC}"
    echo -e "\nSuggested models:"
    echo -e "  - TinyLlama 1.1B: https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF"
    echo -e "  - Llama 3.2 1B: https://huggingface.co/mlx-community/Llama-3.2-1B-Instruct-GGUF"
    echo -e "  - Phi-3 Mini: https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf"
else
    echo -e "${GREEN}✓ Found $MODEL_COUNT model(s) on USB${NC}"
    find "$USB_MOUNT/leonardo/models" -name "*.gguf" -type f -exec basename {} \; | sed 's/^/  - /'
fi

# Create launcher script
echo -e "\n${CYAN}Creating launcher script...${NC}"
cat > "$USB_MOUNT/leonardo/start-chat.sh" << 'EOF'
#!/bin/bash
# Leonardo USB Chat Launcher

USB_MOUNT="$(cd "$(dirname "$0")/.." && pwd)"
export LEONARDO_USB_MOUNT="$USB_MOUNT"
export LEONARDO_USB_MODE="true"
export LEONARDO_MODEL_DIR="$USB_MOUNT/leonardo/models"
export PATH="$USB_MOUNT/leonardo/bin:$PATH"

# Find a model
MODEL=$(find "$LEONARDO_MODEL_DIR" -name "*.gguf" -type f | head -1)

if [[ -z "$MODEL" ]]; then
    echo "Error: No GGUF models found in $LEONARDO_MODEL_DIR"
    exit 1
fi

echo "Starting chat with model: $(basename "$MODEL")"

# Start llama-server
llama-server \
    --model "$MODEL" \
    --ctx-size 2048 \
    --n-gpu-layers 0 \
    --port 8080 \
    --host 127.0.0.1 &

SERVER_PID=$!
sleep 3

# Simple chat interface
echo -e "\n🤖 Leonardo AI Chat (USB Mode)"
echo "Type 'exit' to quit"
echo "=========================="

while true; do
    read -p "You: " input
    [[ "$input" == "exit" ]] && break
    
    response=$(curl -s -X POST http://127.0.0.1:8080/completion \
        -H "Content-Type: application/json" \
        -d "{\"prompt\": \"Human: $input\nAssistant:\", \"n_predict\": 200}" | \
        jq -r '.content // "Error: No response"')
    
    echo -e "AI: $response\n"
done

kill $SERVER_PID 2>/dev/null
echo "Chat ended."
EOF

chmod +x "$USB_MOUNT/leonardo/start-chat.sh"

echo -e "\n${GREEN}✅ Setup complete!${NC}"
echo -e "\nTo use Leonardo USB Chat:"
echo -e "  1. Ensure you have at least one GGUF model in: $USB_MOUNT/leonardo/models/"
echo -e "  2. Run: ${CYAN}$USB_MOUNT/leonardo/start-chat.sh${NC}"
echo -e "\nFor full Leonardo experience, run: ${CYAN}./leonardo.sh${NC}"
