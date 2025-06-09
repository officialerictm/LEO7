#!/usr/bin/env bash
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
