#!/bin/bash
# Test menu selection with debug
cd /home/officialerictm/CascadeProjects/vibecoding/CascadeProjects/windsurf-project/LEO7

# Run with debug mode and simulate selecting option 1
export DEBUG=1
export LEONARDO_DEBUG=true
echo -e "1\nq" | timeout 5 ./leonardo.sh 2>&1 | tail -100
