#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Color Definitions
# ==============================================================================
# Description: Terminal color codes and styling utilities
# Version: 7.0.0
# Dependencies: none
# ==============================================================================

# Check if colors should be disabled
if [[ "$LEONARDO_NO_COLOR" == "true" ]] || [[ ! -t 1 ]]; then
    # No colors - define empty variables
    NC=""
    BOLD=""
    DIM=""
    UNDERLINE=""
    BLINK=""
    REVERSE=""
    HIDDEN=""
    
    # Regular colors
    BLACK=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    MAGENTA=""
    CYAN=""
    WHITE=""
    
    # Bright colors
    BRIGHT_BLACK=""
    BRIGHT_RED=""
    BRIGHT_GREEN=""
    BRIGHT_YELLOW=""
    BRIGHT_BLUE=""
    BRIGHT_MAGENTA=""
    BRIGHT_CYAN=""
    BRIGHT_WHITE=""
    
    # Background colors
    BG_BLACK=""
    BG_RED=""
    BG_GREEN=""
    BG_YELLOW=""
    BG_BLUE=""
    BG_MAGENTA=""
    BG_CYAN=""
    BG_WHITE=""
else
    # Reset
    NC="\033[0m"       # No Color / Reset
    
    # Text attributes
    BOLD="\033[1m"
    DIM="\033[2m"
    UNDERLINE="\033[4m"
    BLINK="\033[5m"
    REVERSE="\033[7m"
    HIDDEN="\033[8m"
    
    # Regular colors
    BLACK="\033[0;30m"
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[0;33m"
    BLUE="\033[0;34m"
    MAGENTA="\033[0;35m"
    CYAN="\033[0;36m"
    WHITE="\033[0;37m"
    
    # Bright colors
    BRIGHT_BLACK="\033[0;90m"
    BRIGHT_RED="\033[0;91m"
    BRIGHT_GREEN="\033[0;92m"
    BRIGHT_YELLOW="\033[0;93m"
    BRIGHT_BLUE="\033[0;94m"
    BRIGHT_MAGENTA="\033[0;95m"
    BRIGHT_CYAN="\033[0;96m"
    BRIGHT_WHITE="\033[0;97m"
    
    # Background colors
    BG_BLACK="\033[40m"
    BG_RED="\033[41m"
    BG_GREEN="\033[42m"
    BG_YELLOW="\033[43m"
    BG_BLUE="\033[44m"
    BG_MAGENTA="\033[45m"
    BG_CYAN="\033[46m"
    BG_WHITE="\033[47m"
fi

# Special Leonardo color combinations (Matrix/hacker themed)
LEONARDO_PRIMARY="${GREEN}"
LEONARDO_SECONDARY="${CYAN}"
LEONARDO_ACCENT="${MAGENTA}"
LEONARDO_SUCCESS="${GREEN}"
LEONARDO_WARNING="${YELLOW}"
LEONARDO_ERROR="${RED}"
LEONARDO_INFO="${BLUE}"

# Functions for colored output
print_color() {
    local color="$1"
    shift
    echo -e "${color}$*${NC}"
}

print_bold() {
    echo -e "${BOLD}$*${NC}"
}

print_success() {
    echo -e "${LEONARDO_SUCCESS}✓${NC} $*"
}

print_error() {
    echo -e "${LEONARDO_ERROR}✗${NC} $*" >&2
}

print_warning() {
    echo -e "${LEONARDO_WARNING}⚠${NC} $*" >&2
}

print_info() {
    echo -e "${LEONARDO_INFO}ℹ${NC} $*"
}

# Progress indicators with colors
print_progress() {
    local percent="$1"
    local width="${2:-50}"
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    printf "\r${LEONARDO_PRIMARY}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "]${NC} ${BOLD}%3d%%${NC}" "$percent"
}

# Spinner animation
declare -a SPINNER_FRAMES=(
    "⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏"
)

print_spinner() {
    local message="$1"
    local frame_index="${2:-0}"
    local frame="${SPINNER_FRAMES[$frame_index]}"
    
    printf "\r${LEONARDO_PRIMARY}${frame}${NC} ${message}"
}

# Box drawing characters
BOX_HORIZONTAL="─"
BOX_VERTICAL="│"
BOX_TOP_LEFT="┌"
BOX_TOP_RIGHT="┐"
BOX_BOTTOM_LEFT="└"
BOX_BOTTOM_RIGHT="┘"
BOX_CROSS="┼"
BOX_T_DOWN="┬"
BOX_T_UP="┴"
BOX_T_RIGHT="├"
BOX_T_LEFT="┤"

# Double box drawing
BOX_DOUBLE_HORIZONTAL="═"
BOX_DOUBLE_VERTICAL="║"
BOX_DOUBLE_TOP_LEFT="╔"
BOX_DOUBLE_TOP_RIGHT="╗"
BOX_DOUBLE_BOTTOM_LEFT="╚"
BOX_DOUBLE_BOTTOM_RIGHT="╝"

# Function to draw a box around text
draw_box() {
    local title="$1"
    local content="$2"
    local width="${3:-60}"
    local box_color="${4:-$LEONARDO_PRIMARY}"
    
    # Top border
    echo -e "${box_color}${BOX_TOP_LEFT}$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")${BOX_TOP_RIGHT}${NC}"
    
    # Title if provided
    if [[ -n "$title" ]]; then
        local title_len=${#title}
        local padding=$(( (width - title_len - 2) / 2 ))
        echo -e "${box_color}${BOX_VERTICAL}${NC}$(printf "%${padding}s")${BOLD}${title}${NC}$(printf "%$((width - padding - title_len))s")${box_color}${BOX_VERTICAL}${NC}"
        echo -e "${box_color}${BOX_T_RIGHT}$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")${BOX_T_LEFT}${NC}"
    fi
    
    # Content
    while IFS= read -r line; do
        local line_len=${#line}
        echo -e "${box_color}${BOX_VERTICAL}${NC} ${line}$(printf "%$((width - line_len - 1))s")${box_color}${BOX_VERTICAL}${NC}"
    done <<< "$content"
    
    # Bottom border
    echo -e "${box_color}${BOX_BOTTOM_LEFT}$(printf "%${width}s" | tr ' ' "$BOX_HORIZONTAL")${BOX_BOTTOM_RIGHT}${NC}"
}

# Function to create a gradient effect (for fun ASCII art)
print_gradient() {
    local text="$1"
    local colors=("$BRIGHT_GREEN" "$GREEN" "$CYAN" "$BLUE" "$MAGENTA")
    local len=${#text}
    local color_count=${#colors[@]}
    
    for ((i=0; i<len; i++)); do
        local color_index=$((i % color_count))
        echo -en "${colors[$color_index]}${text:$i:1}"
    done
    echo -e "${NC}"
}

# Matrix rain effect character
get_matrix_char() {
    local chars="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ0123456789"
    local len=${#chars}
    local index=$((RANDOM % len))
    echo "${chars:$index:1}"
}

# Export color functions
export -f print_color print_bold print_success print_error print_warning print_info
export -f print_progress print_spinner draw_box print_gradient
