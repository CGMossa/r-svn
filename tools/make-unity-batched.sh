#!/bin/sh
# Generate batched unity build files (groups of N files)
# This avoids most static symbol conflicts while still getting speedup
# Usage: tools/make-unity-batched.sh [batch_size] dir [dir...]

set -eu

BATCH_SIZE="${1:-8}"
shift

for dir in "$@"; do
    if [ ! -d "$dir" ]; then
        echo "Skipping non-existent: $dir"
        continue
    fi

    # Remove old unity files
    rm -f "$dir"/unity_*.c

    # Get all .c files (excluding any existing unity files)
    sources=$(ls "$dir"/*.c 2>/dev/null | grep -v 'unity_' | sort)
    total=$(echo "$sources" | wc -l | tr -d ' ')

    batch=0
    count=0
    unity_file=""

    echo "Processing $dir: $total files in batches of $BATCH_SIZE"

    for src in $sources; do
        if [ $count -eq 0 ]; then
            batch=$((batch + 1))
            unity_file="$dir/unity_batch${batch}.c"
            cat > "$unity_file" << 'HEADER'
/* Unity build batch - auto-generated */
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

HEADER
        fi

        base=$(basename "$src")
        echo "#include \"$base\"" >> "$unity_file"
        count=$((count + 1))

        if [ $count -ge $BATCH_SIZE ]; then
            echo "  Generated: unity_batch${batch}.c ($count files)"
            count=0
        fi
    done

    if [ $count -gt 0 ]; then
        echo "  Generated: unity_batch${batch}.c ($count files)"
    fi

    echo "  Total: $batch batch file(s)"
done
