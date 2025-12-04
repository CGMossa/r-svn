#!/bin/bash
# Generate unity build files for R source directories
# Usage: tools/make-unity.sh src/main src/nmath src/appl

set -euo pipefail

for dir in "$@"; do
    if [ ! -d "$dir" ]; then
        echo "Skipping non-existent: $dir"
        continue
    fi

    unity_file="$dir/unity_all.c"
    echo "Generating: $unity_file"

    {
        echo "/* Unity build file - auto-generated */"
        echo "/* Do not edit - regenerate with: tools/make-unity.sh $dir */"
        echo ""
        echo "#ifdef HAVE_CONFIG_H"
        echo "#include <config.h>"
        echo "#endif"
        echo ""

        # Include all .c files except the unity file itself
        for src in "$dir"/*.c; do
            base=$(basename "$src")
            if [ "$base" != "unity_all.c" ]; then
                echo "#include \"$base\""
            fi
        done
    } > "$unity_file"

    echo "  Included $(ls "$dir"/*.c 2>/dev/null | grep -v unity_all.c | wc -l | tr -d ' ') files"
done
