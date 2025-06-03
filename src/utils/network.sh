#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Network Utilities
# ==============================================================================
# Description: Network operations, downloads, and connectivity checks
# Version: 7.0.0
# Dependencies: logging.sh, colors.sh, validation.sh
# ==============================================================================

# Check internet connectivity
check_connectivity() {
    local timeout="${1:-5}"
    local test_hosts=("8.8.8.8" "1.1.1.1" "google.com")
    
    log_message "INFO" "Checking internet connectivity..."
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W "$timeout" "$host" >/dev/null 2>&1; then
            log_message "DEBUG" "Connectivity check passed: $host"
            return 0
        fi
    done
    
    log_message "ERROR" "No internet connectivity detected"
    return 1
}

# Download file with progress
download_file() {
    local url="$1"
    local output_file="$2"
    local expected_checksum="${3:-}"
    local checksum_algo="${4:-sha256}"
    
    log_message "INFO" "Downloading: $url"
    log_message "DEBUG" "Output: $output_file"
    
    # Create output directory if needed
    local output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir"
    
    # Determine download tool
    local downloader=""
    if command -v curl >/dev/null 2>&1; then
        downloader="curl"
    elif command -v wget >/dev/null 2>&1; then
        downloader="wget"
    else
        log_message "ERROR" "No download tool available (need curl or wget)"
        return 1
    fi
    
    # Download with retry logic
    local retry=0
    local max_retries=$LEONARDO_DOWNLOAD_RETRIES
    
    while [[ $retry -le $max_retries ]]; do
        log_message "INFO" "Download attempt $((retry + 1)) of $((max_retries + 1))"
        
        if [[ "$downloader" == "curl" ]]; then
            if download_with_curl "$url" "$output_file"; then
                break
            fi
        else
            if download_with_wget "$url" "$output_file"; then
                break
            fi
        fi
        
        retry=$((retry + 1))
        if [[ $retry -le $max_retries ]]; then
            log_message "WARN" "Download failed, retrying in 5 seconds..."
            sleep 5
        fi
    done
    
    if [[ $retry -gt $max_retries ]]; then
        log_message "ERROR" "Download failed after $max_retries retries"
        return 1
    fi
    
    # Verify checksum if provided
    if [[ -n "$expected_checksum" ]]; then
        log_message "INFO" "Verifying checksum..."
        if ! validate_checksum "$output_file" "$expected_checksum" "$checksum_algo"; then
            safe_delete "$output_file"
            return 1
        fi
        log_message "INFO" "Checksum verified successfully"
    fi
    
    return 0
}

# Download with curl
download_with_curl() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.tmp"
    
    # Build curl command
    local curl_cmd=(
        curl
        --location                           # Follow redirects
        --fail                              # Fail on HTTP errors
        --silent                            # Silent mode
        --show-error                        # Show errors
        --connect-timeout "$LEONARDO_DOWNLOAD_TIMEOUT"
        --max-time 0                        # No timeout for download
        --retry 0                           # We handle retries ourselves
        --user-agent "$LEONARDO_USER_AGENT"
        --output "$temp_file"
    )
    
    # Add resume support if file exists
    if [[ -f "$temp_file" ]]; then
        curl_cmd+=(--continue-at -)
    fi
    
    # Show progress if not quiet
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        curl_cmd+=(--progress-bar)
    fi
    
    # Execute download
    "${curl_cmd[@]}" "$url" 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ ^[[:space:]]*([0-9]+)[[:space:]]+([0-9.]+[KMG]?)[[:space:]]+ ]]; then
            local percent="${BASH_REMATCH[1]}"
            print_progress "$percent" 50
        elif [[ -n "$line" ]]; then
            log_message "DEBUG" "curl: $line"
        fi
    done
    
    # Move temp file to final location
    if [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$output_file"
        return 0
    else
        return 1
    fi
}

# Download with wget
download_with_wget() {
    local url="$1"
    local output_file="$2"
    local temp_file="${output_file}.tmp"
    
    # Build wget command
    local wget_cmd=(
        wget
        --quiet                             # Quiet mode
        --timeout="$LEONARDO_DOWNLOAD_TIMEOUT"
        --tries=1                          # We handle retries ourselves
        --user-agent="$LEONARDO_USER_AGENT"
        --output-document="$temp_file"
    )
    
    # Add resume support if file exists
    if [[ -f "$temp_file" ]]; then
        wget_cmd+=(--continue)
    fi
    
    # Show progress if not quiet
    if [[ "$LEONARDO_QUIET" != "true" ]]; then
        wget_cmd+=(--show-progress)
    fi
    
    # Execute download
    "${wget_cmd[@]}" "$url" 2>&1 | while IFS= read -r line; do
        if [[ "$line" =~ ([0-9]+)% ]]; then
            local percent="${BASH_REMATCH[1]}"
            print_progress "$percent" 50
        elif [[ -n "$line" ]]; then
            log_message "DEBUG" "wget: $line"
        fi
    done
    
    # Move temp file to final location
    if [[ -f "$temp_file" ]]; then
        mv "$temp_file" "$output_file"
        return 0
    else
        return 1
    fi
}

# Download with parallel chunks (for large files)
download_parallel() {
    local url="$1"
    local output_file="$2"
    local num_chunks="${3:-4}"
    
    log_message "INFO" "Starting parallel download with $num_chunks chunks"
    
    # Get file size
    local file_size=$(get_remote_file_size "$url")
    if [[ -z "$file_size" ]] || [[ "$file_size" -eq 0 ]]; then
        log_message "WARN" "Cannot determine file size, falling back to regular download"
        return download_file "$url" "$output_file"
    fi
    
    local chunk_size=$((file_size / num_chunks))
    local temp_dir=$(create_temp_dir "leonardo-download")
    local pids=()
    
    # Download chunks in parallel
    for ((i=0; i<num_chunks; i++)); do
        local start=$((i * chunk_size))
        local end=$((start + chunk_size - 1))
        
        # Last chunk goes to end of file
        if [[ $i -eq $((num_chunks - 1)) ]]; then
            end=$((file_size - 1))
        fi
        
        local chunk_file="$temp_dir/chunk_$i"
        
        (
            download_range "$url" "$chunk_file" "$start" "$end"
        ) &
        
        pids+=($!)
    done
    
    # Wait for all downloads to complete
    local failed=false
    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            failed=true
        fi
    done
    
    if [[ "$failed" == "true" ]]; then
        log_message "ERROR" "One or more chunks failed to download"
        safe_delete "$temp_dir"
        return 1
    fi
    
    # Combine chunks
    log_message "INFO" "Combining chunks..."
    > "$output_file"
    for ((i=0; i<num_chunks; i++)); do
        cat "$temp_dir/chunk_$i" >> "$output_file"
    done
    
    # Cleanup
    safe_delete "$temp_dir"
    
    log_message "INFO" "Parallel download completed"
    return 0
}

# Download a byte range
download_range() {
    local url="$1"
    local output_file="$2"
    local start="$3"
    local end="$4"
    
    log_message "DEBUG" "Downloading range: bytes=$start-$end"
    
    if command -v curl >/dev/null 2>&1; then
        curl -s -L -H "Range: bytes=$start-$end" \
             --user-agent "$LEONARDO_USER_AGENT" \
             --output "$output_file" \
             "$url"
    else
        wget -q --header="Range: bytes=$start-$end" \
             --user-agent="$LEONARDO_USER_AGENT" \
             -O "$output_file" \
             "$url"
    fi
}

# Get remote file size
get_remote_file_size() {
    local url="$1"
    local size=""
    
    if command -v curl >/dev/null 2>&1; then
        size=$(curl -sI -L "$url" | grep -i "content-length" | tail -1 | awk '{print $2}' | tr -d '\r')
    else
        size=$(wget --spider -S "$url" 2>&1 | grep -i "content-length" | tail -1 | awk '{print $2}')
    fi
    
    echo "${size:-0}"
}

# Upload file (for telemetry or backups)
upload_file() {
    local file="$1"
    local url="$2"
    local method="${3:-POST}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "Upload file not found: $file"
        return 1
    fi
    
    log_message "INFO" "Uploading $file to $url"
    
    if command -v curl >/dev/null 2>&1; then
        curl -X "$method" \
             --fail \
             --silent \
             --show-error \
             --user-agent "$LEONARDO_USER_AGENT" \
             --data-binary "@$file" \
             "$url"
    else
        log_message "ERROR" "Upload requires curl"
        return 1
    fi
}

# Check for updates
check_for_updates() {
    local current_version="$1"
    local update_url="${2:-https://api.leonardo-ai.dev/version}"
    
    log_message "INFO" "Checking for updates..."
    
    local response
    if command -v curl >/dev/null 2>&1; then
        response=$(curl -s -L --max-time 10 "$update_url" 2>/dev/null)
    else
        response=$(wget -q -O- --timeout=10 "$update_url" 2>/dev/null)
    fi
    
    if [[ -z "$response" ]]; then
        log_message "WARN" "Could not check for updates"
        return 1
    fi
    
    # Parse version from response (assumes JSON with "version" field)
    local latest_version=$(echo "$response" | grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4)
    
    if [[ -z "$latest_version" ]]; then
        log_message "WARN" "Could not parse version from response"
        return 1
    fi
    
    log_message "INFO" "Current version: $current_version"
    log_message "INFO" "Latest version: $latest_version"
    
    if [[ "$current_version" != "$latest_version" ]]; then
        echo "$latest_version"
        return 0
    else
        return 1
    fi
}

# Fetch model registry
fetch_model_registry() {
    local registry_url="${1:-$LEONARDO_MODEL_REGISTRY_URL}"
    local cache_file="${2:-$LEONARDO_MODEL_CACHE_DIR/registry.json}"
    local max_age="${3:-3600}"  # 1 hour default
    
    # Check cache
    if [[ -f "$cache_file" ]]; then
        local cache_age=$(($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null)))
        if [[ $cache_age -lt $max_age ]]; then
            log_message "DEBUG" "Using cached registry (age: ${cache_age}s)"
            cat "$cache_file"
            return 0
        fi
    fi
    
    # Fetch fresh registry
    log_message "INFO" "Fetching model registry from $registry_url"
    
    local temp_file=$(create_temp_dir)/registry.json
    if download_file "$registry_url" "$temp_file"; then
        mkdir -p "$(dirname "$cache_file")"
        mv "$temp_file" "$cache_file"
        cat "$cache_file"
        return 0
    else
        # Fall back to cache if available
        if [[ -f "$cache_file" ]]; then
            log_message "WARN" "Using stale cache due to download failure"
            cat "$cache_file"
            return 0
        else
            return 1
        fi
    fi
}

# Export network functions
export -f check_connectivity download_file download_parallel
export -f get_remote_file_size check_for_updates fetch_model_registry
