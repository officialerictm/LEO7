#!/bin/bash

echo "Rebuilding Leonardo..."
cd "$(dirname "$0")"
bash assembly/build-simple.sh
echo "Done!"
