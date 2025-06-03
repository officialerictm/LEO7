#!/usr/bin/env bash
# ==============================================================================
# Leonardo AI Universal - USB Health Monitoring Module
# ==============================================================================
# Description: Monitor USB drive health, write cycles, and performance
# Version: 7.0.0
# Dependencies: colors.sh, logging.sh, filesystem.sh, detector.sh
# ==============================================================================

# Health check thresholds
readonly USB_HEALTH_WRITE_CYCLE_WARNING=10000
readonly USB_HEALTH_WRITE_CYCLE_CRITICAL=50000
readonly USB_HEALTH_TEMP_WARNING=60
readonly USB_HEALTH_TEMP_CRITICAL=70
readonly USB_HEALTH_SPEED_MIN_MB=10

# Health status database
declare -g LEONARDO_USB_HEALTH_DB="${LEONARDO_USB_MOUNT:-}/leonardo/data/health.db"

# Initialize health monitoring
init_usb_health() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    
    if [[ -z "$mount_point" ]] || [[ ! -d "$mount_point" ]]; then
        log_message "ERROR" "Invalid mount point for health monitoring"
        return 1
    fi
    
    # Create health database directory
    mkdir -p "$(dirname "$LEONARDO_USB_HEALTH_DB")" 2>/dev/null
    
    # Initialize health database if not exists
    if [[ ! -f "$LEONARDO_USB_HEALTH_DB" ]]; then
        cat > "$LEONARDO_USB_HEALTH_DB" << EOF
# Leonardo USB Health Database
# Format: timestamp|metric|value
# Initialized: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
EOF
    fi
    
    log_message "INFO" "USB health monitoring initialized"
    return 0
}

# Record health metric
record_health_metric() {
    local metric="$1"
    local value="$2"
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")
    
    echo "${timestamp}|${metric}|${value}" >> "$LEONARDO_USB_HEALTH_DB"
}

# Get USB SMART data
get_usb_smart_data() {
    local device="${1:-$LEONARDO_USB_DEVICE}"
    local platform=$(detect_platform)
    
    case "$platform" in
        "linux")
            if command_exists "smartctl"; then
                # Try to get SMART data
                if smartctl -i "$device" 2>/dev/null | grep -q "SMART support is: Available"; then
                    smartctl -A "$device" 2>/dev/null
                else
                    echo "SMART data not available for USB device"
                fi
            else
                echo "smartctl not installed"
            fi
            ;;
        "macos")
            if command_exists "smartctl"; then
                smartctl -A "$device" 2>/dev/null || echo "SMART data not available"
            else
                # Use diskutil for basic info
                diskutil info "$device" | grep -E "(Media Name|Total Size|Device Block Size)"
            fi
            ;;
        *)
            echo "SMART monitoring not supported on this platform"
            ;;
    esac
}

# Estimate write cycles
estimate_write_cycles() {
    local mount_point="${1:-$LEONARDO_USB_MOUNT}"
    
    if [[ ! -f "$LEONARDO_USB_HEALTH_DB" ]]; then
        echo "0"
        return
    fi
    
    # Count write operations from health database
    local write_count=$(grep "|write_operation|" "$LEONARDO_USB_HEALTH_DB" 2>/dev/null | wc -l)
    
    # Estimate based on write operations (rough approximation)
    # Assume each operation writes average 10MB, USB has 100GB capacity
    # This gives us a very rough estimate of write cycles
    local estimated_cycles=$((write_count / 1000))
    
    echo "$estimated_cycles"
}

# Check USB temperature (if available)
check_usb_temperature() {
    local device="${1:-$LEONARDO_USB_DEVICE}"
    local platform=$(detect_platform)
    local temp="N/A"
    
    case "$platform" in
        "linux")
            # Try to get temperature from hwmon
            local device_name=$(basename "$device")
            local hwmon_path="/sys/block/$device_name/device/hwmon"
            
            if [[ -d "$hwmon_path" ]]; then
                for hwmon in "$hwmon_path"/hwmon*; do
                    if [[ -f "$hwmon/temp1_input" ]]; then
                        local temp_milli=$(cat "$hwmon/temp1_input" 2>/dev/null)
                        temp=$((temp_milli / 1000))
                        break
                    fi
                done
            fi
            
            # Try smartctl as fallback
            if [[ "$temp" == "N/A" ]] && command_exists "smartctl"; then
                local smart_temp=$(smartctl -A "$device" 2>/dev/null | grep -i "temperature" | awk '{print $10}')
                [[ -n "$smart_temp" ]] && temp="$smart_temp"
            fi
            ;;
        "macos")
            # Try smartctl
            if command_exists "smartctl"; then
                local smart_temp=$(smartctl -A "$device" 2>/dev/null | grep -i "temperature" | awk '{print $10}')
                [[ -n "$smart_temp" ]] && temp="$smart_temp"
            fi
            ;;
    esac
    
    echo "$temp"
}

# Perform comprehensive health check
perform_health_check() {
    local device="${1:-$LEONARDO_USB_DEVICE}"
    local mount_point="${2:-$LEONARDO_USB_MOUNT}"
    
    if [[ -z "$device" ]]; then
        log_message "ERROR" "No USB device specified"
        return 1
    fi
    
    echo "${COLOR_CYAN}USB Health Check${COLOR_RESET}"
    echo "=================="
    echo ""
    
    # Basic device info
    echo "${COLOR_CYAN}Device Information:${COLOR_RESET}"
    get_usb_drive_info "$device" | sed 's/^/  /'
    echo ""
    
    # Performance test
    echo "${COLOR_CYAN}Performance Test:${COLOR_RESET}"
    local write_speed="N/A"
    if [[ -n "$mount_point" ]] && [[ -d "$mount_point" ]]; then
        # Quick write test (10MB)
        local test_file="$mount_point/.leonardo_health_test_$$"
        local start_time=$(date +%s%N)
        
        if dd if=/dev/zero of="$test_file" bs=1M count=10 conv=fdatasync 2>/dev/null; then
            local end_time=$(date +%s%N)
            local duration=$((end_time - start_time))
            
            if [[ $duration -gt 0 ]]; then
                # Calculate MB/s
                local speed_bytes=$((10485760 * 1000000000 / duration))
                write_speed="$(format_bytes $speed_bytes)/s"
                
                # Record metric
                record_health_metric "write_speed" "$speed_bytes"
            fi
            
            rm -f "$test_file"
        fi
    fi
    echo "  Write Speed: $write_speed"
    
    # USB speed
    echo "  USB Speed: $(get_usb_speed "$device")"
    echo ""
    
    # Health metrics
    echo "${COLOR_CYAN}Health Metrics:${COLOR_RESET}"
    
    # Temperature
    local temp=$(check_usb_temperature "$device")
    echo -n "  Temperature: "
    if [[ "$temp" != "N/A" ]]; then
        if [[ $temp -ge $USB_HEALTH_TEMP_CRITICAL ]]; then
            echo "${COLOR_RED}${temp}°C (CRITICAL)${COLOR_RESET}"
        elif [[ $temp -ge $USB_HEALTH_TEMP_WARNING ]]; then
            echo "${COLOR_YELLOW}${temp}°C (WARNING)${COLOR_RESET}"
        else
            echo "${COLOR_GREEN}${temp}°C${COLOR_RESET}"
        fi
        record_health_metric "temperature" "$temp"
    else
        echo "N/A"
    fi
    
    # Write cycles
    local cycles=$(estimate_write_cycles)
    echo -n "  Estimated Write Cycles: "
    if [[ $cycles -ge $USB_HEALTH_WRITE_CYCLE_CRITICAL ]]; then
        echo "${COLOR_RED}${cycles} (CRITICAL)${COLOR_RESET}"
    elif [[ $cycles -ge $USB_HEALTH_WRITE_CYCLE_WARNING ]]; then
        echo "${COLOR_YELLOW}${cycles} (WARNING)${COLOR_RESET}"
    else
        echo "${COLOR_GREEN}${cycles}${COLOR_RESET}"
    fi
    
    # Free space
    if [[ -n "$mount_point" ]]; then
        local free_space=$(df -h "$mount_point" 2>/dev/null | tail -1 | awk '{print $4}')
        local used_percent=$(df "$mount_point" 2>/dev/null | tail -1 | awk '{print $5}' | tr -d '%')
        
        echo -n "  Free Space: $free_space "
        if [[ $used_percent -ge 95 ]]; then
            echo "${COLOR_RED}(${used_percent}% used - CRITICAL)${COLOR_RESET}"
        elif [[ $used_percent -ge 80 ]]; then
            echo "${COLOR_YELLOW}(${used_percent}% used - WARNING)${COLOR_RESET}"
        else
            echo "${COLOR_GREEN}(${used_percent}% used)${COLOR_RESET}"
        fi
    fi
    
    echo ""
    
    # SMART data (if available)
    echo "${COLOR_CYAN}SMART Data:${COLOR_RESET}"
    get_usb_smart_data "$device" | grep -E "(Reallocated|Wear_Leveling|Runtime_Bad|Temperature|Power_On)" | sed 's/^/  /'
    echo ""
    
    # Overall health status
    echo -n "${COLOR_CYAN}Overall Status:${COLOR_RESET} "
    local status="GOOD"
    local status_color="$COLOR_GREEN"
    
    if [[ $cycles -ge $USB_HEALTH_WRITE_CYCLE_CRITICAL ]] || [[ "$temp" != "N/A" && $temp -ge $USB_HEALTH_TEMP_CRITICAL ]]; then
        status="CRITICAL"
        status_color="$COLOR_RED"
    elif [[ $cycles -ge $USB_HEALTH_WRITE_CYCLE_WARNING ]] || [[ "$temp" != "N/A" && $temp -ge $USB_HEALTH_TEMP_WARNING ]]; then
        status="WARNING"
        status_color="$COLOR_YELLOW"
    fi
    
    echo "${status_color}${status}${COLOR_RESET}"
    
    # Record overall health
    record_health_metric "health_status" "$status"
    
    return 0
}

# Generate health report
generate_health_report() {
    local output_file="${1:-./usb_health_report_$(date +%Y%m%d_%H%M%S).txt}"
    local device="${2:-$LEONARDO_USB_DEVICE}"
    
    {
        echo "Leonardo USB Health Report"
        echo "========================="
        echo "Generated: $(date)"
        echo ""
        
        perform_health_check "$device"
        
        echo ""
        echo "Health History (Last 30 days):"
        echo "=============================="
        
        if [[ -f "$LEONARDO_USB_HEALTH_DB" ]]; then
            # Get metrics from last 30 days
            local cutoff_date=$(date -u -d "30 days ago" +"%Y-%m-%d" 2>/dev/null || date -u -v-30d +"%Y-%m-%d")
            
            echo ""
            echo "Write Speed Trend:"
            grep "|write_speed|" "$LEONARDO_USB_HEALTH_DB" | tail -20 | while IFS='|' read -r timestamp metric value; do
                echo "  $timestamp: $(format_bytes $value)/s"
            done
            
            echo ""
            echo "Temperature History:"
            grep "|temperature|" "$LEONARDO_USB_HEALTH_DB" | tail -20 | while IFS='|' read -r timestamp metric value; do
                echo "  $timestamp: ${value}°C"
            done
            
            echo ""
            echo "Health Status Changes:"
            grep "|health_status|" "$LEONARDO_USB_HEALTH_DB" | tail -10 | while IFS='|' read -r timestamp metric value; do
                echo "  $timestamp: $value"
            done
        else
            echo "No historical data available"
        fi
        
    } > "$output_file"
    
    log_message "INFO" "Health report generated: $output_file"
    echo "${COLOR_GREEN}Health report saved to: $output_file${COLOR_RESET}"
}

# Monitor health in background
monitor_usb_health() {
    local interval="${1:-300}"  # Default 5 minutes
    local device="${2:-$LEONARDO_USB_DEVICE}"
    
    if [[ -z "$device" ]]; then
        log_message "ERROR" "No USB device to monitor"
        return 1
    fi
    
    log_message "INFO" "Starting USB health monitoring (interval: ${interval}s)"
    
    # Create monitoring script
    local monitor_script="/tmp/leonardo_health_monitor_$$.sh"
    cat > "$monitor_script" << EOF
#!/usr/bin/env bash
source "$0"  # Source Leonardo

while true; do
    # Check if device still exists
    if ! is_usb_device "$device"; then
        log_message "WARN" "USB device disconnected"
        break
    fi
    
    # Perform quick health check
    local temp=\$(check_usb_temperature "$device")
    local cycles=\$(estimate_write_cycles)
    
    # Record metrics
    [[ "\$temp" != "N/A" ]] && record_health_metric "temperature" "\$temp"
    record_health_metric "write_cycles" "\$cycles"
    
    # Check for critical conditions
    if [[ "\$temp" != "N/A" && \$temp -ge $USB_HEALTH_TEMP_CRITICAL ]]; then
        log_message "CRITICAL" "USB temperature critical: \${temp}°C"
    fi
    
    if [[ \$cycles -ge $USB_HEALTH_WRITE_CYCLE_CRITICAL ]]; then
        log_message "CRITICAL" "USB write cycles critical: \$cycles"
    fi
    
    sleep $interval
done

rm -f "$monitor_script"
EOF
    
    chmod +x "$monitor_script"
    
    # Run in background
    nohup bash "$monitor_script" > /dev/null 2>&1 &
    local monitor_pid=$!
    
    echo "${COLOR_GREEN}Health monitoring started (PID: $monitor_pid)${COLOR_RESET}"
    echo "To stop monitoring: kill $monitor_pid"
    
    # Save PID for later
    echo "$monitor_pid" > "/tmp/leonardo_health_monitor.pid"
    
    return 0
}

# Stop health monitoring
stop_health_monitoring() {
    if [[ -f "/tmp/leonardo_health_monitor.pid" ]]; then
        local pid=$(cat "/tmp/leonardo_health_monitor.pid")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            log_message "INFO" "Health monitoring stopped"
        fi
        rm -f "/tmp/leonardo_health_monitor.pid"
    else
        log_message "WARN" "No active health monitoring found"
    fi
}

# Analyze health trends
analyze_health_trends() {
    if [[ ! -f "$LEONARDO_USB_HEALTH_DB" ]]; then
        log_message "ERROR" "No health data available"
        return 1
    fi
    
    echo "${COLOR_CYAN}USB Health Trend Analysis${COLOR_RESET}"
    echo "========================="
    echo ""
    
    # Analyze write speed trends
    echo "Write Speed Analysis:"
    local speeds=($(grep "|write_speed|" "$LEONARDO_USB_HEALTH_DB" | tail -100 | cut -d'|' -f3))
    if [[ ${#speeds[@]} -gt 0 ]]; then
        local sum=0
        local min=${speeds[0]}
        local max=${speeds[0]}
        
        for speed in "${speeds[@]}"; do
            ((sum += speed))
            [[ $speed -lt $min ]] && min=$speed
            [[ $speed -gt $max ]] && max=$speed
        done
        
        local avg=$((sum / ${#speeds[@]}))
        
        echo "  Average: $(format_bytes $avg)/s"
        echo "  Minimum: $(format_bytes $min)/s"
        echo "  Maximum: $(format_bytes $max)/s"
        
        # Check for degradation
        local recent_avg=0
        local recent_count=0
        for ((i=${#speeds[@]}-10; i<${#speeds[@]}; i++)); do
            if [[ $i -ge 0 ]]; then
                ((recent_avg += speeds[i]))
                ((recent_count++))
            fi
        done
        
        if [[ $recent_count -gt 0 ]]; then
            recent_avg=$((recent_avg / recent_count))
            local degradation=$(( (avg - recent_avg) * 100 / avg ))
            
            if [[ $degradation -gt 20 ]]; then
                echo "  ${COLOR_YELLOW}⚠ Performance degradation detected: ${degradation}%${COLOR_RESET}"
            fi
        fi
    else
        echo "  No data available"
    fi
    
    echo ""
    
    # Temperature trends
    echo "Temperature Analysis:"
    local temps=($(grep "|temperature|" "$LEONARDO_USB_HEALTH_DB" | tail -100 | cut -d'|' -f3 | grep -v "N/A"))
    if [[ ${#temps[@]} -gt 0 ]]; then
        local sum=0
        local min=${temps[0]}
        local max=${temps[0]}
        local high_count=0
        
        for temp in "${temps[@]}"; do
            ((sum += temp))
            [[ $temp -lt $min ]] && min=$temp
            [[ $temp -gt $max ]] && max=$temp
            [[ $temp -ge $USB_HEALTH_TEMP_WARNING ]] && ((high_count++))
        done
        
        local avg=$((sum / ${#temps[@]}))
        
        echo "  Average: ${avg}°C"
        echo "  Minimum: ${min}°C"
        echo "  Maximum: ${max}°C"
        
        if [[ $high_count -gt 0 ]]; then
            local high_percent=$((high_count * 100 / ${#temps[@]}))
            echo "  ${COLOR_YELLOW}⚠ High temperature incidents: ${high_count} (${high_percent}%)${COLOR_RESET}"
        fi
    else
        echo "  No data available"
    fi
    
    echo ""
    
    # Health status summary
    echo "Health Status Summary:"
    local good_count=$(grep "|health_status|GOOD" "$LEONARDO_USB_HEALTH_DB" | wc -l)
    local warn_count=$(grep "|health_status|WARNING" "$LEONARDO_USB_HEALTH_DB" | wc -l)
    local crit_count=$(grep "|health_status|CRITICAL" "$LEONARDO_USB_HEALTH_DB" | wc -l)
    local total_count=$((good_count + warn_count + crit_count))
    
    if [[ $total_count -gt 0 ]]; then
        echo "  Good: $good_count ($((good_count * 100 / total_count))%)"
        echo "  Warning: $warn_count ($((warn_count * 100 / total_count))%)"
        echo "  Critical: $crit_count ($((crit_count * 100 / total_count))%)"
    else
        echo "  No data available"
    fi
    
    return 0
}

# Export health monitoring functions
export -f init_usb_health record_health_metric get_usb_smart_data
export -f estimate_write_cycles check_usb_temperature perform_health_check
export -f generate_health_report monitor_usb_health stop_health_monitoring
export -f analyze_health_trends
