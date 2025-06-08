#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Progress Display Components
# ==============================================================================
# Description: Progress bars, spinners, and status displays
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh
# ==============================================================================

# ==============================================================================
# UTILITY FUNCTIONS - Must be defined before use
# ==============================================================================

# Format duration from seconds
format_duration() {
    local seconds="$1"
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [[ $hours -gt 0 ]]; then
        printf "%02d:%02d:%02d" "$hours" "$minutes" "$secs"
    elif [[ $minutes -gt 0 ]]; then
        printf "%02d:%02d" "$minutes" "$secs"
    else
        printf "%ds" "$secs"
    fi
}

# Format bytes for display
format_bytes() {
    local bytes="$1"
    local units=("B" "KB" "MB" "GB" "TB")
    local unit=0
    
    # Use bc for floating point math if available
    if command -v bc >/dev/null 2>&1; then
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
    else
        # Fallback without bc
        local size=$bytes
        while [[ $size -ge 1024 ]] && [[ $unit -lt 4 ]]; do
            size=$((size / 1024))
            ((unit++))
        done
        printf "%d %s" "$size" "${units[unit]}"
    fi
}

# ==============================================================================
# PROGRESS BAR FUNCTIONS
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

# Matrix-style progress - DISABLED DUE TO SYNTAX ISSUES
# show_matrix_progress() {
#     local message="$1"
#     local duration="${2:-5}"
#     local width="${3:-$(tput cols)}"
#     
#     # Matrix rain characters
#     local chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
#     local drops=()
#     
#     # Initialize drops
#     for ((i=0; i<width; i++)); do
#         drops[i]=$((RANDOM % 20 - 10))
#     done
#     
#     # Save screen state
#     tput smcup
#     clear
#     
#     local start_time=$(date +%s)
#     local end_time=$((start_time + duration))
#     
#     # Hide cursor
#     tput civis
#     
#     while [[ $(date +%s) -lt $end_time ]]; do
#         for ((x=0; x<width; x++)); do
#             local y=${drops[x]}
#             
#             # Draw new character at bottom of trail
#             if [[ $y -ge 0 && $y -lt 20 ]]; then
#                 tput cup $y $x
#                 echo -ne "${BRIGHT_GREEN}${chars:$((RANDOM % ${#chars})):1}${NC}"
#                 
#                 # Draw the trail
#                 for ((ty=0; ty<y && ty<20; ty++)); do
#                     tput cup $ty $x
#                     local char_index=$((RANDOM % ${#chars}))
#                     local char="${chars:$char_index:1}"
#                     echo -ne "${GREEN}${char}${NC}"
#                 done
#             fi
#             
#             # Move drop down
#             drops[x]=$((drops[x] + 1))
#             
#             # Reset drop if it goes off screen
#             if [[ ${drops[x]} -gt 25 ]]; then
#                 drops[x]=$((RANDOM % 10 - 10))
#             fi
#         done
#         
#         # Display message in center
#         local msg_y=$((10))
#         local msg_x=$(((width - ${#message}) / 2))
#         tput cup $msg_y $msg_x
#         echo -ne "${BOLD}${CYAN}${message}${NC}"
#         
#         sleep 0.05
#     done
#     
#     # Show cursor
#     tput cnorm
#     
#     # Restore screen
#     tput rmcup
# }

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

# Track download progress with speed and ETA
track_download_progress() {
    local url="$1"
    local output_file="$2"
    local expected_size="${3:-0}"
    
    # Create a temporary file for curl progress
    local progress_file="/tmp/leonardo_download_$$"
    
    # Start curl in background with progress output
    curl -L -# -o "$output_file" "$url" 2>&1 | \
    while IFS= read -r line; do
        # Parse curl progress output
        if [[ "$line" =~ ^[[:space:]]*([0-9]+\.[0-9]+)%.*([0-9]+[kMG]?).*([0-9]+[kMG]?/s).*([0-9]+:[0-9]+:[0-9]+|[0-9]+:[0-9]+|[0-9]+s) ]]; then
            local percent="${BASH_REMATCH[1]}"
            local downloaded="${BASH_REMATCH[2]}"
            local speed="${BASH_REMATCH[3]}"
            local eta="${BASH_REMATCH[4]}"
            
            # Update progress bar
            printf "\r${CYAN}Downloading:${COLOR_RESET} "
            show_progress_bar "${percent%.*}" 100 30
            printf " %s%% \| %s \| ETA: %s  " "$percent" "$speed" "$eta"
        fi
    done
    
    # Clear the line
    printf "\r%-80s\r" " "
    
    # Check if download was successful
    if [[ -f "$output_file" ]]; then
        local size=$(format_bytes $(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file"))
        echo -e "${GREEN}✓ Downloaded successfully${COLOR_RESET} (${size})"
        return 0
    else
        echo -e "${RED}✗ Download failed${COLOR_RESET}"
        return 1
    fi
}

# Enhanced download with retry and resume
download_with_progress() {
    local url="$1"
    local output_file="$2"
    local description="${3:-Downloading}"
    local max_retries="${4:-3}"
    
    echo -e "${CYAN}${description}${COLOR_RESET}"
    echo "URL: $url"
    echo "Target: $output_file"
    echo ""
    
    local attempt=1
    while [[ $attempt -le $max_retries ]]; do
        if [[ $attempt -gt 1 ]]; then
            echo -e "${YELLOW}Retry attempt $attempt/$max_retries${COLOR_RESET}"
        fi
        
        # Check if file partially exists (for resume)
        local resume_flag=""
        if [[ -f "$output_file" ]]; then
            resume_flag="-C -"
            echo -e "${DIM}Resuming download...${COLOR_RESET}"
        fi
        
        # Download with progress
        if curl -L $resume_flag -# -o "$output_file" "$url" 2>&1 | \
        while IFS= read -r line; do
            # Match curl's progress bar format: ######################################################################## 100.0%
            if [[ "$line" =~ ^[#[:space:]]+([0-9]+)\+[0-9]+[[:space:]]records ]]; then
                local blocks="${BASH_REMATCH[1]}"
                local percent=$((blocks * 100 / 100))
                local copied=$((blocks * 1048576))
                local copied_fmt=$(format_bytes "$copied")
                
                printf "\r"
                show_progress_bar "$percent" 100 40
                printf " %s%% \| %s/%s  " "$percent" "$copied_fmt" "$(format_bytes 104857600)"
            elif [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]+([0-9]+[kMG]?)[[:space:]]+([0-9]+)[%][[:space:]]+([0-9]+[kMG]?/s)[[:space:]]+.*[[:space:]]+([0-9]+:[0-9]+:[0-9]+|[0-9]+:[0-9]+|[0-9]+s|--:--:--) ]]; then
                # Alternative format with more details
                local percent="${BASH_REMATCH[3]}"
                local downloaded="${BASH_REMATCH[2]}"
                local speed="${BASH_REMATCH[4]}"
                local eta="${BASH_REMATCH[5]}"
                
                # Update progress bar
                printf "\r"
                show_progress_bar "$percent" 100 40
                printf " %s%% \| %s \| ETA: %s  " "$percent" "$speed" "$eta"
            fi
        done; then
            printf "\r%-80s\r" " "
            local size=$(format_bytes $(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file"))
            echo -e "${GREEN}✓ Downloaded successfully${COLOR_RESET} (${size})"
            return 0
        else
            printf "\r%-80s\r" " "
            echo -e "${RED}✗ Download failed${COLOR_RESET}"
            ((attempt++))
            if [[ $attempt -le $max_retries ]]; then
                sleep 2
            fi
        fi
    done
    
    return 1
}

# Copy files with progress
copy_with_progress() {
    local source="$1"
    local dest="$2"
    local description="${3:-Copying}"
    
    if [[ ! -f "$source" ]]; then
        echo -e "${RED}Source file not found: $source${COLOR_RESET}"
        return 1
    fi
    
    local total_size=$(stat -f%z "$source" 2>/dev/null || stat -c%s "$source")
    local total_size_fmt=$(format_bytes "$total_size")
    
    echo -e "${CYAN}${description}${COLOR_RESET}"
    echo "Source: $(basename "$source") ($total_size_fmt)"
    echo "Destination: $dest"
    echo ""
    
    # Use dd with progress
    local block_size=1048576  # 1MB blocks
    local total_blocks=$((total_size / block_size + 1))
    
    (
        dd if="$source" of="$dest" bs=$block_size 2>&1 | \
        while IFS= read -r line; do
            if [[ "$line" =~ ^([0-9]+)\+[0-9]+[[:space:]]records ]]; then
                local blocks="${BASH_REMATCH[1]}"
                local percent=$((blocks * 100 / total_blocks))
                local copied=$((blocks * block_size))
                local copied_fmt=$(format_bytes "$copied")
                
                printf "\r"
                show_progress_bar "$percent" 100 40
                printf " %s%% \| %s/%s  " "$percent" "$copied_fmt" "$total_size_fmt"
            fi
        done
    ) &
    
    local dd_pid=$!
    
    # Monitor progress
    while kill -0 $dd_pid 2>/dev/null; do
        if [[ -f "$dest" ]]; then
            local current_size=$(stat -f%z "$dest" 2>/dev/null || stat -c%s "$dest")
            local percent=$((current_size * 100 / total_size))
            local copied_fmt=$(format_bytes "$current_size")
            
            printf "\r"
            show_progress_bar "$percent" 100 40
            printf " %s%% \| %s/%s  " "$percent" "$copied_fmt" "$total_size_fmt"
        fi
        sleep 0.1
    done
    
    wait $dd_pid
    local result=$?
    
    printf "\r%-80s\r" " "
    
    if [[ $result -eq 0 ]]; then
        echo -e "${GREEN}✓ Copy completed${COLOR_RESET} ($total_size_fmt)"
        return 0
    else
        echo -e "${RED}✗ Copy failed${COLOR_RESET}"
        return 1
    fi
}

# Multi-file copy with overall progress
copy_directory_with_progress() {
    local source_dir="$1"
    local dest_dir="$2"
    local description="${3:-Copying files}"
    
    if [[ ! -d "$source_dir" ]]; then
        echo -e "${RED}Source directory not found: $source_dir${COLOR_RESET}"
        return 1
    fi
    
    # Calculate total size
    echo -e "${CYAN}Calculating total size...${COLOR_RESET}"
    local total_size=$(du -sb "$source_dir" 2>/dev/null | cut -f1 || du -sk "$source_dir" | cut -f1)
    local total_size_fmt=$(format_bytes "$total_size")
    
    echo -e "${CYAN}${description}${COLOR_RESET}"
    echo "Source: $source_dir"
    echo "Destination: $dest_dir"
    echo "Total size: $total_size_fmt"
    echo ""
    
    # Create destination directory
    mkdir -p "$dest_dir"
    
    # Copy with rsync and progress
    rsync -ah --info=progress2 "$source_dir/" "$dest_dir/" 2>&1 | \
    while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]+([0-9]+[kMG]?)[[:space:]]+([0-9]+)[%][[:space:]]+([0-9]+[kMG]?/s)[[:space:]]+.*[[:space:]]+([0-9]+:[0-9]+:[0-9]+|[0-9]+:[0-9]+|[0-9]+s|--:--:--) ]]; then
            local percent="${BASH_REMATCH[3]}"
            local downloaded="${BASH_REMATCH[2]}"
            local speed="${BASH_REMATCH[4]}"
            local eta="${BASH_REMATCH[5]}"
            
            printf "\r"
            show_progress_bar "$percent" 100 40
            printf " %s%% \| %s \| ETA: %s  " "$percent" "$speed" "$eta"
        fi
    done
    
    printf "\r%-80s\r" " "
    echo -e "${GREEN}✓ Copy completed${COLOR_RESET} ($total_size_fmt)"
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

# Simple progress function with spinner
show_progress() {
    local message="${1:-Processing...}"
    echo "${CYAN}→ ${message}${RESET}"
}

# Export progress functions
export -f show_progress_bar show_multi_progress show_spinner stop_spinner
export -f show_progress show_download_progress show_status show_countdown
export -f format_duration format_bytes show_ascii_progress
export -f track_download_progress download_with_progress copy_with_progress copy_directory_with_progress
