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
    
    echo -e "${CYAN}Leonardo USB Deployment${COLOR_RESET}"
    echo "========================"
    echo ""
    
    # Step 1: Detect or select USB device
    if [[ -z "$target_device" ]]; then
        echo "Detecting USB drives..."
        local devices=$(detect_usb_drives)
        
        if [[ -z "$devices" ]]; then
            log_message "ERROR" "No USB drives detected"
            echo ""
            echo "Please insert a USB drive and try again."
            return 1
        fi
        
        # Show available devices
        list_usb_drives
        echo ""
        
        # Let user select
        read -p "Enter device path (e.g., /dev/sdb): " target_device
        
        if [[ -z "$target_device" ]]; then
            log_message "ERROR" "No device selected"
            return 1
        fi
    fi
    
    # Validate device
    if ! is_usb_device "$target_device"; then
        log_message "ERROR" "Not a valid USB device: $target_device"
        return 1
    fi
    
    # Step 2: Check USB health
    echo ""
    echo -e "${YELLOW}Checking USB health...${COLOR_RESET}"
    init_usb_device "$target_device" >/dev/null 2>&1
    
    local health_status
    if command -v smartctl >/dev/null 2>&1; then
        health_status=$(check_usb_smart_health "$target_device" 2>/dev/null | grep "SMART overall-health" || echo "Health check unavailable")
        echo "Health: $health_status"
    fi
    
    # Check write cycles if available
    local write_cycles=$(estimate_write_cycles 2>/dev/null || echo "unknown")
    if [[ "$write_cycles" != "unknown" ]]; then
        echo "Estimated write cycles: $write_cycles"
        if [[ $write_cycles -gt 5000 ]]; then
            echo "${COLOR_YELLOW}Warning: This USB has high write cycles${COLOR_RESET}"
        fi
    fi
    
    # Step 3: Initialize USB
    echo ""
    
    # Ask about formatting
    if [[ "$options" != *"format"* ]]; then
        echo -e "${YELLOW}Format USB drive?${COLOR_RESET}"
        echo -e "${DIM}This will erase all data on the drive${COLOR_RESET}"
        if confirm_action "Format USB drive"; then
            options="${options} format"
        fi
        echo ""
    fi
    
    if ! confirm_action "Initialize USB for Leonardo"; then
        return 1
    fi
    
    echo ""
    echo -e "${CYAN}Initializing USB...${COLOR_RESET}"
    
    # Format if requested
    if [[ "$options" == *"format"* ]]; then
        local filesystem="${USB_FORMAT_TYPE:-exfat}"
        if ! format_usb_drive "$target_device" "$filesystem" "LEONARDO"; then
            return 1
        fi
    fi
    
    # Initialize and mount
    if ! init_usb_device "$target_device"; then
        return 1
    fi
    
    # Check space
    if ! check_usb_free_space "$LEONARDO_USB_MOUNT" $((USB_DEPLOY_MIN_SPACE_GB * 1024)); then
        log_message "ERROR" "Insufficient space. Need at least ${USB_DEPLOY_MIN_SPACE_GB}GB"
        return 1
    fi
    
    echo "Available space: ${LEONARDO_USB_FREE}"
    
    # Step 4: Create Leonardo structure
    echo ""
    echo -e "${CYAN}Creating Leonardo structure...${COLOR_RESET}"
    if ! create_leonardo_structure "$LEONARDO_USB_MOUNT"; then
        return 1
    fi
    
    # Step 5: Install Leonardo
    echo ""
    echo -e "${CYAN}Installing Leonardo...${COLOR_RESET}"
    
    local leonardo_script="./leonardo.sh"
    if [[ ! -f "$leonardo_script" ]]; then
        # Try to build it
        if [[ -f "assembly/build-simple.sh" ]]; then
            echo "Building Leonardo..."
            (cd assembly && ./build-simple.sh) || return 1
        else
            log_message "ERROR" "Leonardo script not found"
            return 1
        fi
    fi
    
    copy_leonardo_to_usb "$leonardo_script" "$LEONARDO_USB_MOUNT"
    
    # Step 6: Configure for first run
    echo ""
    echo -e "${CYAN}Configuring Leonardo...${COLOR_RESET}"
    configure_usb_leonardo
    
    # Step 7: Optionally install models
    if [[ "$options" != *"no-models"* ]]; then
        echo ""
        if confirm_action "Install AI models now"; then
            deploy_models_to_usb
        fi
    fi
    
    # Step 8: Create autorun (if supported)
    if [[ "$options" == *"autorun"* ]]; then
        create_usb_autorun
    fi
    
    # Step 9: Final verification
    echo ""
    echo -e "${CYAN}Verifying deployment...${COLOR_RESET}"
    verify_usb_deployment
    
    # Success!
    echo ""
    echo -e "${GREEN}✓ Leonardo successfully deployed to USB!${COLOR_RESET}"
    echo ""
    echo "To use Leonardo:"
    echo "1. Safely eject this USB drive"
    echo "2. Insert into any computer"
    echo "3. Run leonardo.sh (Linux/Mac) or leonardo.bat (Windows)"
    echo ""
    echo "USB Mount: $LEONARDO_USB_MOUNT"
    
    return 0
}

# Copy Leonardo to USB
copy_leonardo_to_usb() {
    local leonardo_script="$1"
    local target_dir="$2"
    
    # Copy Leonardo script
    echo -e "${CYAN}→ Copying Leonardo executable...${COLOR_RESET}"
    
    # Use copy with progress if file is large enough
    local leonardo_size=$(stat -f%z "$leonardo_script" 2>/dev/null || stat -c%s "$leonardo_script" 2>/dev/null || echo "0")
    
    if [[ $leonardo_size -gt 1048576 ]]; then  # > 1MB
        copy_with_progress "$leonardo_script" "$target_dir/leonardo.sh" "Installing Leonardo"
    else
        # Small file, just copy normally
        cp "$leonardo_script" "$target_dir/leonardo.sh"
        echo -e "${GREEN}✓ Leonardo installed${COLOR_RESET}"
    fi
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
    
    echo -e "${CYAN}Downloading ${model_id}${COLOR_RESET}"
    
    # Check if we have Ollama provider
    if command_exists ollama; then
        # Use Ollama to pull the model
        echo "Using Ollama to download model..."
        ollama pull "${model_id}:${variant}" 2>&1 | \
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
                echo -e "${GREEN}✓ Model downloaded successfully${COLOR_RESET}"
                return 0
            fi
        done
    else
        # Direct download from registry
        echo "Downloading from model registry..."
        
        # Get model URL from registry (mock for now)
        local model_url="https://huggingface.co/TheBloke/${model_id}-GGUF/resolve/main/${model_id}.${variant}.gguf"
        local output_file="$target_dir/${model_id}-${variant}.gguf"
        
        # Download with progress
        download_with_progress "$model_url" "$output_file" "Downloading ${model_id} (${variant})"
    fi
    
    return $?
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

# Export deployment functions
export -f deploy_to_usb configure_usb_leonardo deploy_models_to_usb
export -f download_model_to_usb create_usb_autorun verify_usb_deployment
export -f quick_deploy_to_usb get_usb_deployment_status
