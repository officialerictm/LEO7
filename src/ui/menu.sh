#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Menu System
# ==============================================================================
# Description: Interactive menu navigation and selection
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, validation.sh
# ==============================================================================

# Menu state tracking
declare -g MENU_SELECTION=""
declare -g MENU_POSITION=1
declare -g MENU_MAX_ITEMS=0

# Compatibility
BRIGHT="${BOLD}"

# Show interactive menu
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    local selected=0
    local num_options=${#options[@]}
    
    # Debug terminal detection
    if [[ "${LEONARDO_DEBUG:-}" == "true" ]]; then
        echo -e "${YELLOW}DEBUG: Terminal detection:${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - tty 0: $([[ -t 0 ]] && echo yes || echo no)${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - tty 1: $([[ -t 1 ]] && echo yes || echo no)${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - tty 2: $([[ -t 2 ]] && echo yes || echo no)${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - PS1: '${PS1:-}'${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - TERM: '${TERM:-}'${COLOR_RESET}" >&2
        echo -e "${YELLOW}  - LEONARDO_FORCE_INTERACTIVE: '${LEONARDO_FORCE_INTERACTIVE:-}'${COLOR_RESET}" >&2
    fi
    
    # Check for interactive terminal - more robust check
    local is_interactive=false
    if [[ -t 0 ]] && [[ -t 1 ]] && [[ -t 2 ]]; then
        is_interactive=true
    elif [[ -n "${PS1:-}" ]] && [[ -z "${DEBIAN_FRONTEND:-}" ]]; then
        is_interactive=true
    elif [[ "${LEONARDO_FORCE_INTERACTIVE:-}" == "true" ]]; then
        is_interactive=true
    fi
    
    # For now, let's bypass the check if TERM is set
    if [[ -n "${TERM:-}" ]] && [[ "${TERM:-}" != "dumb" ]]; then
        is_interactive=true
    fi
    
    if [[ "$is_interactive" != "true" ]]; then
        echo -e "${RED}Error: No interactive terminal available${COLOR_RESET}" >&2
        echo -e "${DIM}Hint: Run Leonardo directly in a terminal, not through pipes or scripts${COLOR_RESET}" >&2
        return 1
    fi
    
    # Hide cursor
    tput civis 2>/dev/null >/dev/tty || true
    
    # Ensure cursor is restored on exit
    trap 'tput cnorm 2>/dev/null >/dev/tty || true' RETURN INT TERM
    
    # Clear pending input
    while read -t 0; do :; done
    
    while true; do
        # Clear screen completely
        printf '\033[2J\033[H' >/dev/tty
        
        # Draw the menu
        draw_menu "$title" "$selected" "${options[@]}"
        
        # Read single character
        local key
        IFS= read -rsn1 key
        
        # Handle escape sequences for arrow keys
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
            case "$key" in
                '[A') key='UP' ;;     # Up arrow
                '[B') key='DOWN' ;;   # Down arrow
                '[D') key='LEFT' ;;   # Left arrow
                '[C') key='RIGHT' ;;  # Right arrow
                *) continue ;;
            esac
        fi
        
        # Process input
        case "$key" in
            'UP'|'k')
                ((selected = selected > 0 ? selected - 1 : num_options - 1))
                ;;
            'DOWN'|'j')
                ((selected = (selected + 1) % num_options))
                ;;
            [1-9])
                local idx=$((key - 1))
                if [[ $idx -lt $num_options ]]; then
                    selected=$idx
                    # Restore cursor before returning
                    tput cnorm 2>/dev/null >/dev/tty || true
                    # Return clean option text only
                    echo -n "${options[$selected]}"
                    return 0
                fi
                ;;
            ''|$'\n') # Enter
                # Restore cursor before returning
                tput cnorm 2>/dev/null >/dev/tty || true
                # Return clean option text only
                echo -n "${options[$selected]}"
                return 0
                ;;
            'q'|'Q')
                tput cnorm 2>/dev/null >/dev/tty || true
                return 1
                ;;
        esac
    done
}

# Display menu frame with highlighting
draw_menu() {
    local title="$1"
    local selected="$2"
    shift 2
    local options=("$@")
    
    # All display output goes to stderr or /dev/tty to keep stdout clean
    {
        # Draw title box - force output to terminal
        echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}" >/dev/tty
        printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title" >/dev/tty
        echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}" >/dev/tty
        echo >/dev/tty
        
        # Display options with numbering
        local i=1
        for option in "${options[@]}"; do
            local display_option="${i}) ${option}"
            if [[ $i -eq $((selected + 1)) ]]; then
                # Highlighted option
                echo -e "${CYAN}▶ ${BRIGHT}${display_option}${COLOR_RESET}" >/dev/tty
            else
                echo -e "  ${DIM}${display_option}${COLOR_RESET}" >/dev/tty
            fi
            ((i++))
        done
        
        echo >/dev/tty
        echo -e "${DIM}Use ↑/↓ arrows or numbers to select, Enter to confirm, q to quit${COLOR_RESET}" >/dev/tty
    } >&2
}

# Simple yes/no menu
confirm_menu() {
    local prompt="$1"
    local default="${2:-n}"
    
    echo -e "${YELLOW}${prompt}${COLOR_RESET}"
    
    local options=("Yes" "No")
    local selection=$(show_menu "Confirm Action" "${options[@]}")
    
    case "$selection" in
        "Yes") return 0 ;;
        "No"|"") return 1 ;;
    esac
}

# Alias for backward compatibility
confirm_action() {
    confirm_menu "$@"
}

# Multi-select checklist menu
show_checklist() {
    local title="$1"
    shift
    local options=("$@")
    local num_options=${#options[@]}
    local -a selected=()
    
    # Initialize all as unselected
    for ((i=0; i<num_options; i++)); do
        selected[i]=0
    done
    
    MENU_POSITION=1
    
    # Hide cursor if possible (only if tput is available)
    if command -v tput >/dev/null 2>&1 && [ -n "$TERM" ]; then
        tput civis 2>/dev/null >/dev/tty || true
        trap 'tput cnorm 2>/dev/null >/dev/tty || true; echo' INT TERM
    fi
    
    while true; do
        clear
        display_checklist_frame "$title" "${options[@]}" "${selected[@]}"
        
        # Read user input
        IFS= read -sn1 key
        
        case "$key" in
            $'\x1b')
                read -sn2 -t 0.1 key
                case "$key" in
                    '[A') # Up arrow
                        ((MENU_POSITION--))
                        [[ $MENU_POSITION -lt 1 ]] && MENU_POSITION=$num_options
                        ;;
                    '[B') # Down arrow
                        ((MENU_POSITION++))
                        [[ $MENU_POSITION -gt $num_options ]] && MENU_POSITION=1
                        ;;
                esac
                ;;
            ' ') # Space to toggle
                local idx=$((MENU_POSITION-1))
                selected[idx]=$((1 - selected[idx]))
                ;;
            '') # Enter to confirm
                break
                ;;
            q|Q) # Quit
                selected=()
                break
                ;;
        esac
    done
    
    # Show cursor again (only if tput is available)
    if command -v tput >/dev/null 2>&1 && [ -n "$TERM" ]; then
        tput cnorm 2>/dev/null >/dev/tty || true
        trap - INT TERM
    fi
    
    # Return selected items
    local result=()
    for ((i=0; i<num_options; i++)); do
        if [[ ${selected[i]} -eq 1 ]]; then
            result+=("${options[i]}")
        fi
    done
    
    printf '%s\n' "${result[@]}"
}

# Display checklist frame
display_checklist_frame() {
    local title="$1"
    shift
    local num_options=$(($# / 2))
    local -a options=("${@:1:$num_options}")
    local -a selected=("${@:$((num_options+1))}")
    
    # All display output goes to stderr or /dev/tty to keep stdout clean
    {
        # Draw title box
        echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}" >&2
        printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title" >&2
        echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}" >&2
        echo >&2
        
        # Display options with checkboxes
        local i=1
        for ((idx=0; idx<num_options; idx++)); do
            local checkbox="[ ]"
            [[ ${selected[idx]} -eq 1 ]] && checkbox="[✓]"
            
            if [[ $i -eq $MENU_POSITION ]]; then
                echo -e "${CYAN}▶ ${checkbox} ${BRIGHT}${options[idx]}${COLOR_RESET}" >&2
            else
                echo -e "  ${checkbox} ${DIM}${options[idx]}${COLOR_RESET}" >&2
            fi
            ((i++))
        done
        
        echo >&2
        echo -e "${DIM}Use ↑/↓ to navigate, Space to select, Enter to confirm${COLOR_RESET}" >&2
    }
}

# Radio button menu (single selection)
show_radio_menu() {
    local title="$1"
    local current="$2"
    shift 2
    local options=("$@")
    
    # Find current selection index
    local current_idx=0
    for ((i=0; i<${#options[@]}; i++)); do
        if [[ "${options[i]}" == "$current" ]]; then
            current_idx=$((i+1))
            break
        fi
    done
    
    MENU_POSITION=${current_idx:-1}
    local selection=$(show_menu "$title" "${options[@]}")
    echo "$selection"
}

# Progress menu with cancel option
show_progress_menu() {
    local title="$1"
    local message="$2"
    local -n progress_var=$3
    local -n cancel_var=$4
    
    # Run in background
    (
        while [[ ${cancel_var} -eq 0 ]] && [[ ${progress_var} -lt 100 ]]; do
            clear
            echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
            printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
            echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
            echo
            echo -e "${message}"
            echo
            print_progress ${progress_var} 40
            echo
            echo -e "${DIM}Press 'c' to cancel${COLOR_RESET}"
            sleep 0.1
        done
    ) &
    
    local bg_pid=$!
    
    # Wait for input or completion
    while kill -0 $bg_pid 2>/dev/null; do
        IFS= read -rsn1 -t 0.1 key
        if [[ "$key" == "c" ]] || [[ "$key" == "C" ]]; then
            cancel_var=1
            kill $bg_pid 2>/dev/null
            wait $bg_pid 2>/dev/null
            return 1
        fi
    done
    
    return 0
}

# Input dialog
show_input_dialog() {
    local title="$1"
    local prompt="$2"
    local default="$3"
    local validation_func="${4:-}"
    
    clear
    echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
    printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
    echo
    echo -e "${prompt}"
    
    if [[ -n "$default" ]]; then
        echo -e "${DIM}(default: $default)${COLOR_RESET}"
    fi
    
    echo
    
    local input
    while true; do
        read -er -p "> " input
        
        # Use default if empty
        if [[ -z "$input" ]] && [[ -n "$default" ]]; then
            input="$default"
        fi
        
        # Validate if function provided
        if [[ -n "$validation_func" ]]; then
            if $validation_func "$input"; then
                break
            else
                echo -e "${RED}Invalid input. Please try again.${COLOR_RESET}"
            fi
        else
            break
        fi
    done
    
    echo "$input"
}

# List selection with filtering
show_filtered_list() {
    local title="$1"
    shift
    local items=("$@")
    local filtered_items=("${items[@]}")
    local filter=""
    local selected=""
    
    while true; do
        clear
        echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
        printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
        echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
        echo
        echo -e "Filter: ${YELLOW}$filter${COLOR_RESET}_"
        echo -e "${DIM}Type to filter, ↑/↓ to select, Enter to confirm, Esc to cancel${COLOR_RESET}"
        echo
        
        # Apply filter
        if [[ -n "$filter" ]]; then
            filtered_items=()
            for item in "${items[@]}"; do
                if [[ "${item,,}" == *"${filter,,}"* ]]; then
                    filtered_items+=("$item")
                fi
            done
        fi
        
        # Display filtered items
        if [[ ${#filtered_items[@]} -eq 0 ]]; then
            echo -e "${DIM}No items match filter${COLOR_RESET}"
        else
            selected=$(show_menu "Select Item" "${filtered_items[@]}")
            if [[ -n "$selected" ]]; then
                echo "$selected"
                return 0
            fi
        fi
        
        # Read input for filtering
        IFS= read -sn1 key
        case "$key" in
            $'\x1b') # Escape
                return 1
                ;;
            $'\x7f'|$'\b') # Backspace
                filter="${filter%?}"
                ;;
            '') # Enter
                if [[ ${#filtered_items[@]} -eq 1 ]]; then
                    echo "${filtered_items[0]}"
                    return 0
                fi
                ;;
            *)
                if [[ "$key" =~ ^[[:print:]]$ ]]; then
                    filter="${filter}${key}"
                fi
                ;;
        esac
    done
}

# Export menu functions
export -f show_menu confirm_menu confirm_action show_checklist show_radio_menu
export -f show_progress_menu show_input_dialog show_filtered_list
