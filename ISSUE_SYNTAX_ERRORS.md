# Leonardo Build Syntax Errors - Help Needed

## Issue Description
Leonardo AI Universal (LEO7) is experiencing persistent bash syntax errors that prevent the built `leonardo.sh` from running. Multiple fixes have been attempted but new errors keep appearing.

## Current Status
The build completes successfully but running `./leonardo.sh` results in:
```
./leonardo.sh: line 3127: syntax error near unexpected token `('
./leonardo.sh: line 3127: `        echo -e "${GREEN}✓ Downloaded successfully${COLOR_RESET} (${size})"'
```

## Fixes Already Attempted

### 1. Fixed Complex Parameter Expansions
**Problem:** Nested parameter expansion causing syntax errors
```bash
# Original (causing error):
"${chars:$((RANDOM % ${#chars})):1}"

# Fixed to:
local char_index=$((RANDOM % ${#chars}))
local char="${chars:$char_index:1}"
```

### 2. Commented Out Matrix Effect Function
The entire `show_matrix_progress()` function in `src/ui/progress.sh` has been commented out due to syntax issues.

### 3. Fixed Printf Format Strings
**Problem:** Pipe characters in format strings within pipeline context
```bash
# Original:
printf " ${percent}%% | ${speed} | ETA: ${eta}  "

# Fixed to:
printf " %s%% \| %s \| ETA: %s  " "${percent}" "${speed}" "${eta}"
```

### 4. Moved Utility Functions
Moved `format_bytes()` and `format_duration()` to the top of `progress.sh` to ensure they're defined before use.

## Current Problem Areas

1. **File:** `src/ui/progress.sh`
   - Multiple download progress functions with complex pipelines
   - Curl output parsing with regex matches
   - Progress bar display with ANSI escape sequences

2. **Symptoms:**
   - Syntax errors appear after fixing previous ones
   - Errors seem related to:
     - Subshells within pipelines
     - Variable interpolation in echo/printf statements
     - Function calls within command substitution

## How to Reproduce
```bash
cd LEO7
rm -f leonardo.sh
bash assembly/build-simple.sh
./leonardo.sh
```

## Help Needed
1. Review the bash syntax in `src/ui/progress.sh`
2. Check for:
   - Unclosed quotes or parentheses
   - Issues with pipelines and subshells
   - Problems with variable expansion in different contexts
3. Consider simplifying the progress display functions
4. Test with different bash versions (currently using system default)

## Environment
- OS: Linux
- Shell: bash
- Build script: `assembly/build-simple.sh` (simple concatenation, no processing)

## Related Files
- `src/ui/progress.sh` - Main problem file
- `src/utils/colors.sh` - Color definitions
- `assembly/build-simple.sh` - Build script

The goal is to get Leonardo running without syntax errors while maintaining the progress display functionality for downloads and file operations.
