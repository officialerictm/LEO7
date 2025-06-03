#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Local Deployment Module
# ==============================================================================
# Description: Deploy Leonardo and AI models to local systems
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh, models/*.sh, checksum.sh
# ==============================================================================

# Local deployment paths
LOCAL_INSTALL_PREFIX="${LOCAL_INSTALL_PREFIX:-$HOME/.leonardo}"
LOCAL_BIN_PATH="${LOCAL_BIN_PATH:-$HOME/.local/bin}"
LOCAL_DESKTOP_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

# Deploy Leonardo locally
deploy_to_local() {
    local install_path="${1:-$LOCAL_INSTALL_PREFIX}"
    local options="${2:-}"
    
    echo "${COLOR_CYAN}Leonardo Local Deployment${COLOR_RESET}"
    echo "========================="
    echo ""
    
    # Step 1: Check system
    echo "${COLOR_YELLOW}Checking system...${COLOR_RESET}"
    check_local_system
    
    # Step 2: Select installation path
    if [[ "$options" != *"auto"* ]]; then
        echo ""
        echo "Default installation path: $install_path"
        read -p "Use this path? (Y/n): " response
        
        if [[ "${response,,}" == "n" ]]; then
            read -p "Enter installation path: " custom_path
            if [[ -n "$custom_path" ]]; then
                install_path="$custom_path"
            fi
        fi
    fi
    
    # Expand path
    install_path=$(eval echo "$install_path")
    
    # Step 3: Check if already installed
    if [[ -d "$install_path" ]] && [[ -f "$install_path/leonardo.sh" ]]; then
        echo ""
        echo "${COLOR_YELLOW}Leonardo is already installed at: $install_path${COLOR_RESET}"
        
        if ! confirm_action "Reinstall/Update Leonardo"; then
            return 0
        fi
    fi
    
    # Step 4: Create installation directory
    echo ""
    echo "${COLOR_CYAN}Creating installation directory...${COLOR_RESET}"
    if ! ensure_directory "$install_path"; then
        log_message "ERROR" "Failed to create installation directory"
        return 1
    fi
    
    # Step 5: Install Leonardo
    echo ""
    echo "${COLOR_CYAN}Installing Leonardo...${COLOR_RESET}"
    if ! install_leonardo_local "$install_path"; then
        return 1
    fi
    
    # Step 6: Create system integration
    echo ""
    echo "${COLOR_CYAN}Creating system integration...${COLOR_RESET}"
    create_local_integration "$install_path"
    
    # Step 7: Configure Leonardo
    echo ""
    echo "${COLOR_CYAN}Configuring Leonardo...${COLOR_RESET}"
    configure_local_leonardo "$install_path"
    
    # Step 8: Optionally install models
    if [[ "$options" != *"no-models"* ]]; then
        echo ""
        if confirm_action "Install AI models now"; then
            deploy_models_to_local "$install_path"
        fi
    fi
    
    # Step 9: Verify installation
    echo ""
    echo "${COLOR_CYAN}Verifying installation...${COLOR_RESET}"
    verify_local_deployment "$install_path"
    
    # Success!
    echo ""
    echo "${COLOR_GREEN}✓ Leonardo successfully installed!${COLOR_RESET}"
    echo ""
    echo "Installation path: $install_path"
    echo ""
    echo "To use Leonardo:"
    echo "1. Run: leonardo"
    echo "2. Or: $install_path/leonardo.sh"
    echo ""
    
    # Update shell if needed
    if [[ "$options" != *"no-shell"* ]]; then
        update_shell_config "$install_path"
    fi
    
    return 0
}

# Check local system
check_local_system() {
    local platform=$(detect_platform)
    
    echo "Platform: $platform"
    echo "Architecture: $(uname -m)"
    echo "Shell: $SHELL"
    
    # Check disk space
    local available_space
    case "$platform" in
        "macos")
            available_space=$(df -g "$HOME" | awk 'NR==2 {print $4}')
            echo "Available space: ${available_space}GB"
            ;;
        "linux")
            available_space=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
            echo "Available space: ${available_space}GB"
            ;;
        "windows")
            # WSL or Git Bash
            available_space=$(df -BG "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//')
            if [[ -n "$available_space" ]]; then
                echo "Available space: ${available_space}GB"
            fi
            ;;
    esac
    
    # Check dependencies
    echo ""
    echo "Checking dependencies..."
    local deps=("curl" "tar" "gzip")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "${COLOR_YELLOW}Missing dependencies: ${missing[*]}${COLOR_RESET}"
        echo "Please install them before continuing."
        return 1
    else
        echo "✓ All dependencies satisfied"
    fi
}

# Install Leonardo locally
install_leonardo_local() {
    local install_path="$1"
    local leonardo_script="./leonardo.sh"
    
    # Build if necessary
    if [[ ! -f "$leonardo_script" ]]; then
        if [[ -f "assembly/build-simple.sh" ]]; then
            echo "Building Leonardo..."
            (cd assembly && ./build-simple.sh) || return 1
        else
            log_message "ERROR" "Leonardo script not found"
            return 1
        fi
    fi
    
    # Copy Leonardo
    echo "Copying Leonardo..."
    cp "$leonardo_script" "$install_path/" || return 1
    chmod +x "$install_path/leonardo.sh"
    
    # Create directory structure
    echo "Creating directory structure..."
    local dirs=("models" "cache" "config" "logs" "data" "scripts" "backups" "temp")
    
    for dir in "${dirs[@]}"; do
        ensure_directory "$install_path/$dir"
    done
    
    # Copy assets if available
    if [[ -d "assets" ]]; then
        cp -r assets "$install_path/"
    fi
    
    # Create VERSION file
    echo "$LEONARDO_VERSION" > "$install_path/VERSION"
    
    log_message "SUCCESS" "Leonardo installed to $install_path"
    return 0
}

# Create local system integration
create_local_integration() {
    local install_path="$1"
    local platform=$(detect_platform)
    
    # Create command link
    ensure_directory "$LOCAL_BIN_PATH"
    
    # Create wrapper script
    local wrapper="$LOCAL_BIN_PATH/leonardo"
    cat > "$wrapper" << EOF
#!/usr/bin/env bash
# Leonardo AI Universal launcher
exec "$install_path/leonardo.sh" "\$@"
EOF
    chmod +x "$wrapper"
    echo "✓ Command 'leonardo' created"
    
    # Platform-specific integration
    case "$platform" in
        "linux")
            create_desktop_entry "$install_path"
            ;;
        "macos")
            create_macos_app "$install_path"
            ;;
        "windows")
            create_windows_shortcut "$install_path"
            ;;
    esac
}

# Create Linux desktop entry
create_desktop_entry() {
    local install_path="$1"
    
    ensure_directory "$LOCAL_DESKTOP_PATH"
    
    cat > "$LOCAL_DESKTOP_PATH/leonardo.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Leonardo AI Universal
Comment=Deploy AI models anywhere
Icon=$install_path/assets/leonardo.png
Exec=$install_path/leonardo.sh
Terminal=true
Categories=Development;Science;
Keywords=AI;ML;LLM;Models;
EOF
    
    # Update desktop database if available
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$LOCAL_DESKTOP_PATH" 2>/dev/null
    fi
    
    echo "✓ Desktop entry created"
}

# Create macOS app bundle
create_macos_app() {
    local install_path="$1"
    local app_path="$HOME/Applications/Leonardo.app"
    
    # Create app structure
    ensure_directory "$app_path/Contents/MacOS"
    ensure_directory "$app_path/Contents/Resources"
    
    # Create launcher
    cat > "$app_path/Contents/MacOS/Leonardo" << EOF
#!/bin/bash
cd "$install_path"
open -a Terminal "$install_path/leonardo.sh"
EOF
    chmod +x "$app_path/Contents/MacOS/Leonardo"
    
    # Create Info.plist
    cat > "$app_path/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Leonardo</string>
    <key>CFBundleIdentifier</key>
    <string>ai.leonardo.universal</string>
    <key>CFBundleName</key>
    <string>Leonardo AI Universal</string>
    <key>CFBundleVersion</key>
    <string>$LEONARDO_VERSION</string>
    <key>CFBundleIconFile</key>
    <string>leonardo.icns</string>
</dict>
</plist>
EOF
    
    echo "✓ macOS app created"
}

# Create Windows shortcut (for WSL/Git Bash)
create_windows_shortcut() {
    local install_path="$1"
    local desktop="$HOME/Desktop"
    
    if [[ -d "$desktop" ]]; then
        # Create batch file
        cat > "$desktop/Leonardo.bat" << EOF
@echo off
title Leonardo AI Universal
bash "$install_path/leonardo.sh" %*
pause
EOF
        echo "✓ Desktop shortcut created"
    fi
}

# Configure local Leonardo
configure_local_leonardo() {
    local install_path="$1"
    local config_file="$install_path/config/leonardo.conf"
    
    cat > "$config_file" << EOF
# Leonardo AI Universal - Local Configuration
# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Deployment type
LEONARDO_DEPLOYMENT_TYPE="local"

# Local paths
LEONARDO_BASE_DIR="$install_path"
LEONARDO_MODEL_DIR="\$LEONARDO_BASE_DIR/models"
LEONARDO_CACHE_DIR="\$LEONARDO_BASE_DIR/cache"
LEONARDO_CONFIG_DIR="\$LEONARDO_BASE_DIR/config"
LEONARDO_LOG_DIR="\$LEONARDO_BASE_DIR/logs"
LEONARDO_DATA_DIR="\$LEONARDO_BASE_DIR/data"

# Performance settings
LEONARDO_CACHE_SIZE_MB="2048"
LEONARDO_MAX_THREADS="0"  # 0 = auto-detect

# Update settings
LEONARDO_AUTO_UPDATE="true"
LEONARDO_UPDATE_CHANNEL="stable"
EOF
    
    log_message "SUCCESS" "Local configuration created"
}

# Deploy models to local installation
deploy_models_to_local() {
    local install_path="$1"
    local model_dir="$install_path/models"
    
    # Set model directory
    export LEONARDO_MODEL_DIR="$model_dir"
    
    echo ""
    echo "${COLOR_CYAN}Model Installation${COLOR_RESET}"
    echo ""
    
    # Check disk space
    local available_gb
    available_gb=$(df -BG "$install_path" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "unknown")
    
    if [[ "$available_gb" != "unknown" ]]; then
        echo "Available space: ${available_gb}GB"
        echo ""
    fi
    
    # Show recommendations
    echo "${COLOR_CYAN}Recommended starter models:${COLOR_RESET}"
    echo "1. Llama 3.2 (3B) - Fast and capable"
    echo "2. Mistral 7B - Excellent general purpose"
    echo "3. Gemma 2B - Lightweight option"
    echo ""
    
    # Let user select models
    local continue_selection=true
    
    while [[ "$continue_selection" == "true" ]]; do
        select_model_interactive
        
        if [[ -z "$SELECTED_MODEL_ID" ]]; then
            break
        fi
        
        # Download model
        echo ""
        download_model "$SELECTED_MODEL_ID"
        
        echo ""
        if ! confirm_action "Install another model"; then
            continue_selection=false
        fi
    done
}

# Verify local deployment
verify_local_deployment() {
    local install_path="$1"
    local checks_passed=0
    local checks_total=0
    
    # Check 1: Leonardo executable
    ((checks_total++))
    if [[ -f "$install_path/leonardo.sh" ]] && [[ -x "$install_path/leonardo.sh" ]]; then
        echo "✓ Leonardo executable found"
        ((checks_passed++))
    else
        echo "✗ Leonardo executable missing"
    fi
    
    # Check 2: Directory structure
    ((checks_total++))
    local required_dirs=("models" "config" "logs" "cache")
    local dirs_ok=true
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$install_path/$dir" ]]; then
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
    if [[ -f "$install_path/config/leonardo.conf" ]]; then
        echo "✓ Configuration file present"
        ((checks_passed++))
    else
        echo "✗ Configuration file missing"
    fi
    
    # Check 4: Command availability
    ((checks_total++))
    if command -v leonardo >/dev/null 2>&1; then
        echo "✓ 'leonardo' command available"
        ((checks_passed++))
    else
        echo "✗ 'leonardo' command not in PATH"
    fi
    
    echo ""
    echo "Verification: $checks_passed/$checks_total checks passed"
    
    return $((checks_total - checks_passed))
}

# Update shell configuration
update_shell_config() {
    local install_path="$1"
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$LOCAL_BIN_PATH:"* ]]; then
        echo ""
        echo "${COLOR_YELLOW}Adding Leonardo to PATH...${COLOR_RESET}"
        
        # Detect shell config file
        local shell_config=""
        case "$SHELL" in
            */bash)
                shell_config="$HOME/.bashrc"
                ;;
            */zsh)
                shell_config="$HOME/.zshrc"
                ;;
            */fish)
                shell_config="$HOME/.config/fish/config.fish"
                ;;
        esac
        
        if [[ -n "$shell_config" ]] && [[ -f "$shell_config" ]]; then
            # Check if already added
            if ! grep -q "leonardo.*PATH" "$shell_config"; then
                echo "" >> "$shell_config"
                echo "# Leonardo AI Universal" >> "$shell_config"
                echo "export PATH=\"\$PATH:$LOCAL_BIN_PATH\"" >> "$shell_config"
                echo "✓ PATH updated in $shell_config"
                echo ""
                echo "Run 'source $shell_config' or restart your terminal"
            fi
        fi
    fi
}

# Uninstall Leonardo
uninstall_leonardo_local() {
    local install_path="${1:-$LOCAL_INSTALL_PREFIX}"
    
    echo "${COLOR_YELLOW}Uninstalling Leonardo...${COLOR_RESET}"
    echo ""
    
    if [[ ! -d "$install_path" ]]; then
        echo "Leonardo not found at: $install_path"
        return 1
    fi
    
    if ! confirm_action "Remove Leonardo and all data"; then
        return 0
    fi
    
    # Remove installation
    echo "Removing $install_path..."
    rm -rf "$install_path"
    
    # Remove command
    if [[ -f "$LOCAL_BIN_PATH/leonardo" ]]; then
        rm -f "$LOCAL_BIN_PATH/leonardo"
    fi
    
    # Remove desktop entry
    if [[ -f "$LOCAL_DESKTOP_PATH/leonardo.desktop" ]]; then
        rm -f "$LOCAL_DESKTOP_PATH/leonardo.desktop"
    fi
    
    # Remove macOS app
    if [[ -d "$HOME/Applications/Leonardo.app" ]]; then
        rm -rf "$HOME/Applications/Leonardo.app"
    fi
    
    echo ""
    echo "${COLOR_GREEN}✓ Leonardo uninstalled${COLOR_RESET}"
}

# Export deployment functions
export -f deploy_to_local check_local_system install_leonardo_local
export -f create_local_integration configure_local_leonardo
export -f deploy_models_to_local verify_local_deployment
export -f update_shell_config uninstall_leonardo_local
