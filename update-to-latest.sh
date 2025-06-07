#!/bin/bash
# Update to latest main branch

cd /home/officialerictm/CascadeProjects/vibecoding/CascadeProjects/windsurf-project/LEO7

echo "Switching to main branch..."
git checkout main

echo "Pulling latest changes..."
git pull origin main

echo "Rebuilding leonardo.sh..."
bash assembly/build-simple.sh

echo "Done! Latest UI/UX improvements have been pulled and rebuilt."
