#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Network Transfer Module
# ==============================================================================
# Description: File transfer functionality (upload, sync, share)
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, validation.sh
# ==============================================================================

# Upload file
upload_file() {
    local file="$1"
    local destination="$2"
    local method="${3:-auto}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    case "$method" in
        "curl")
            upload_with_curl "$file" "$destination"
            ;;
        "rsync")
            upload_with_rsync "$file" "$destination"
            ;;
        "scp")
            upload_with_scp "$file" "$destination"
            ;;
        "auto")
            if command_exists "rsync"; then
                upload_with_rsync "$file" "$destination"
            elif command_exists "scp"; then
                upload_with_scp "$file" "$destination"
            elif command_exists "curl"; then
                upload_with_curl "$file" "$destination"
            else
                log_message "ERROR" "No suitable upload method found"
                return 1
            fi
            ;;
        *)
            log_message "ERROR" "Unknown upload method: $method"
            return 1
            ;;
    esac
}

# Upload with curl
upload_with_curl() {
    local file="$1"
    local url="$2"
    
    log_message "INFO" "Uploading with curl: $(basename "$file")"
    
    if curl -f -T "$file" "$url"; then
        log_message "INFO" "Upload successful"
        return 0
    else
        log_message "ERROR" "Upload failed"
        return 1
    fi
}

# Upload with rsync
upload_with_rsync() {
    local file="$1"
    local destination="$2"
    
    log_message "INFO" "Uploading with rsync: $(basename "$file")"
    
    rsync -avz --progress "$file" "$destination"
}

# Upload with scp
upload_with_scp() {
    local file="$1"
    local destination="$2"
    
    log_message "INFO" "Uploading with scp: $(basename "$file")"
    
    scp -p "$file" "$destination"
}

# Create temporary share link
create_share_link() {
    local file="$1"
    local expire_hours="${2:-24}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    # Use transfer.sh for temporary file sharing
    if command_exists "curl"; then
        log_message "INFO" "Creating share link for: $(basename "$file")"
        
        local response=$(curl -s --upload-file "$file" "https://transfer.sh/$(basename "$file")")
        
        if [[ -n "$response" ]]; then
            echo "${COLOR_GREEN}Share link:${COLOR_RESET} $response"
            echo "${COLOR_YELLOW}Expires in $expire_hours hours${COLOR_RESET}"
            return 0
        fi
    fi
    
    log_message "ERROR" "Failed to create share link"
    return 1
}

# Sync directory
sync_directory() {
    local source="$1"
    local destination="$2"
    local method="${3:-rsync}"
    
    if [[ ! -d "$source" ]]; then
        log_message "ERROR" "Source directory not found: $source"
        return 1
    fi
    
    case "$method" in
        "rsync")
            sync_with_rsync "$source" "$destination"
            ;;
        "cp")
            sync_with_cp "$source" "$destination"
            ;;
        *)
            log_message "ERROR" "Unknown sync method: $method"
            return 1
            ;;
    esac
}

# Sync with rsync
sync_with_rsync() {
    local source="$1"
    local destination="$2"
    
    log_message "INFO" "Syncing with rsync: $source -> $destination"
    
    rsync -avz --delete --progress "$source/" "$destination/"
}

# Sync with cp
sync_with_cp() {
    local source="$1"
    local destination="$2"
    
    log_message "INFO" "Syncing with cp: $source -> $destination"
    
    cp -R "$source"/* "$destination/"
}

# Transfer between systems
transfer_between_systems() {
    local source_system="$1"
    local source_path="$2"
    local dest_system="$3"
    local dest_path="$4"
    
    log_message "INFO" "Transferring: $source_system:$source_path -> $dest_system:$dest_path"
    
    if command_exists "rsync"; then
        rsync -avz --progress "$source_system:$source_path" "$dest_system:$dest_path"
    elif command_exists "scp"; then
        # Use intermediate transfer
        local temp_file="$LEONARDO_TEMP_DIR/transfer_$$"
        scp "$source_system:$source_path" "$temp_file" && \
        scp "$temp_file" "$dest_system:$dest_path"
        rm -f "$temp_file"
    else
        log_message "ERROR" "No suitable transfer method found"
        return 1
    fi
}

# Check connectivity
check_connectivity() {
    local host="${1:-8.8.8.8}"
    local port="${2:-443}"
    local timeout="${3:-5}"
    
    if command_exists "nc"; then
        nc -z -w "$timeout" "$host" "$port" 2>/dev/null
    elif command_exists "timeout"; then
        timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null
    else
        ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1
    fi
}

# Test transfer speed
test_transfer_speed() {
    local destination="$1"
    local test_size="${2:-10M}"
    
    echo "${COLOR_CYAN}Testing transfer speed to $destination...${COLOR_RESET}"
    
    # Create test file
    local test_file="$LEONARDO_TEMP_DIR/speedtest_$$"
    dd if=/dev/zero of="$test_file" bs=1M count=10 2>/dev/null
    
    local start_time=$(date +%s)
    
    if upload_file "$test_file" "$destination"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ $duration -gt 0 ]]; then
            local speed=$((10485760 / duration))  # 10MB in bytes
            echo "Transfer speed: $(format_bytes $speed)/s"
        fi
    else
        echo "${COLOR_RED}Speed test failed${COLOR_RESET}"
    fi
    
    rm -f "$test_file"
}

# Create model package
create_model_package() {
    local model_id="$1"
    local output_file="$2"
    
    log_message "INFO" "Creating model package for: $model_id"
    
    # Get model info
    local model_file=$(get_model_metadata "$model_id" "filename")
    local model_path="$LEONARDO_MODEL_DIR/$model_file"
    
    if [[ ! -f "$model_path" ]]; then
        log_message "ERROR" "Model file not found: $model_path"
        return 1
    fi
    
    # Create package directory
    local package_dir="$LEONARDO_TEMP_DIR/package_$$"
    mkdir -p "$package_dir"
    
    # Copy model and metadata
    cp "$model_path" "$package_dir/"
    
    # Create metadata file
    cat > "$package_dir/metadata.json" << EOF
{
  "model_id": "$model_id",
  "name": "$(get_model_metadata "$model_id" "name")",
  "size": "$(get_model_metadata "$model_id" "size")",
  "format": "$(get_model_metadata "$model_id" "format")",
  "quantization": "$(get_model_metadata "$model_id" "quantization")",
  "family": "$(get_model_metadata "$model_id" "family")",
  "license": "$(get_model_metadata "$model_id" "license")",
  "sha256": "$(get_model_metadata "$model_id" "sha256")",
  "packaged_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    # Create archive
    tar -czf "$output_file" -C "$package_dir" .
    
    # Cleanup
    rm -rf "$package_dir"
    
    log_message "INFO" "Model package created: $output_file"
    return 0
}

# Extract model package
extract_model_package() {
    local package_file="$1"
    local extract_dir="${2:-$LEONARDO_MODEL_DIR}"
    
    if [[ ! -f "$package_file" ]]; then
        log_message "ERROR" "Package file not found: $package_file"
        return 1
    fi
    
    log_message "INFO" "Extracting model package: $package_file"
    
    # Create temporary extraction directory
    local temp_dir="$LEONARDO_TEMP_DIR/extract_$$"
    mkdir -p "$temp_dir"
    
    # Extract package
    if tar -xzf "$package_file" -C "$temp_dir"; then
        # Check for metadata
        if [[ -f "$temp_dir/metadata.json" ]]; then
            # Move model file
            local model_files=$(find "$temp_dir" -name "*.gguf" -o -name "*.bin" -o -name "*.safetensors")
            for file in $model_files; do
                mv "$file" "$extract_dir/"
                log_message "INFO" "Extracted: $(basename "$file")"
            done
            
            # Process metadata
            # TODO: Import metadata into registry
            
            rm -rf "$temp_dir"
            return 0
        else
            log_message "ERROR" "Invalid package: missing metadata"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        log_message "ERROR" "Failed to extract package"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Export transfer functions
export -f upload_file create_share_link sync_directory
export -f transfer_between_systems check_connectivity test_transfer_speed
export -f create_model_package extract_model_package
