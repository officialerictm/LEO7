#!/bin/bash
source ./leonardo.sh

# Override deploy_to_usb with debug version
original_deploy_to_usb=$(declare -f deploy_to_usb)
deploy_to_usb() {
    echo "DEBUG: deploy_to_usb called" >&2
    echo "DEBUG: Terminal status: $(tty)" >&2
    echo "DEBUG: TERM=$TERM" >&2
    
    # Call original function
    eval "${original_deploy_to_usb#*\{}"
    local ret=$?
    
    echo "DEBUG: deploy_to_usb returned: $ret" >&2
    echo "Press Enter to continue..." >&2
    read
    return $ret
}

# Run interactive menu
interactive_main_menu
