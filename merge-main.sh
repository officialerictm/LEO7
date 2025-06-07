#!/bin/bash
# Script to merge latest main branch changes

echo "Merging latest UI/UX improvements from main branch..."

# Ensure we have the latest remote refs
echo "Fetching latest changes..."
git fetch origin

# Show what we're merging
echo "Latest commits on origin/main:"
git log --oneline origin/main -5

# Perform the merge
echo "Merging origin/main..."
git merge origin/main -m "Merge latest UI/UX improvements from main"

if [ $? -eq 0 ]; then
    echo "✓ Successfully merged latest changes!"
    echo ""
    echo "Rebuilding leonardo.sh..."
    bash assembly/build-simple.sh
else
    echo "✗ Merge failed. Please resolve conflicts manually."
fi
