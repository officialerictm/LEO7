#!/bin/bash
cd "$(dirname "$0")"
rm -f leonardo.sh
echo "Rebuilding Leonardo..."
bash assembly/build-simple.sh
echo "Done. Test with: ./leonardo.sh"
