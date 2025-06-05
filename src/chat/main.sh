#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Chat Module Main
# ==============================================================================
# Description: Main entry point for chat functionality
# Version: 7.0.0
# ==============================================================================

# Handle chat commands
handle_chat_command() {
    local subcommand="${1:-}"
    shift
    
    case "$subcommand" in
        "")
            # Start interactive chat
            source "${LEONARDO_BASE_DIR}/src/chat/cli.sh" 2>/dev/null || source "$(dirname "${BASH_SOURCE[0]}")/cli.sh"
            start_chat "$@"
            ;;
        
        "web"|"--web")
            # Start web interface
            source "${LEONARDO_BASE_DIR}/src/ui/web_server.sh" 2>/dev/null || source "$(dirname "${BASH_SOURCE[0]}")/../ui/web_server.sh"
            start_servers "$@"
            ;;
        
        "api")
            # Start API server only
            source "${LEONARDO_BASE_DIR}/src/chat/api.sh" 2>/dev/null || source "$(dirname "${BASH_SOURCE[0]}")/api.sh"
            start_api_server "$@"
            ;;
        
        "status")
            # Check server status
            source "${LEONARDO_BASE_DIR}/src/chat/api.sh" 2>/dev/null || source "$(dirname "${BASH_SOURCE[0]}")/api.sh"
            api_server_status
            ;;
        
        "stop")
            # Stop servers
            source "${LEONARDO_BASE_DIR}/src/ui/web_server.sh" 2>/dev/null || source "$(dirname "${BASH_SOURCE[0]}")/../ui/web_server.sh"
            stop_servers
            ;;
        
        "help"|"--help"|"-h")
            show_chat_help
            ;;
        
        *)
            echo -e "${RED}Unknown chat command: $subcommand${COLOR_RESET}"
            show_chat_help
            return 1
            ;;
    esac
}

# Show chat help
show_chat_help() {
    cat << EOF
Leonardo AI Chat Commands

Usage: leonardo chat [command] [options]

Commands:
  (no command)        Start interactive CLI chat
  web, --web         Start web interface with chat
  api                Start API server only
  status             Check server status
  stop               Stop all servers
  help               Show this help

Options for chat:
  [model]            Specify model to use (e.g., llama3.2:1b)

Options for web:
  [web_port] [api_port]  Specify ports (default: 8080, 8081)

Examples:
  leonardo chat                    # Start interactive chat
  leonardo chat llama3.2:1b       # Chat with specific model
  leonardo chat --web             # Start web interface
  leonardo chat web 3000 3001     # Custom ports
  leonardo chat stop              # Stop servers

Quick Start:
  leonardo chat --web             # Full web experience
  leonardo chat                   # CLI chat interface

EOF
}

# Export functions
export -f handle_chat_command
export -f show_chat_help
