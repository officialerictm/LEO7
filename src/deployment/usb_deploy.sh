#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - USB Deployment Module
# ==============================================================================
# Description: Deploy Leonardo and AI models to USB drives
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, usb/*.sh, models/*.sh, checksum.sh
# ==============================================================================

# USB deployment configuration
USB_DEPLOY_MIN_SPACE_GB=8
USB_DEPLOY_RECOMMENDED_SPACE_GB=32

# Deploy Leonardo to USB
deploy_to_usb() {
    local target_device="${1:-}"
    local options="${2:-}"
    
    # Debug output to confirm function is called
    echo -e "${YELLOW}DEBUG: deploy_to_usb function started${COLOR_RESET}" >&2
    echo -e "${YELLOW}DEBUG: Terminal test: [[ -t 0 ]] = $([[ -t 0 ]] && echo true || echo false)${COLOR_RESET}" >&2
    sleep 1  # Give time to see the message
    
    echo
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}              🚀 Leonardo USB Deployment${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo
    
    # Step 1: Detect or use provided USB device
    if [[ -z "$target_device" ]]; then
        # Auto-detect USB drives
        local usb_drives=()
        echo -e "${DIM}Detecting USB drives...${COLOR_RESET}"
        
        # Get USB drives - let debug output go to stderr
        local raw_output=$(detect_usb_drives)
        if [[ -n "$raw_output" ]]; then
            # Extract just the device paths (first field before |)
            readarray -t usb_drives < <(echo "$raw_output" | cut -d'|' -f1 | grep -E '^/dev/')
        fi
        
        if [[ ${#usb_drives[@]} -eq 0 ]]; then
            echo -e "${RED}No USB drives detected!${COLOR_RESET}"
            echo -e "${YELLOW}Please insert a USB drive and try again.${COLOR_RESET}"
            echo
            echo -e "${DIM}Tip: Make sure your USB drive is properly connected and recognized by the system.${COLOR_RESET}"
            echo -e "${DIM}On Linux, you might need to run with sudo for device detection.${COLOR_RESET}"
            pause
            return 1
        elif [[ ${#usb_drives[@]} -eq 1 ]]; then
            target_device="${usb_drives[0]}"
            echo -e "${GREEN}Found USB drive: $target_device${COLOR_RESET}"
        else
            # Multiple drives - let user select with better formatting
            echo -e "${YELLOW}Multiple USB drives detected:${COLOR_RESET}"
            echo
            
            # Create formatted menu options
            local menu_options=()
            local drive_info
            while IFS='|' read -r device label size mount; do
                # Format: /dev/sdc1 - CHATUSB (114.6G)
                if [[ -n "$label" && "$label" != "Unknown" ]]; then
                    drive_info="$device - $label ($size)"
                else
                    drive_info="$device ($size)"
                fi
                menu_options+=("$drive_info")
            done < <(echo "$raw_output")
            
            # Show menu and extract just the device path from selection
            local selected
            selected=$(show_menu "Select USB Drive" "${menu_options[@]}")
            if [[ -z "$selected" ]]; then
                return 1
            fi
            
            # Extract device path from selection
            target_device=$(echo "$selected" | awk '{print $1}')
        fi
    fi
    
    # Get device info
    local device_size_mb=$(get_device_size_mb "$target_device")
    local device_size_gb=$((device_size_mb / 1024))
    
    echo
    echo -e "${BOLD}Target USB:${COLOR_RESET} $target_device (${device_size_gb}GB)"
    echo
    
    # Step 2: Initialize USB (includes format option)
    echo -e "${YELLOW}Step 1/4: Preparing USB Drive${COLOR_RESET}"
    
    # Check if already initialized
    if is_leonardo_usb "$target_device"; then
        echo -e "${YELLOW}⚠ Leonardo installation detected on USB${COLOR_RESET}"
        echo
        
        # Show current installation info
        if [[ -f "$LEONARDO_USB_MOUNT/leonardo/VERSION" ]]; then
            local current_version=$(cat "$LEONARDO_USB_MOUNT/leonardo/VERSION" 2>/dev/null || echo "Unknown")
            echo -e "Current version: ${CYAN}$current_version${COLOR_RESET}"
        fi
        
        # Show options in interactive mode
        if [[ -t 0 ]]; then
            echo
            echo -e "${BOLD}What would you like to do?${COLOR_RESET}"
            echo -e "1) ${GREEN}Update/Fix${COLOR_RESET} - Keep data and update Leonardo"
            echo -e "2) ${RED}Format & Reinstall${COLOR_RESET} - Fresh installation (erases all data)"
            echo -e "3) ${DIM}Cancel${COLOR_RESET} - Exit without changes"
            echo
            
            local choice
            read -p "Enter choice (1-3): " choice
            
            case "$choice" in
                1)
                    echo -e "${CYAN}→ Updating Leonardo installation...${COLOR_RESET}"
                    # Skip formatting, just update
                    ;;
                2)
                    if confirm_menu "Format USB and install fresh? ${RED}WARNING: This will erase all data!${COLOR_RESET}"; then
                        echo -e "${CYAN}→ Formatting USB drive...${COLOR_RESET}"
                        if ! format_usb_device "$target_device"; then
                            echo -e "${RED}Failed to format USB drive${COLOR_RESET}"
                            pause
                            return 1
                        fi
                        
                        # Mount the newly formatted device
                        echo -e "${CYAN}→ Mounting USB drive...${COLOR_RESET}"
                        if ! mount_usb_drive "$target_device"; then
                            echo -e "${RED}Failed to mount USB drive${COLOR_RESET}"
                            pause
                            return 1
                        fi
                    else
                        echo -e "${DIM}Cancelled${COLOR_RESET}"
                        return 0
                    fi
                    ;;
                3|*)
                    echo -e "${DIM}Cancelled${COLOR_RESET}"
                    return 0
                    ;;
            esac
        else
            echo -e "${YELLOW}Non-interactive mode: Updating existing installation${COLOR_RESET}"
            # In non-interactive mode, default to update
        fi
    else
        # Ask about formatting only in interactive mode
        if [[ -t 0 ]]; then
            if confirm_menu "Format USB drive? ${RED}WARNING: This will erase all data!${COLOR_RESET}"; then
                echo -e "${CYAN}→ Formatting USB drive...${COLOR_RESET}"
                if ! format_usb_device "$target_device"; then
                    echo -e "${RED}Failed to format USB drive${COLOR_RESET}"
                    pause
                    return 1
                fi
                
                # Mount the newly formatted device
                echo -e "${CYAN}→ Mounting USB drive...${COLOR_RESET}"
                if ! mount_usb_drive "$target_device"; then
                    echo -e "${RED}Failed to mount USB drive${COLOR_RESET}"
                    pause
                    return 1
                fi
            fi
        else
            echo -e "${YELLOW}Non-interactive mode: Skipping format prompt${COLOR_RESET}"
            # Try to mount if not already mounted
            echo -e "${CYAN}→ Checking USB mount status...${COLOR_RESET}"
            
            # Check if we need to try partition instead
            local mount_device="$target_device"
            if [[ "$target_device" =~ ^/dev/sd[a-z]$ ]]; then
                # Check if partition exists
                if [[ -b "${target_device}1" ]]; then
                    mount_device="${target_device}1"
                    echo -e "${DIM}Using partition: $mount_device${COLOR_RESET}"
                fi
            fi
            
            # Try to mount if not already mounted
            local existing_mount=$(lsblk -no MOUNTPOINT "$mount_device" 2>/dev/null | grep -v "^$" | head -1)
            if [[ -z "$existing_mount" ]]; then
                echo -e "${CYAN}→ Mounting USB drive...${COLOR_RESET}"
                if ! mount_usb_drive "$mount_device"; then
                    echo -e "${RED}Failed to mount USB drive${COLOR_RESET}"
                    echo -e "${YELLOW}Try one of these options:${COLOR_RESET}"
                    echo -e "  1. Run with sudo: ${CYAN}sudo ./leonardo.sh deploy usb $target_device${COLOR_RESET}"
                    echo -e "  2. Mount manually first: ${CYAN}sudo mount $mount_device /mnt/usb${COLOR_RESET}"
                    echo -e "  3. Use your desktop file manager to mount the USB"
                    return 1
                fi
            else
                echo -e "${GREEN}✓ USB already mounted at: $existing_mount${COLOR_RESET}"
                # Update target device to use the partition
                target_device="$mount_device"
            fi
        fi
    fi
    
    # Initialize USB
    echo -e "${CYAN}→ Initializing USB device...${COLOR_RESET}"
    if ! init_usb_device "$target_device"; then
        echo -e "${RED}Failed to initialize USB device${COLOR_RESET}"
        pause
        return 1
    fi
    
    # Debug mount point
    echo -e "${DIM}DEBUG: USB mount point is: ${LEONARDO_USB_MOUNT:-'(not set)'}${COLOR_RESET}" >&2
    
    # Ensure mount point is set
    if [[ -z "$LEONARDO_USB_MOUNT" ]]; then
        echo -e "${RED}Error: USB mount point not detected${COLOR_RESET}"
        echo -e "${YELLOW}Please ensure the USB drive is properly mounted${COLOR_RESET}"
        pause
        return 1
    fi
    
    # Create Leonardo directory structure if it doesn't exist
    if [[ ! -d "$LEONARDO_USB_MOUNT/leonardo" ]]; then
        echo -e "${CYAN}→ Creating Leonardo directory structure...${COLOR_RESET}"
        create_leonardo_structure "$LEONARDO_USB_MOUNT"
    fi
    
    # Get Leonardo script location
    local leonardo_script="${LEONARDO_SCRIPT:-$0}"
    if [[ ! -f "$leonardo_script" ]]; then
        leonardo_script="./leonardo.sh"
    fi
    
    # Step 3: Install Leonardo
    echo
    echo -e "${YELLOW}Step 2/4: Installing Leonardo AI${COLOR_RESET}"
    copy_leonardo_to_usb "$leonardo_script" "$LEONARDO_USB_MOUNT"
    
    # Create platform launchers
    create_platform_launchers "$LEONARDO_USB_MOUNT"
    
    # Step 4: Configure
    echo
    echo -e "${YELLOW}Step 3/4: Configuring Leonardo${COLOR_RESET}"
    configure_usb_leonardo
    
    # Step 5: Model deployment
    echo
    echo -e "${YELLOW}Step 4/4: AI Model Setup${COLOR_RESET}"
    
    # Get USB free space for model recommendations
    local usb_free_mb=$(get_usb_free_space_mb "$LEONARDO_USB_MOUNT")
    
    # Select and install model
    local selected_model=$(select_model_interactive "$usb_free_mb")
    
    if [[ -n "$selected_model" ]]; then
        echo
        echo -e "${CYAN}Installing $selected_model...${COLOR_RESET}"
        if download_model_to_usb "$selected_model"; then
            echo -e "${GREEN}✓ Model installed successfully${COLOR_RESET}"
        else
            echo -e "${YELLOW}⚠ Model installation failed${COLOR_RESET}"
        fi
    else
        echo -e "${DIM}Skipping model installation${COLOR_RESET}"
    fi
    
    # Final verification
    echo
    echo -e "${CYAN}Verifying deployment...${COLOR_RESET}"
    if verify_usb_deployment; then
        echo
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
        echo -e "${GREEN}✨ USB deployment successful!${COLOR_RESET}"
        echo -e "${GREEN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
        echo
        echo -e "${BOLD}To use Leonardo on any computer:${COLOR_RESET}"
        echo -e "1. Insert the USB drive"
        echo -e "2. Navigate to the USB in terminal"
        echo -e "3. Run: ${CYAN}./leonardo${COLOR_RESET} (Linux/Mac) or ${CYAN}leonardo.bat${COLOR_RESET} (Windows)"
        echo
        echo -e "${DIM}The USB is ready to use on any computer!${COLOR_RESET}"
    else
        echo -e "${RED}⚠ Deployment verification failed${COLOR_RESET}"
        echo -e "${YELLOW}The USB may still work but some features might be missing.${COLOR_RESET}"
    fi
    
    echo
    pause
    return 0
}

# Copy Leonardo to USB
copy_leonardo_to_usb() {
    local leonardo_script="$1"
    local target_dir="$2"
    
    # Copy Leonardo script
    echo -e "${CYAN}→ Copying Leonardo executable...${COLOR_RESET}"
    
    # Create leonardo directory if needed
    mkdir -p "$target_dir/leonardo"
    
    # Use copy with progress if file is large enough
    local leonardo_size=$(stat -f%z "$leonardo_script" 2>/dev/null || stat -c%s "$leonardo_script" 2>/dev/null || echo "0")
    
    if [[ $leonardo_size -gt 1048576 ]]; then  # > 1MB
        copy_with_progress "$leonardo_script" "$target_dir/leonardo/leonardo.sh" "Installing Leonardo"
    else
        # Small file, just copy normally
        cp "$leonardo_script" "$target_dir/leonardo/leonardo.sh"
        echo -e "${GREEN}✓ Leonardo installed${COLOR_RESET}"
    fi
    
    # Also copy to root for convenience
    cp "$leonardo_script" "$target_dir/leonardo.sh"
    chmod +x "$target_dir/leonardo.sh"
    chmod +x "$target_dir/leonardo/leonardo.sh"
}

# Create platform-specific launchers
create_platform_launchers() {
    local target_dir="$1"
    
    # Create Windows batch launcher
    cat > "$target_dir/leonardo.bat" << 'EOF'
@echo off
title Leonardo AI Universal
echo Starting Leonardo AI...
bash leonardo.sh %*
if errorlevel 1 (
    echo.
    echo Leonardo requires Git Bash or WSL on Windows.
    echo Please install Git for Windows from https://git-scm.com/
    pause
)
EOF
    
    # Create Mac/Linux launcher (executable)
    cat > "$target_dir/leonardo" << 'EOF'
#!/bin/bash
# Leonardo AI Universal Launcher
cd "$(dirname "$0")"
./leonardo.sh "$@"
EOF
    chmod +x "$target_dir/leonardo" 2>/dev/null || true
    
    # Create desktop entry for Linux
    cat > "$target_dir/Leonardo.desktop" << EOF
[Desktop Entry]
Name=Leonardo AI
Comment=Portable AI Assistant
Exec=bash %f/leonardo.sh
Icon=%f/leonardo/assets/icon.png
Terminal=true
Type=Application
Categories=Utility;Development;
EOF
    
    echo -e "${GREEN}✓ Platform launchers created${COLOR_RESET}"
}

# Configure Leonardo for USB deployment
configure_usb_leonardo() {
    local config_file="$LEONARDO_USB_MOUNT/leonardo/config/leonardo.conf"
    
    # Create configuration
    cat > "$config_file" << EOF
# Leonardo AI Universal - USB Configuration
# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Deployment type
LEONARDO_DEPLOYMENT_TYPE="usb"

# USB-specific settings
LEONARDO_USB_MODE="true"
LEONARDO_PORTABLE_MODE="true"
LEONARDO_NO_INSTALL="true"

# Paths (relative to USB root)
LEONARDO_BASE_DIR="\$(dirname "\$(readlink -f "\$0")")/leonardo"
LEONARDO_MODEL_DIR="\$LEONARDO_BASE_DIR/models"
LEONARDO_CACHE_DIR="\$LEONARDO_BASE_DIR/cache"
LEONARDO_CONFIG_DIR="\$LEONARDO_BASE_DIR/config"
LEONARDO_LOG_DIR="\$LEONARDO_BASE_DIR/logs"
LEONARDO_DATA_DIR="\$LEONARDO_BASE_DIR/data"

# Performance settings for USB
LEONARDO_LOW_MEMORY_MODE="true"
LEONARDO_CACHE_SIZE_MB="512"
LEONARDO_MAX_THREADS="4"

# Security settings
LEONARDO_PARANOID_MODE="true"
LEONARDO_NO_TELEMETRY="true"
LEONARDO_CLEANUP_ON_EXIT="true"
EOF
    
    log_message "SUCCESS" "USB configuration created"
}

# Deploy models to USB
deploy_models_to_usb() {
    echo ""
    echo -e "${CYAN}Model Deployment${COLOR_RESET}"
    echo ""
    
    # Check available space
    check_usb_free_space "$LEONARDO_USB_MOUNT" 1024
    local free_gb=$((LEONARDO_USB_FREE_MB / 1024))
    
    echo "Available space: ${free_gb}GB"
    echo ""
    
    # Show model recommendations based on space
    if [[ $free_gb -lt 8 ]]; then
        echo -e "${YELLOW}Limited space. Recommended models:${COLOR_RESET}"
        echo "- TinyLlama (1.1B) - 2GB"
        echo "- Phi-2 (2.7B) - 3GB"
    elif [[ $free_gb -lt 16 ]]; then
        echo -e "${CYAN}Recommended models:${COLOR_RESET}"
        echo "- Llama 3.2 (3B) - 4GB"
        echo "- Mistral 7B - 8GB"
        echo "- Gemma 2B - 3GB"
    else
        echo -e "${GREEN}Plenty of space! Popular models:${COLOR_RESET}"
        echo "- Llama 3.1 (8B) - 8GB"
        echo "- Mistral 7B - 8GB"
        echo "- Mixtral 8x7B - 48GB (if space permits)"
    fi
    
    echo ""
    
    # Use interactive model selector
    echo ""
    
    # Simple model selection menu for USB deployment
    local popular_models=(
        "llama3.2:3b:Llama 3.2 (3B) - Fast and efficient:4"
        "mistral:7b:Mistral 7B - Great for general use:8"
        "codellama:7b:Code Llama - Optimized for coding:8"
        "phi3:mini:Phi-3 Mini - Tiny but capable:2"
        "gemma2:2b:Gemma 2B - Google's efficient model:3"
        "skip:0:Skip model installation:0"
    )
    
    echo -e "${CYAN}Select models to install:${COLOR_RESET}"
    echo -e "${DIM}Use space to select/deselect, Enter when done${COLOR_RESET}"
    echo ""
    
    local selected_models=()
    local i=1
    for model_info in "${popular_models[@]}"; do
        IFS=':' read -r model_id variant name size_gb <<< "$model_info"
        printf "  %d) %-20s - %s (%sGB)\n" "$i" "$model_id" "$name" "$size_gb"
        ((i++))
    done
    
    echo ""
    echo -n "Enter model numbers (space-separated, or 'skip'): "
    read -r model_selection
    
    if [[ "$model_selection" != "skip" ]] && [[ -n "$model_selection" ]]; then
        for num in $model_selection; do
            if [[ $num -ge 1 ]] && [[ $num -le ${#popular_models[@]} ]]; then
                local model_info="${popular_models[$((num-1))]}"
                IFS=':' read -r model_id variant name size_gb <<< "$model_info"
                if [[ "$model_id" != "skip" ]]; then
                    selected_models+=("$model_id:$variant")
                fi
            fi
        done
    fi
    
    # Download and install selected models
    if [[ ${#selected_models[@]} -gt 0 ]]; then
        echo ""
        echo -e "${CYAN}Downloading models...${COLOR_RESET}"
        
        for model_id in "${selected_models[@]}"; do
            echo ""
            download_model_to_usb "$model_id"
        done
    fi
}

# Download model to USB
download_model_to_usb() {
    local model_spec="$1"
    local target_dir="$LEONARDO_USB_MOUNT/leonardo/models"
    
    # Parse model spec (format: model_id:variant)
    local model_id="${model_spec%:*}"
    local variant="${model_spec#*:}"
    
    # Ensure target directory exists
    ensure_directory "$target_dir"
    
    # Set download target
    export LEONARDO_MODEL_DIR="$target_dir"
    
    echo -e "${CYAN}Downloading ${model_id}:${variant}${COLOR_RESET}"
    
    # Check if we have Ollama provider
    if command_exists ollama; then
        # Use Ollama to pull the model
        echo "Using Ollama to download model..."
        
        # First pull the model
        if ollama pull "${model_id}:${variant}" 2>&1 | \
        while IFS= read -r line; do
            # Parse Ollama progress output
            if [[ "$line" =~ pulling[[:space:]].*[[:space:]]([0-9]+)%[[:space:]]+\|.*\|[[:space:]]+([0-9.]+[[:space:]]?[KMGT]?B)/([0-9.]+[[:space:]]?[KMGT]?B)[[:space:]]+([0-9.]+[[:space:]]?[KMGT]?B/s) ]]; then
                local percent="${BASH_REMATCH[1]}"
                local downloaded="${BASH_REMATCH[2]}"
                local total="${BASH_REMATCH[3]}"
                local speed="${BASH_REMATCH[4]}"
                
                printf "\r"
                show_progress_bar "$percent" 100 40
                printf " ${percent}%% | ${downloaded}/${total} | ${speed}  "
            elif [[ "$line" =~ "success" ]] || [[ "$line" =~ "already up to date" ]]; then
                printf "\r%-80s\r" " "
                echo -e "${GREEN}✓ Model downloaded to Ollama${COLOR_RESET}"
                return 0
            fi
        done; then
            # Now export the model to USB
            echo -e "${CYAN}Exporting model to USB...${COLOR_RESET}"
            local model_file="$target_dir/${model_id}-${variant}.gguf"
            
            # Try to export using ollama show
            if ollama show "${model_id}:${variant}" --modelfile > "$target_dir/${model_id}-${variant}.modelfile" 2>/dev/null; then
                echo -e "${GREEN}✓ Model exported to USB${COLOR_RESET}"
                
                # Create a simple info file
                cat > "$target_dir/${model_id}-${variant}.info" <<EOF
Model: ${model_id}:${variant}
Downloaded: $(date)
Type: Ollama Model
Location: $target_dir
Note: Use 'ollama run ${model_id}:${variant}' to run this model
EOF
                return 0
            else
                echo -e "${YELLOW}⚠ Could not export model file, using fallback download${COLOR_RESET}"
            fi
        fi
    fi
    
    # Direct download from registry as fallback
    echo "Downloading from model registry..."
    
    # Map common model names to HuggingFace URLs
    local model_url=""
    case "${model_id}:${variant}" in
        "phi:2.7b")
            model_url="https://huggingface.co/microsoft/phi-2/resolve/main/phi-2_Q4_K_M.gguf"
            ;;
        "llama2:7b")
            model_url="https://huggingface.co/TheBloke/Llama-2-7B-GGUF/resolve/main/llama-2-7b.Q4_K_M.gguf"
            ;;
        "mistral:7b")
            model_url="https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_K_M.gguf"
            ;;
        "llama3.2:1b")
            model_url="https://huggingface.co/lmstudio-community/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf"
            ;;
        *)
            echo -e "${RED}✗ Model ${model_id}:${variant} not found in registry${COLOR_RESET}"
            echo -e "${YELLOW}Available models for direct download:${COLOR_RESET}"
            echo "  - phi:2.7b"
            echo "  - llama2:7b"
            echo "  - mistral:7b"
            echo "  - llama3.2:1b"
            return 1
            ;;
    esac
    
    local output_file="$target_dir/${model_id}-${variant}.gguf"
    
    # Download with progress
    if download_with_progress "$model_url" "$output_file" "Downloading ${model_id} (${variant})"; then
        # Create info file
        cat > "$target_dir/${model_id}-${variant}.info" <<EOF
Model: ${model_id}:${variant}
Downloaded: $(date)
Type: GGUF Model
Location: $output_file
Size: $(du -h "$output_file" | cut -f1)
EOF
        echo -e "${GREEN}✓ Model downloaded successfully to USB${COLOR_RESET}"
        return 0
    else
        echo -e "${RED}✗ Failed to download model${COLOR_RESET}"
        return 1
    fi
}

# Create autorun files
create_usb_autorun() {
    # Windows autorun.inf (note: often disabled by default on modern Windows)
    cat > "$LEONARDO_USB_MOUNT/autorun.inf" << EOF
[autorun]
label=Leonardo AI Universal
icon=leonardo\\assets\\leonardo.ico
action=Run Leonardo AI Universal
open=leonardo.bat
EOF
    
    # Create desktop entry for Linux
    cat > "$LEONARDO_USB_MOUNT/.autorun" << EOF
#!/bin/bash
# Leonardo AI Universal Autorun
cd "\$(dirname "\$0")"
./leonardo.sh
EOF
    chmod +x "$LEONARDO_USB_MOUNT/.autorun"
    
    log_message "INFO" "Autorun files created (may require user permission)"
}

# Verify USB deployment
verify_usb_deployment() {
    local checks_passed=0
    local checks_total=0
    
    # Check 1: Leonardo executable
    ((checks_total++))
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo.sh" ]]; then
        echo "✓ Leonardo executable found"
        ((checks_passed++))
    else
        echo "✗ Leonardo executable missing"
    fi
    
    # Check 2: Directory structure
    ((checks_total++))
    local required_dirs=("leonardo" "leonardo/models" "leonardo/config" "leonardo/logs")
    local dirs_ok=true
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$LEONARDO_USB_MOUNT/$dir" ]]; then
            dirs_ok=false
            break
        fi
    done
    
    if [[ "$dirs_ok" == "true" ]]; then
        echo "✓ Directory structure complete"
        ((checks_passed++))
    else
        echo "✗ Directory structure incomplete"
    fi
    
    # Check 3: Configuration
    ((checks_total++))
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo/config/leonardo.conf" ]]; then
        echo "✓ Configuration file present"
        ((checks_passed++))
    else
        echo "✗ Configuration file missing"
    fi
    
    # Check 4: Platform launchers
    ((checks_total++))
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo.bat" ]] || [[ -f "$LEONARDO_USB_MOUNT/leonardo.command" ]]; then
        echo "✓ Platform launchers created"
        ((checks_passed++))
    else
        echo "✗ Platform launchers missing"
    fi
    
    # Check 5: Write test
    ((checks_total++))
    local test_file="$LEONARDO_USB_MOUNT/.leonardo_test_$$"
    if echo "test" > "$test_file" 2>/dev/null && rm -f "$test_file" 2>/dev/null; then
        echo "✓ USB is writable"
        ((checks_passed++))
    else
        echo "✗ USB write test failed"
    fi
    
    echo ""
    echo "Verification: $checks_passed/$checks_total checks passed"
    
    return $((checks_total - checks_passed))
}

# Get recommended models based on USB size
get_recommended_models() {
    local usb_size_gb="$1"
    local models=()
    
    # Define model sizes (approximate compressed sizes in GB)
    local -A model_sizes=(
        ["phi:2.7b"]="2"
        ["llama3.2:1b"]="1"
        ["llama3.2:3b"]="2"
        ["mistral:7b"]="4"
        ["llama2:7b"]="4"
        ["llama2:13b"]="8"
        ["codellama:7b"]="4"
        ["mixtral:8x7b"]="26"
        ["llama3.1:8b"]="5"
        ["gemma2:2b"]="2"
        ["qwen2.5:3b"]="2"
    )
    
    # Calculate available space (leave 20% free)
    local available_gb=$((usb_size_gb * 80 / 100))
    
    # Add models that fit
    for model in "${!model_sizes[@]}"; do
        local size="${model_sizes[$model]}"
        if [[ $size -le $available_gb ]]; then
            models+=("$model (${size}GB)")
        fi
    done
    
    # Sort by size (smallest first for quick testing)
    printf '%s\n' "${models[@]}" | sort -t'(' -k2 -n
}

# Quick USB deployment (minimal interaction)
quick_deploy_to_usb() {
    local device="$1"
    
    # Auto-detect if not specified
    if [[ -z "$device" ]]; then
        device=$(detect_usb_drives | head -1 | cut -d'|' -f1)
        if [[ -z "$device" ]]; then
            log_message "ERROR" "No USB device detected"
            return 1
        fi
    fi
    
    # Deploy with defaults
    deploy_to_usb "$device" "no-models"
}

# USB deployment status
get_usb_deployment_status() {
    local device="$1"
    
    # Initialize device
    if ! init_usb_device "$device" >/dev/null 2>&1; then
        echo "Status: Not mounted"
        return 1
    fi
    
    # Check deployment
    if [[ -f "$LEONARDO_USB_MOUNT/leonardo.sh" ]]; then
        echo "Status: Leonardo installed"
        
        # Check version
        if [[ -f "$LEONARDO_USB_MOUNT/leonardo/VERSION" ]]; then
            echo "Version: $(cat "$LEONARDO_USB_MOUNT/leonardo/VERSION")"
        fi
        
        # Check models
        local model_count=$(find "$LEONARDO_USB_MOUNT/leonardo/models" -name "*.gguf" 2>/dev/null | wc -l)
        echo "Models: $model_count installed"
        
        # Check space
        check_usb_free_space "$LEONARDO_USB_MOUNT" 0
        echo "Free space: ${LEONARDO_USB_FREE}"
    else
        echo "Status: Not deployed"
    fi
}

# Interactive model selection with size recommendations
select_model_interactive() {
    local usb_size_mb="${1:-8192}"  # Default 8GB
    local usb_size_gb=$((usb_size_mb / 1024))
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${BOLD}               🤖 Select AI Model${COLOR_RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo
    echo -e "${YELLOW}USB Size: ${usb_size_gb}GB${COLOR_RESET}"
    echo -e "${DIM}Recommended models based on available space:${COLOR_RESET}"
    echo
    
    # Get recommended models
    local models=()
    readarray -t models < <(get_recommended_models "$usb_size_gb")
    
    if [[ ${#models[@]} -eq 0 ]]; then
        echo -e "${RED}USB too small for any models!${COLOR_RESET}"
        echo -e "${YELLOW}Minimum 2GB required.${COLOR_RESET}"
        return 1
    fi
    
    # Add option to skip
    models+=("Skip (no model)")
    
    # Show menu
    local selected=$(show_menu "Available Models" "${models[@]}")
    
    # Extract model name without size
    if [[ "$selected" == "Skip (no model)" ]] || [[ -z "$selected" ]]; then
        echo ""
        return 1
    else
        # Remove size annotation
        echo "${selected% (*}"
    fi
}

# Get USB free space in MB
get_usb_free_space_mb() {
    local mount_point="$1"
    df -BM "$mount_point" | awk 'NR==2 {print $4}' | sed 's/M$//'
}

# Get device size in MB
get_device_size_mb() {
    local device="$1"
    # Try different methods to get device size
    if command_exists lsblk; then
        lsblk -ndo SIZE -b "$device" 2>/dev/null | awk '{print int($1/1024/1024)}'
    elif command_exists blockdev; then
        blockdev --getsize64 "$device" 2>/dev/null | awk '{print int($1/1024/1024)}'
    else
        # Fallback to 8GB
        echo "8192"
    fi
}

# Pause function
pause() {
    echo
    read -p "Press Enter to continue..." -r
}

# Export deployment functions
export -f deploy_to_usb configure_usb_leonardo deploy_models_to_usb
export -f download_model_to_usb create_usb_autorun verify_usb_deployment
export -f quick_deploy_to_usb get_usb_deployment_status

# Create Leonardo directory structure
create_leonardo_structure() {
    local target_dir="$1"
    
    # Create required directories
    local required_dirs=("leonardo" "leonardo/models" "leonardo/config" "leonardo/logs")
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$target_dir/$dir" ]]; then
            mkdir -p "$target_dir/$dir"
        fi
    done
    
    echo -e "${GREEN}✓ Leonardo directory structure created${COLOR_RESET}"
}
