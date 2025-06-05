#!/usr/bin/env bash
# Start Leonardo Web Chat Interface

export LEONARDO_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modules directly
source "${LEONARDO_BASE_DIR}/src/utils/colors.sh"
source "${LEONARDO_BASE_DIR}/src/ui/web_server.sh"
source "${LEONARDO_BASE_DIR}/src/chat/api.sh"

echo -e "${CYAN}Starting Leonardo Web Chat Interface...${COLOR_RESET}"
echo

# Start both servers
start_servers 8080 8081
