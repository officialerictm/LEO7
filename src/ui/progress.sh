#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Progress Display Components
# ==============================================================================
# Description: Progress bars, spinners, and status displays
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh
# ==============================================================================

# Progress bar state
declare -g PROGRESS_ACTIVE=0
declare -g PROGRESS_PID=""

# Enhanced progress bar with percentage and ETA
show_progress_bar() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local title="${4:-Progress}"
    local start_time="${5:-$(date +%s)}"
    
    # Calculate percentage
    local percent=$((current * 100 / total))
    
    # Calculate filled width
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    # Calculate ETA
    local elapsed=$(($(date +%s) - start_time))
    local eta=""
    if [[ $elapsed -gt 0 ]] && [[ $current -gt 0 ]]; then
        local rate=$(echo "scale=2; $current / $elapsed" | bc 2>/dev/null || echo "0")
        if [[ $(echo "$rate > 0" | bc 2>/dev/null) == "1" ]]; then
            local remaining=$((total - current))
            local eta_seconds=$(echo "scale=0; $remaining / $rate" | bc 2>/dev/null || echo "0")
            eta=$(format_duration "$eta_seconds")
        fi
    fi
    
    # Build progress bar
    printf "\r${YELLOW}%s${RESET} [" "$title"
    
    # Filled portion with gradient effect
    if [[ $filled -gt 0 ]]; then
        local gradient=""
        for ((i=0; i<filled; i++)); do
            if [[ $percent -lt 33 ]]; then
                gradient+="${RED}█"
            elif [[ $percent -lt 66 ]]; then
                gradient+="${YELLOW}█"
            else
                gradient+="${GREEN}█"
            fi
        done
        printf "%b" "$gradient${RESET}"
    fi
    
    # Empty portion
    printf "%${empty}s" | tr ' ' '░'
    
    # Percentage and ETA
    printf "] ${BRIGHT}%3d%%${RESET}" "$percent"
    if [[ -n "$eta" ]]; then
        printf " ${DIM}ETA: %s${RESET}" "$eta"
    fi
    
    # Add data info if provided
    if [[ -n "${6:-}" ]] && [[ -n "${7:-}" ]]; then
        local current_size="$6"
        local total_size="$7"
        printf " ${DIM}(%s/%s)${RESET}" \
            "$(format_bytes "$current_size")" \
            "$(format_bytes "$total_size")"
    fi
    
    # Newline if complete
    if [[ $percent -eq 100 ]]; then
        echo
    fi
}

# Multi-line progress display
show_multi_progress() {
    local -n tasks=$1
    local -n progress=$2
    local title="${3:-Tasks Progress}"
    
    # Save cursor position
    tput sc
    
    # Clear area
    local num_tasks=${#tasks[@]}
    for ((i=0; i<=num_tasks+3; i++)); do
        echo -e "\033[K"
    done
    
    # Restore cursor
    tput rc
    
    # Display title
    echo -e "${GREEN}╔════════════════════════════════════════════╗${RESET}"
    printf "${GREEN}║${RESET} %-42s ${GREEN}║${RESET}\n" "$title"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${RESET}"
    echo
    
    # Display each task progress
    local all_complete=true
    for ((i=0; i<num_tasks; i++)); do
        local task="${tasks[i]}"
        local prog="${progress[i]:-0}"
        
        printf "%-20s " "$task:"
        
        # Mini progress bar
        local bar_width=20
        local filled=$((prog * bar_width / 100))
        local empty=$((bar_width - filled))
        
        printf "["
        if [[ $prog -eq 100 ]]; then
            printf "${GREEN}%${bar_width}s${RESET}" | tr ' ' '█'
        else
            all_complete=false
            printf "${YELLOW}%${filled}s${RESET}" | tr ' ' '█'
            printf "%${empty}s" | tr ' ' '░'
        fi
        printf "] %3d%%\n" "$prog"
    done
    
    # Return whether all tasks are complete
    [[ "$all_complete" == "true" ]]
}

# Animated spinner styles
declare -a SPINNER_STYLES=(
    "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"                    # Braille dots
    "◐◓◑◒"                              # Circle quarters
    "▁▂▃▄▅▆▇█▇▆▅▄▃▂"                    # Building blocks
    "⣾⣽⣻⢿⡿⣟⣯⣷"                    # Braille blocks
    "←↖↑↗→↘↓↙"                          # Arrows
    "|/-\\"                             # Classic
    "◢◣◤◥"                              # Triangles
    "⬒⬔⬓⬕"                              # Diamond
    "⠁⠂⠄⡀⢀⠠⠐⠈"                    # Dots
)

# Show spinner with message
show_spinner() {
    local message="$1"
    local style_idx="${2:-0}"
    local style="${SPINNER_STYLES[$style_idx]}"
    local delay="${3:-0.1}"
    
    PROGRESS_ACTIVE=1
    
    # Run spinner in background
    (
        local i=0
        while [[ $PROGRESS_ACTIVE -eq 1 ]]; do
            local char="${style:$i:1}"
            printf "\r${CYAN}%s${RESET} %s" "$char" "$message"
            sleep "$delay"
            i=$(( (i + 1) % ${#style} ))
        done
        printf "\r\033[K"  # Clear line
    ) &
    
    PROGRESS_PID=$!
}

# Stop spinner
stop_spinner() {
    PROGRESS_ACTIVE=0
    if [[ -n "$PROGRESS_PID" ]]; then
        kill "$PROGRESS_PID" 2>/dev/null
        wait "$PROGRESS_PID" 2>/dev/null
        PROGRESS_PID=""
    fi
    printf "\r\033[K"  # Clear line
}

# Matrix-style progress
show_matrix_progress() {
    local message="$1"
    local duration="${2:-5}"
    local width="${3:-$(tput cols)}"
    
    # Matrix rain characters
    local chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
    local drops=()
    
    # Initialize drops
    for ((i=0; i<width; i++)); do
        drops[i]=$((RANDOM % 20 - 10))
    done
    
    # Save screen state
    tput smcup
    clear
    
    local start_time=$(date +%s)
    while [[ $(($(date +%s) - start_time)) -lt $duration ]]; do
        clear
        
        # Update and draw drops
        for ((x=0; x<width; x++)); do
            local y=${drops[x]}
            if [[ $y -ge 0 ]]; then
                # Draw the trail
                for ((ty=0; ty<y && ty<20; ty++)); do
                    tput cup $ty $x
                    local brightness=$((255 - (y - ty) * 12))
                    printf "\033[38;2;0;%d;0m%s\033[0m" \
                        "$brightness" \
                        "${chars:$((RANDOM % ${#chars})):1}"
                done
            fi
            
            # Move drop down
            drops[x]=$((drops[x] + 1))
            
            # Reset drop if it goes off screen
            if [[ ${drops[x]} -gt 25 ]]; then
                drops[x]=$((RANDOM % 10 - 10))
            fi
        done
        
        # Display message in center
        local msg_y=$(($(tput lines) / 2))
        local msg_x=$(((width - ${#message}) / 2))
        tput cup $msg_y $msg_x
        echo -e "${BRIGHT}${GREEN}$message${RESET}"
        
        sleep 0.05
    done
    
    # Restore screen
    tput rmcup
}

# Download progress with speed and time
show_download_progress() {
    local url="$1"
    local current_bytes="$2"
    local total_bytes="$3"
    local start_time="${4:-$(date +%s)}"
    
    # Calculate speed
    local elapsed=$(($(date +%s) - start_time))
    local speed=0
    if [[ $elapsed -gt 0 ]]; then
        speed=$((current_bytes / elapsed))
    fi
    
    # Extract filename from URL
    local filename=$(basename "$url" | cut -c1-30)
    [[ ${#filename} -eq 30 ]] && filename="${filename}..."
    
    # Show progress
    show_progress_bar "$current_bytes" "$total_bytes" 40 "$filename" \
        "$start_time" "$current_bytes" "$total_bytes"
    
    # Add speed indicator
    if [[ $speed -gt 0 ]]; then
        printf " ${DIM}↓ %s/s${RESET}" "$(format_bytes "$speed")"
    fi
}

# Status indicator with icon
show_status() {
    local status="$1"
    local message="$2"
    local icon=""
    local color=""
    
    case "$status" in
        success|ok|done)
            icon="✓"
            color="$GREEN"
            ;;
        error|fail|failed)
            icon="✗"
            color="$RED"
            ;;
        warning|warn)
            icon="⚠"
            color="$YELLOW"
            ;;
        info)
            icon="ℹ"
            color="$BLUE"
            ;;
        loading|progress)
            icon="◌"
            color="$CYAN"
            ;;
        *)
            icon="•"
            color="$WHITE"
            ;;
    esac
    
    echo -e "${color}${icon}${RESET} ${message}"
}

# Countdown timer
show_countdown() {
    local seconds="$1"
    local message="${2:-Countdown}"
    
    for ((i=seconds; i>0; i--)); do
        printf "\r${YELLOW}%s:${RESET} %02d:%02d" \
            "$message" \
            $((i / 60)) \
            $((i % 60))
        sleep 1
    done
    printf "\r\033[K"
    show_status "done" "$message complete!"
}

# Format duration for display
format_duration() {
    local seconds="$1"
    
    if [[ $seconds -lt 60 ]]; then
        echo "${seconds}s"
    elif [[ $seconds -lt 3600 ]]; then
        printf "%dm %ds" $((seconds / 60)) $((seconds % 60))
    else
        printf "%dh %dm" $((seconds / 3600)) $((seconds % 3600 / 60))
    fi
}

# Format bytes for display
format_bytes() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    
    # Use bc for floating point math
    local size=$bytes
    while [[ $(echo "$size >= 1024" | bc 2>/dev/null) == "1" ]] && [[ $unit -lt 4 ]]; do
        size=$(echo "scale=2; $size / 1024" | bc 2>/dev/null)
        ((unit++))
    done
    
    # Format with appropriate precision
    if [[ $unit -eq 0 ]]; then
        printf "%d %s" "$bytes" "${units[unit]}"
    else
        printf "%.2f %s" "$size" "${units[unit]}"
    fi
}

# ASCII art progress animations
show_ascii_progress() {
    local type="$1"
    local progress="$2"
    
    case "$type" in
        rocket)
            local pos=$((progress * 50 / 100))
            printf "\r"
            printf "%${pos}s" | tr ' ' '.'
            printf "🚀"
            printf "%$((50 - pos))s" | tr ' ' '.'
            printf " %3d%%" "$progress"
            ;;
            
        pac)
            local pos=$((progress * 40 / 100))
            local mouth=$((progress % 20 < 10))
            printf "\r"
            printf "%${pos}s" | tr ' ' ' '
            if [[ $mouth -eq 1 ]]; then
                printf "${YELLOW}ᗧ${RESET}"
            else
                printf "${YELLOW}ᗤ${RESET}"
            fi
            printf "%$((40 - pos))s" | tr ' ' '·'
            printf " %3d%%" "$progress"
            ;;
            
        train)
            local pos=$((progress * 35 / 100))
            printf "\r["
            printf "%${pos}s" | tr ' ' '='
            printf "🚂"
            printf "%$((35 - pos))s" | tr ' ' '-'
            printf "] %3d%%" "$progress"
            ;;
    esac
}

# Export progress functions
export -f show_progress_bar show_multi_progress show_spinner stop_spinner
export -f show_download_progress show_status show_countdown format_duration
export -f format_bytes show_matrix_progress show_ascii_progress
