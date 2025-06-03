#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Network Download Module
# ==============================================================================
# Description: File download functionality with progress tracking
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, progress.sh, validation.sh
# ==============================================================================

# Download file with progress
download_file_with_progress() {
    local url="$1"
    local output_file="$2"
    local retries="${3:-$LEONARDO_DOWNLOAD_RETRIES}"
    
    # Validate inputs
    if [[ -z "$url" ]] || [[ -z "$output_file" ]]; then
        log_message "ERROR" "Invalid download parameters"
        return 1
    fi
    
    # Create output directory
    local output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir"
    
    # Check available downloaders
    local downloader=""
    if command_exists "curl"; then
        downloader="curl"
    elif command_exists "wget"; then
        downloader="wget"
    else
        log_message "ERROR" "No suitable downloader found (curl or wget required)"
        return 1
    fi
    
    log_message "INFO" "Downloading: $url"
    log_message "INFO" "Output: $output_file"
    log_message "INFO" "Using: $downloader"
    
    local attempt=1
    while [[ $attempt -le $retries ]]; do
        log_message "INFO" "Download attempt $attempt/$retries"
        
        if [[ "$downloader" == "curl" ]]; then
            if download_with_curl "$url" "$output_file"; then
                return 0
            fi
        else
            if download_with_wget "$url" "$output_file"; then
                return 0
            fi
        fi
        
        ((attempt++))
        if [[ $attempt -le $retries ]]; then
            log_message "WARN" "Download failed, retrying in 5 seconds..."
            sleep 5
        fi
    done
    
    log_message "ERROR" "Download failed after $retries attempts"
    return 1
}

# Download with curl
download_with_curl() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.tmp"
    
    # Download with progress bar
    if [[ -t 1 ]] && [[ "$LEONARDO_QUIET" != "true" ]]; then
        # Interactive mode with progress bar
        curl -L -f -# \
            --connect-timeout "$LEONARDO_TIMEOUT" \
            --retry 3 \
            --retry-delay 2 \
            -o "$temp_file" \
            "$url" 2>&1 | \
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*([0-9]+(\.[0-9]+)?)[[:space:]]+.*$ ]]; then
                local percent="${BASH_REMATCH[1]}"
                show_download_progress "$percent" "$url"
            fi
        done
    else
        # Non-interactive mode
        curl -L -f -S \
            --connect-timeout "$LEONARDO_TIMEOUT" \
            --retry 3 \
            --retry-delay 2 \
            -o "$temp_file" \
            "$url"
    fi
    
    local result=$?
    
    if [[ $result -eq 0 ]] && [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$output_file"
        return 0
    else
        rm -f "$temp_file"
        return 1
    fi
}

# Download with wget
download_with_wget() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.tmp"
    
    # Download with progress
    if [[ -t 1 ]] && [[ "$LEONARDO_QUIET" != "true" ]]; then
        # Interactive mode with progress bar
        wget --progress=bar:force \
            --timeout="$LEONARDO_TIMEOUT" \
            --tries=3 \
            --wait=2 \
            -O "$temp_file" \
            "$url" 2>&1 | \
        while IFS= read -r line; do
            if [[ "$line" =~ ([0-9]+)% ]]; then
                local percent="${BASH_REMATCH[1]}"
                show_download_progress "$percent" "$url"
            fi
        done
    else
        # Non-interactive mode
        wget -q \
            --timeout="$LEONARDO_TIMEOUT" \
            --tries=3 \
            --wait=2 \
            -O "$temp_file" \
            "$url"
    fi
    
    local result=$?
    
    if [[ $result -eq 0 ]] && [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$output_file"
        return 0
    else
        rm -f "$temp_file"
        return 1
    fi
}

# Download file (simple version without progress)
download_file() {
    local url="$1"
    local output_file="$2"
    
    if command_exists "curl"; then
        curl -L -f -s -o "$output_file" "$url"
    elif command_exists "wget"; then
        wget -q -O "$output_file" "$url"
    else
        log_message "ERROR" "No suitable downloader found"
        return 1
    fi
}

# Fetch remote file to string
fetch_remote_file() {
    local url="$1"
    
    if command_exists "curl"; then
        curl -L -f -s "$url"
    elif command_exists "wget"; then
        wget -q -O - "$url"
    else
        log_message "ERROR" "No suitable downloader found"
        return 1
    fi
}

# Download and verify file
download_and_verify() {
    local url="$1"
    local output_file="$2"
    local expected_hash="$3"
    local hash_type="${4:-sha256}"
    
    # Download file
    if ! download_file_with_progress "$url" "$output_file"; then
        return 1
    fi
    
    # Verify if hash provided
    if [[ -n "$expected_hash" ]]; then
        log_message "INFO" "Verifying file integrity..."
        
        local actual_hash=""
        case "$hash_type" in
            "sha256")
                actual_hash=$(sha256sum "$output_file" 2>/dev/null | awk '{print $1}')
                ;;
            "md5")
                actual_hash=$(md5sum "$output_file" 2>/dev/null | awk '{print $1}')
                ;;
            *)
                log_message "ERROR" "Unsupported hash type: $hash_type"
                rm -f "$output_file"
                return 1
                ;;
        esac
        
        if [[ "$actual_hash" != "$expected_hash" ]]; then
            log_message "ERROR" "Hash verification failed!"
            log_message "ERROR" "Expected: $expected_hash"
            log_message "ERROR" "Actual:   $actual_hash"
            rm -f "$output_file"
            return 1
        fi
        
        log_message "INFO" "File verified successfully"
    fi
    
    return 0
}

# Batch download files
batch_download() {
    local -n urls=$1
    local -n outputs=$2
    local parallel="${3:-1}"
    
    if [[ ${#urls[@]} -ne ${#outputs[@]} ]]; then
        log_message "ERROR" "URL and output arrays must have same length"
        return 1
    fi
    
    local total=${#urls[@]}
    local completed=0
    local failed=0
    
    echo "${COLOR_CYAN}Downloading $total files...${COLOR_RESET}"
    
    for i in "${!urls[@]}"; do
        local url="${urls[$i]}"
        local output="${outputs[$i]}"
        
        echo ""
        echo "${COLOR_YELLOW}[$((i+1))/$total] $(basename "$output")${COLOR_RESET}"
        
        if download_file_with_progress "$url" "$output"; then
            ((completed++))
        else
            ((failed++))
            log_message "ERROR" "Failed to download: $(basename "$output")"
        fi
    done
    
    echo ""
    echo "${COLOR_CYAN}Download complete:${COLOR_RESET}"
    echo "  ${COLOR_GREEN}Success: $completed${COLOR_RESET}"
    [[ $failed -gt 0 ]] && echo "  ${COLOR_RED}Failed: $failed${COLOR_RESET}"
    
    return $failed
}

# Resume download
resume_download() {
    local url="$1"
    local output_file="$2"
    
    if [[ ! -f "$output_file" ]]; then
        # No partial file, do normal download
        download_file_with_progress "$url" "$output_file"
        return $?
    fi
    
    local existing_size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null || echo 0)
    
    log_message "INFO" "Resuming download from byte $existing_size"
    
    if command_exists "curl"; then
        curl -L -f -C "$existing_size" -# -o "$output_file" "$url"
    elif command_exists "wget"; then
        wget -c --progress=bar:force -O "$output_file" "$url"
    else
        log_message "ERROR" "No suitable downloader with resume support found"
        return 1
    fi
}

# Mirror remote directory
mirror_remote_directory() {
    local remote_url="$1"
    local local_dir="$2"
    local include_pattern="${3:-*}"
    
    log_message "INFO" "Mirroring remote directory: $remote_url"
    
    mkdir -p "$local_dir"
    
    if command_exists "wget"; then
        wget -r -np -nH --cut-dirs=1 \
            -P "$local_dir" \
            -A "$include_pattern" \
            "$remote_url"
    else
        log_message "ERROR" "Directory mirroring requires wget"
        return 1
    fi
}

# Test download speed
test_download_speed() {
    local test_url="${1:-http://speedtest.tele2.net/10MB.zip}"
    local test_file="$LEONARDO_TEMP_DIR/speedtest_$$"
    
    echo "${COLOR_CYAN}Testing download speed...${COLOR_RESET}"
    
    local start_time=$(date +%s)
    
    if download_file "$test_url" "$test_file"; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local file_size=$(stat -f%z "$test_file" 2>/dev/null || stat -c%s "$test_file" 2>/dev/null || echo 0)
        
        if [[ $duration -gt 0 ]]; then
            local speed=$((file_size / duration))
            echo "Download speed: $(format_bytes $speed)/s"
        fi
        
        rm -f "$test_file"
    else
        echo "${COLOR_RED}Speed test failed${COLOR_RESET}"
        return 1
    fi
}

# Fetch model registry
fetch_model_registry() {
    local registry_url="$1"
    local output_file="$2"
    
    log_message "INFO" "Fetching model registry from: $registry_url"
    
    if download_file "$registry_url" "$output_file"; then
        log_message "INFO" "Model registry updated successfully"
        return 0
    else
        log_message "ERROR" "Failed to fetch model registry"
        return 1
    fi
}

# Export download functions
export -f download_file_with_progress download_file fetch_remote_file
export -f download_and_verify batch_download resume_download
export -f mirror_remote_directory test_download_speed fetch_model_registry
