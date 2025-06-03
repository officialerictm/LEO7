#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - Checksum Verification Module
# ==============================================================================
# Description: File integrity verification using multiple hash algorithms
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh
# ==============================================================================

# Supported hash algorithms
declare -A HASH_COMMANDS=(
    ["md5"]="md5sum"
    ["sha1"]="sha1sum"
    ["sha256"]="sha256sum"
    ["sha512"]="sha512sum"
)

# Platform-specific hash commands
init_hash_commands() {
    local platform=$(detect_platform)
    
    case "$platform" in
        "macos")
            HASH_COMMANDS["md5"]="md5 -r"
            HASH_COMMANDS["sha1"]="shasum -a 1"
            HASH_COMMANDS["sha256"]="shasum -a 256"
            HASH_COMMANDS["sha512"]="shasum -a 512"
            ;;
        "windows")
            # Windows using certUtil
            HASH_COMMANDS["md5"]="certutil -hashfile"
            HASH_COMMANDS["sha1"]="certutil -hashfile"
            HASH_COMMANDS["sha256"]="certutil -hashfile"
            HASH_COMMANDS["sha512"]="certutil -hashfile"
            ;;
    esac
}

# Calculate file hash
calculate_hash() {
    local file="$1"
    local algorithm="${2:-sha256}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    local hash_cmd="${HASH_COMMANDS[$algorithm]}"
    if [[ -z "$hash_cmd" ]]; then
        log_message "ERROR" "Unsupported hash algorithm: $algorithm"
        return 1
    fi
    
    local hash=""
    local platform=$(detect_platform)
    
    case "$platform" in
        "windows")
            # Windows certutil outputs differently
            hash=$(certutil -hashfile "$file" "${algorithm^^}" 2>/dev/null | grep -v ":" | tr -d ' \r\n' | tr '[:upper:]' '[:lower:]')
            ;;
        *)
            # Unix-like systems
            hash=$($hash_cmd "$file" 2>/dev/null | awk '{print $1}')
            ;;
    esac
    
    if [[ -z "$hash" ]]; then
        log_message "ERROR" "Failed to calculate $algorithm hash for $file"
        return 1
    fi
    
    echo "$hash"
    return 0
}

# Verify file checksum
verify_checksum() {
    local file="$1"
    local expected_hash="$2"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    if [[ -z "$expected_hash" ]]; then
        log_message "ERROR" "No expected hash provided"
        return 1
    fi
    
    log_message "INFO" "Verifying $algorithm checksum for $(basename "$file")..."
    
    local actual_hash
    actual_hash=$(calculate_hash "$file" "$algorithm")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Normalize hashes for comparison
    expected_hash=$(echo "$expected_hash" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    actual_hash=$(echo "$actual_hash" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    
    if [[ "$actual_hash" == "$expected_hash" ]]; then
        log_message "SUCCESS" "Checksum verification passed"
        return 0
    else
        log_message "ERROR" "Checksum verification failed"
        log_message "ERROR" "Expected: $expected_hash"
        log_message "ERROR" "Actual:   $actual_hash"
        return 1
    fi
}

# Verify checksum from file
verify_checksum_file() {
    local file="$1"
    local checksum_file="$2"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$checksum_file" ]]; then
        log_message "ERROR" "Checksum file not found: $checksum_file"
        return 1
    fi
    
    # Extract hash from checksum file
    local expected_hash
    local filename=$(basename "$file")
    
    # Try different checksum file formats
    # Format 1: "hash  filename"
    expected_hash=$(grep -E "^[a-fA-F0-9]+[[:space:]]+\*?${filename}$" "$checksum_file" 2>/dev/null | awk '{print $1}')
    
    # Format 2: "hash" (single line with just the hash)
    if [[ -z "$expected_hash" ]]; then
        expected_hash=$(grep -E "^[a-fA-F0-9]+$" "$checksum_file" 2>/dev/null | head -1)
    fi
    
    # Format 3: "SHA256(filename)= hash" (BSD style)
    if [[ -z "$expected_hash" ]]; then
        expected_hash=$(grep -E "^${algorithm^^}\(${filename}\)=" "$checksum_file" 2>/dev/null | cut -d'=' -f2- | tr -d ' ')
    fi
    
    if [[ -z "$expected_hash" ]]; then
        log_message "ERROR" "Could not extract hash from checksum file"
        return 1
    fi
    
    verify_checksum "$file" "$expected_hash" "$algorithm"
}

# Generate checksum file
generate_checksum_file() {
    local file="$1"
    local output_file="${2:-${file}.sha256}"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "File not found: $file"
        return 1
    fi
    
    log_message "INFO" "Generating $algorithm checksum for $(basename "$file")..."
    
    local hash
    hash=$(calculate_hash "$file" "$algorithm")
    
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    # Write checksum in standard format
    echo "$hash  $(basename "$file")" > "$output_file"
    
    log_message "SUCCESS" "Checksum saved to $output_file"
    return 0
}

# Batch verify checksums
batch_verify_checksums() {
    local checksum_file="$1"
    local base_dir="${2:-.}"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$checksum_file" ]]; then
        log_message "ERROR" "Checksum file not found: $checksum_file"
        return 1
    fi
    
    local total=0
    local passed=0
    local failed=0
    
    echo "${COLOR_CYAN}Batch Checksum Verification${COLOR_RESET}"
    echo "Algorithm: ${algorithm^^}"
    echo ""
    
    # Process each line in checksum file
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^# ]] && continue
        
        # Extract hash and filename
        local hash=$(echo "$line" | awk '{print $1}')
        local filename=$(echo "$line" | awk '{print $2}' | sed 's/^\*//')
        
        if [[ -z "$hash" ]] || [[ -z "$filename" ]]; then
            continue
        fi
        
        local filepath="$base_dir/$filename"
        ((total++))
        
        echo -n "Verifying $filename... "
        
        if [[ ! -f "$filepath" ]]; then
            echo "${COLOR_RED}FILE NOT FOUND${COLOR_RESET}"
            ((failed++))
            continue
        fi
        
        if verify_checksum "$filepath" "$hash" "$algorithm" >/dev/null 2>&1; then
            echo "${COLOR_GREEN}✓ PASS${COLOR_RESET}"
            ((passed++))
        else
            echo "${COLOR_RED}✗ FAIL${COLOR_RESET}"
            ((failed++))
        fi
    done < "$checksum_file"
    
    echo ""
    echo "Summary: $passed/$total passed"
    
    if [[ $failed -gt 0 ]]; then
        log_message "ERROR" "$failed files failed verification"
        return 1
    else
        log_message "SUCCESS" "All files passed verification"
        return 0
    fi
}

# Generate checksums for directory
generate_directory_checksums() {
    local directory="$1"
    local output_file="${2:-checksums.sha256}"
    local algorithm="${3:-sha256}"
    local pattern="${4:-*}"
    
    if [[ ! -d "$directory" ]]; then
        log_message "ERROR" "Directory not found: $directory"
        return 1
    fi
    
    log_message "INFO" "Generating checksums for files in $directory..."
    
    local count=0
    > "$output_file"  # Clear output file
    
    # Add header
    echo "# Leonardo AI Universal - Checksum File" >> "$output_file"
    echo "# Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")" >> "$output_file"
    echo "# Algorithm: ${algorithm^^}" >> "$output_file"
    echo "" >> "$output_file"
    
    # Process files
    find "$directory" -type f -name "$pattern" -print0 | while IFS= read -r -d '' file; do
        local relative_path="${file#$directory/}"
        local hash
        
        hash=$(calculate_hash "$file" "$algorithm")
        if [[ $? -eq 0 ]]; then
            echo "$hash  $relative_path" >> "$output_file"
            ((count++))
        fi
    done
    
    log_message "SUCCESS" "Generated checksums for $count files"
    return 0
}

# Detect hash algorithm from checksum length
detect_hash_algorithm() {
    local hash="$1"
    local length=${#hash}
    
    case $length in
        32) echo "md5" ;;
        40) echo "sha1" ;;
        64) echo "sha256" ;;
        128) echo "sha512" ;;
        *) echo "unknown" ;;
    esac
}

# Verify download with checksum
verify_download() {
    local url="$1"
    local file="$2"
    local expected_hash="$3"
    local algorithm="${4:-auto}"
    
    if [[ ! -f "$file" ]]; then
        log_message "ERROR" "Downloaded file not found: $file"
        return 1
    fi
    
    # Auto-detect algorithm if needed
    if [[ "$algorithm" == "auto" ]]; then
        algorithm=$(detect_hash_algorithm "$expected_hash")
        if [[ "$algorithm" == "unknown" ]]; then
            log_message "ERROR" "Could not detect hash algorithm"
            return 1
        fi
        log_message "INFO" "Auto-detected algorithm: ${algorithm^^}"
    fi
    
    # Verify checksum
    verify_checksum "$file" "$expected_hash" "$algorithm"
}

# Compare two files by checksum
compare_files_by_hash() {
    local file1="$1"
    local file2="$2"
    local algorithm="${3:-sha256}"
    
    if [[ ! -f "$file1" ]] || [[ ! -f "$file2" ]]; then
        log_message "ERROR" "One or both files not found"
        return 1
    fi
    
    local hash1=$(calculate_hash "$file1" "$algorithm")
    local hash2=$(calculate_hash "$file2" "$algorithm")
    
    if [[ "$hash1" == "$hash2" ]]; then
        log_message "INFO" "Files are identical (${algorithm^^})"
        return 0
    else
        log_message "INFO" "Files are different"
        return 1
    fi
}

# Initialize hash commands on module load
init_hash_commands

# Export checksum functions
export -f calculate_hash verify_checksum verify_checksum_file
export -f generate_checksum_file batch_verify_checksums
export -f generate_directory_checksums detect_hash_algorithm
export -f verify_download compare_files_by_hash
