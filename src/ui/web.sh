#!/usr/bin/env bash
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
