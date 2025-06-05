#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Chat API Backend
# ==============================================================================
# Description: Simple HTTP API for AI chat functionality
# Version: 7.0.0
# ==============================================================================

# API server configuration
API_PORT="${LEONARDO_API_PORT:-8081}"
API_HOST="${LEONARDO_API_HOST:-localhost}"
API_PID_FILE="${LEONARDO_BASE_DIR}/api.pid"

# Start API server
start_api_server() {
    local port="${1:-$API_PORT}"
    local host="${2:-$API_HOST}"
    
    echo -e "${CYAN}Starting Leonardo API Server...${COLOR_RESET}"
    echo -e "${DIM}API endpoint: http://${host}:${port}/api${COLOR_RESET}"
    
    # Check if already running
    if [[ -f "$API_PID_FILE" ]]; then
        local pid=$(cat "$API_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${YELLOW}API server already running (PID: $pid)${COLOR_RESET}"
            return 0
        fi
    fi
    
    # Create Python API server script
    local api_script="${LEONARDO_BASE_DIR}/api_server.py"
    cat > "$api_script" << 'EOF'
#!/usr/bin/env python3
import json
import subprocess
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse

class APIHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def do_GET(self):
        parsed_path = urlparse(self.path)
        
        if parsed_path.path == '/api/health':
            self.send_json({'status': 'ok', 'version': '7.0.0'})
        elif parsed_path.path == '/api/models':
            self.get_models()
        else:
            self.send_error(404, 'Not found')
    
    def do_POST(self):
        parsed_path = urlparse(self.path)
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')
        
        try:
            data = json.loads(body) if body else {}
        except json.JSONDecodeError:
            self.send_error(400, 'Invalid JSON')
            return
        
        if parsed_path.path == '/api/chat':
            self.handle_chat(data)
        else:
            self.send_error(404, 'Not found')
    
    def send_json(self, data):
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def get_models(self):
        models = []
        try:
            # Get Ollama models
            result = subprocess.run(['ollama', 'list'], capture_output=True, text=True)
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')[1:]  # Skip header
                for line in lines:
                    parts = line.split()
                    if len(parts) >= 2:
                        models.append({
                            'name': parts[0],
                            'provider': 'ollama',
                            'size': parts[1]
                        })
        except Exception as e:
            print(f"Error getting models: {e}")
        
        self.send_json({'models': models})
    
    def handle_chat(self, data):
        model = data.get('model', '')
        message = data.get('message', '')
        
        if not model or not message:
            self.send_json({'error': 'Missing model or message'})
            return
        
        try:
            # Use Ollama for chat
            result = subprocess.run(
                ['ollama', 'run', model, '--nowordwrap'],
                input=message,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                response = result.stdout.strip()
                self.send_json({'response': response})
            else:
                self.send_json({'error': f'Model error: {result.stderr}'})
        except Exception as e:
            self.send_json({'error': str(e)})
    
    def log_message(self, format, *args):
        # Suppress default logging
        pass

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
    server = HTTPServer(('localhost', port), APIHandler)
    print(f"API server running on port {port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()
EOF

    # Make executable
    chmod +x "$api_script"
    
    # Start Python server in background
    python3 "$api_script" "$port" > "${LEONARDO_BASE_DIR}/api.log" 2>&1 &
    local server_pid=$!
    echo "$server_pid" > "$API_PID_FILE"
    
    echo -e "${GREEN}✓ API server started (PID: $server_pid)${COLOR_RESET}"
    
    # Wait a moment to ensure server is up
    sleep 2
    
    # Test the server
    if curl -s "http://${host}:${port}/api/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ API server is responding${COLOR_RESET}"
    else
        echo -e "${YELLOW}⚠ API server may not be fully initialized${COLOR_RESET}"
    fi
}

# Stop API server
stop_api_server() {
    if [[ -f "$API_PID_FILE" ]]; then
        local pid=$(cat "$API_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$API_PID_FILE"
            echo -e "${GREEN}✓ API server stopped${COLOR_RESET}"
        else
            echo -e "${YELLOW}API server not running${COLOR_RESET}"
            rm -f "$API_PID_FILE"
        fi
    else
        echo -e "${YELLOW}No API server PID file found${COLOR_RESET}"
    fi
}

# API server status
api_server_status() {
    if [[ -f "$API_PID_FILE" ]]; then
        local pid=$(cat "$API_PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo -e "${GREEN}API server is running (PID: $pid)${COLOR_RESET}"
            echo -e "Endpoint: http://${API_HOST}:${API_PORT}/api"
            return 0
        fi
    fi
    echo -e "${YELLOW}API server is not running${COLOR_RESET}"
    return 1
}

# Export functions
export -f start_api_server
export -f stop_api_server
export -f api_server_status
