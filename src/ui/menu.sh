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

# Display menu with arrow key navigation
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    local num_options=${#options[@]}
    
    MENU_MAX_ITEMS=$num_options
    MENU_POSITION=1
    MENU_SELECTION=""
    
    # Hide cursor
    tput civis
    
    # Trap for cleanup
    trap 'tput cnorm; echo' INT TERM
    
    while true; do
        # Clear screen and display menu
        clear
        display_menu_frame "$title" "${options[@]}"
        
        # Read user input
        read -rsn1 key
        
        case "$key" in
            # Arrow keys
            $'\x1b')
                read -rsn2 -t 0.1 key
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
            # Enter key
            '')
                MENU_SELECTION="${options[$((MENU_POSITION-1))]}"
                break
                ;;
            # Number keys for quick selection
            [1-9])
                if [[ $key -le $num_options ]]; then
                    MENU_POSITION=$key
                    MENU_SELECTION="${options[$((key-1))]}"
                    break
                fi
                ;;
            # Escape or q to quit
            $'\x1b'|q|Q)
                MENU_SELECTION=""
                break
                ;;
        esac
    done
    
    # Show cursor again
    tput cnorm
    trap - INT TERM
    
    # Return selection
    echo "$MENU_SELECTION"
}

# Display menu frame with highlighting
display_menu_frame() {
    local title="$1"
    shift
    local options=("$@")
    
    # Draw title box
    echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
    printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
    echo
    
    # Display options
    local i=1
    for option in "${options[@]}"; do
        if [[ $i -eq $MENU_POSITION ]]; then
            # Highlighted option
            echo -e "${CYAN}▶ ${BRIGHT}${option}${COLOR_RESET}"
        else
            echo -e "  ${DIM}${option}${COLOR_RESET}"
        fi
        ((i++))
    done
    
    echo
    echo -e "${DIM}Use ↑/↓ arrows or numbers to select, Enter to confirm, q to quit${COLOR_RESET}"
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
    
    # Hide cursor
    tput civis
    trap 'tput cnorm; echo' INT TERM
    
    while true; do
        clear
        display_checklist_frame "$title" "${options[@]}" "${selected[@]}"
        
        # Read user input
        read -rsn1 key
        
        case "$key" in
            $'\x1b')
                read -rsn2 -t 0.1 key
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
    
    # Show cursor again
    tput cnorm
    trap - INT TERM
    
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
    
    # Draw title box
    echo -e "${GREEN}╔════════════════════════════════════════════╗${COLOR_RESET}"
    printf "${GREEN}║${COLOR_RESET} %-42s ${GREEN}║${COLOR_RESET}\n" "$title"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${COLOR_RESET}"
    echo
    
    # Display options with checkboxes
    local i=1
    for ((idx=0; idx<num_options; idx++)); do
        local checkbox="[ ]"
        [[ ${selected[idx]} -eq 1 ]] && checkbox="[✓]"
        
        if [[ $i -eq $MENU_POSITION ]]; then
            echo -e "${CYAN}▶ ${checkbox} ${BRIGHT}${options[idx]}${COLOR_RESET}"
        else
            echo -e "  ${checkbox} ${DIM}${options[idx]}${COLOR_RESET}"
        fi
        ((i++))
    done
    
    echo
    echo -e "${DIM}Use ↑/↓ to navigate, Space to select, Enter to confirm${COLOR_RESET}"
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
        read -rsn1 -t 0.1 key
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
        read -rsn1 key
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
