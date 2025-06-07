#!/usr/bin/env bash

# Test location detection functions directly

# Source only the required modules
source src/utils/colors.sh 2>/dev/null || true
source src/core/system_status.sh 2>/dev/null || true

# Define command_exists if not available
if ! type command_exists >/dev/null 2>&1; then
    command_exists() {
        command -v "$1" >/dev/null 2>&1
    }
fi

echo "Testing System Status Detection..."
echo "================================="

# Test Ollama detection
echo -e "\n1. Ollama Location:"
ollama_loc=$(detect_ollama_location)
echo "   Result: $ollama_loc"

# Test Leonardo detection  
echo -e "\n2. Leonardo Location:"
leonardo_loc=$(detect_leonardo_location)
echo "   Result: $leonardo_loc"

# Test formatted status
echo -e "\n3. Formatted Status:"
status=$(format_system_status)
echo -e "   $status"

# Test chat prompt prefix
echo -e "\n4. Chat Prompt Prefix:"
prefix=$(get_chat_prompt_prefix)
echo "   Result: $prefix"

echo -e "\n================================="
echo "Test Complete!"
