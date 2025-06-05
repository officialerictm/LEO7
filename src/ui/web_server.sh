#!/usr/bin/env bash
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
    
    # Copy the chat interface
    local chat_html="${LEONARDO_BASE_DIR}/src/ui/web_chat.html"
    if [[ ! -f "$chat_html" ]]; then
        # Try alternate location
        chat_html="$(dirname "${BASH_SOURCE[0]}")/web_chat.html"
    fi
    
    if [[ -f "$chat_html" ]]; then
        cp "$chat_html" "$web_root/index.html"
    elif [[ ! -f "$web_root/index.html" ]]; then
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

# Start both web and API servers
start_servers() {
    local web_port="${1:-8080}"
    local api_port="${2:-8081}"
    
    # Source API module
    source "${LEONARDO_BASE_DIR}/src/chat/api.sh" 2>/dev/null || source "$(dirname "${BASH_SOURCE[0]}")/../chat/api.sh"
    
    echo -e "${CYAN}Starting Leonardo Web Interface with Chat...${COLOR_RESET}"
    echo
    
    # Start API server first
    start_api_server "$api_port"
    
    # Then start web server
    start_web_server "$web_port"
    
    echo
    echo -e "${GREEN}✓ Leonardo Web Chat is ready!${COLOR_RESET}"
    echo -e "  Web UI: ${CYAN}http://localhost:${web_port}${COLOR_RESET}"
    echo -e "  API: ${CYAN}http://localhost:${api_port}/api${COLOR_RESET}"
    echo
    echo -e "${DIM}Press Ctrl+C to stop${COLOR_RESET}"
}

# Stop both servers
stop_servers() {
    # Source API module
    source "${LEONARDO_BASE_DIR}/src/chat/api.sh" 2>/dev/null || source "$(dirname "${BASH_SOURCE[0]}")/../chat/api.sh"
    
    stop_web_server
    stop_api_server
}
