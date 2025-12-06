#!/bin/sh
# Generate conflict-aware unity build for R library packages
# Usage: tools/make-unity-library.sh <library_name>
# Example: tools/make-unity-library.sh stats
#
# Creates unity_<library>.c in src/library/<library>/src/

set -eu

if [ $# -lt 1 ]; then
    echo "Usage: $0 <library_name>"
    echo "Libraries: stats, utils, tools, parallel, tcltk, methods, graphics, grDevices, splines"
    exit 1
fi

LIB="$1"
SRCDIR="src/library/$LIB/src"

if [ ! -d "$SRCDIR" ]; then
    echo "Error: Directory $SRCDIR does not exist"
    exit 1
fi

# Temp files
TMPDIR="${TMPDIR:-/tmp}"
CONFLICT_FILE="$TMPDIR/unity_conflicts_lib_$$"
trap 'rm -f "$CONFLICT_FILE"' EXIT

# Known conflicts per library (files that cannot be in same batch)
# Format: file1 file2 (meaning they conflict)
case "$LIB" in
    stats)
        # arima.c and pacf.c share: partrans, invpartrans, dotrans, eps, max, min
        # filter.c and starma.c also define max
        cat > "$CONFLICT_FILE" << 'EOF'
arima.c pacf.c
arima.c filter.c
arima.c starma.c
pacf.c filter.c
pacf.c starma.c
filter.c starma.c
EOF
        # Files with macro pollution that should be isolated
        ISOLATE_FILES=""
        ;;
    grDevices)
        # Check for common conflicts in grDevices
        cat > "$CONFLICT_FILE" << 'EOF'
EOF
        ISOLATE_FILES=""
        ;;
    tools)
        # gramLatex.c and gramRd.c are yacc-generated with conflicting enums
        cat > "$CONFLICT_FILE" << 'EOF'
gramLatex.c gramRd.c
EOF
        ISOLATE_FILES=""
        ;;
    graphics)
        cat > "$CONFLICT_FILE" << 'EOF'
EOF
        ISOLATE_FILES=""
        ;;
    utils)
        cat > "$CONFLICT_FILE" << 'EOF'
EOF
        ISOLATE_FILES=""
        ;;
    methods)
        cat > "$CONFLICT_FILE" << 'EOF'
EOF
        ISOLATE_FILES=""
        ;;
    parallel)
        cat > "$CONFLICT_FILE" << 'EOF'
EOF
        ISOLATE_FILES=""
        ;;
    tcltk)
        cat > "$CONFLICT_FILE" << 'EOF'
EOF
        ISOLATE_FILES=""
        ;;
    splines)
        cat > "$CONFLICT_FILE" << 'EOF'
EOF
        ISOLATE_FILES=""
        ;;
    *)
        echo "Unknown library: $LIB"
        exit 1
        ;;
esac

# Check if a file must be isolated
is_isolated() {
    case " $ISOLATE_FILES " in
        *" $1 "*) return 0 ;;
        *) return 1 ;;
    esac
}

# Check if two files conflict
files_conflict() {
    f1="$1"
    f2="$2"
    # Isolated files conflict with everything
    if is_isolated "$f1" || is_isolated "$f2"; then
        return 0
    fi
    grep -q "^$f1 $f2$" "$CONFLICT_FILE" 2>/dev/null && return 0
    grep -q "^$f2 $f1$" "$CONFLICT_FILE" 2>/dev/null && return 0
    return 1
}

# Get all .c files, excluding platform-specific and special files
cd "$SRCDIR"
all_files=""
for f in *.c; do
    case "$f" in
        unity_*.c) continue ;;       # Existing unity files
        *_win.c) continue ;;         # Windows-specific
        *_win32.c) continue ;;       # Windows-specific
        *-common.c) continue ;;      # Fragment files included by others
        devQuartz.c) continue ;;     # macOS-only
        devWindows.c) continue ;;    # Windows-only
        winbitmap.c) continue ;;     # Windows-only
        qdBitmap.c) continue ;;      # macOS-only (Quartz)
        qdPDF.c) continue ;;         # macOS-only (Quartz)
        *.c)
            if [ -z "$all_files" ]; then
                all_files="$f"
            else
                all_files="$all_files $f"
            fi
            ;;
    esac
done

file_count=0
for f in $all_files; do
    file_count=$((file_count + 1))
done
cd - > /dev/null

echo "Processing $file_count files from $SRCDIR"
echo ""

# Simple approach: create 1-2 unity files
# For most libraries, we can combine all files into one
# For stats (with conflicts), we create multiple batches

unity_file="$SRCDIR/unity_$LIB.c"

# Check if we have any conflicts
has_conflicts=false
if [ -s "$CONFLICT_FILE" ]; then
    has_conflicts=true
fi

if [ "$has_conflicts" = "true" ]; then
    echo "Library has known conflicts, creating batched unity build..."

    # Greedy batch assignment
    batch_num=0
    batches=""  # Will store: "batch1:file1,file2|batch2:file3,file4"

    for file in $all_files; do
        assigned=false

        # Try existing batches
        b=1
        while [ $b -le $batch_num ]; do
            # Extract files in batch b
            batch_files=$(echo "$batches" | tr '|' '\n' | grep "^batch$b:" | sed "s/^batch$b://" | tr ',' ' ')
            can_add=true

            for bf in $batch_files; do
                if files_conflict "$file" "$bf"; then
                    can_add=false
                    break
                fi
            done

            if [ "$can_add" = "true" ]; then
                # Add to batch b
                old_batch=$(echo "$batches" | tr '|' '\n' | grep "^batch$b:")
                new_batch="$old_batch,$file"
                batches=$(echo "$batches" | sed "s|$old_batch|$new_batch|")
                assigned=true
                break
            fi
            b=$((b + 1))
        done

        # Create new batch if needed
        if [ "$assigned" = "false" ]; then
            batch_num=$((batch_num + 1))
            if [ -z "$batches" ]; then
                batches="batch$batch_num:$file"
            else
                batches="$batches|batch$batch_num:$file"
            fi
        fi
    done

    echo "Created $batch_num batches"

    # Generate unity files for each batch
    b=1
    while [ $b -le $batch_num ]; do
        batch_files=$(echo "$batches" | tr '|' '\n' | grep "^batch$b:" | sed "s/^batch$b://" | tr ',' ' ')
        count=0
        for f in $batch_files; do
            count=$((count + 1))
        done

        batch_unity="$SRCDIR/unity_${LIB}_batch${b}.c"

        {
            echo "/* Unity build batch $b for $LIB library - auto-generated */"
            echo "/* $count files - conflict-aware grouping */"
            echo "/* Regenerate with: tools/make-unity-library.sh $LIB */"
            echo ""
            for f in $batch_files; do
                echo "#include \"$f\""
            done
        } > "$batch_unity"

        echo "  Batch $b: $count files -> $(basename "$batch_unity")"
        printf "    "
        for f in $batch_files; do
            printf "%s " "$f"
        done
        echo ""

        b=$((b + 1))
    done
else
    # No conflicts: single unity file
    {
        echo "/* Unity build for $LIB library - auto-generated */"
        echo "/* $file_count files */"
        echo "/* Regenerate with: tools/make-unity-library.sh $LIB */"
        echo ""
        for f in $all_files; do
            echo "#include \"$f\""
        done
    } > "$unity_file"

    echo "Created: $unity_file"
    echo "Files:"
    printf "  "
    for f in $all_files; do
        printf "%s " "$f"
    done
    echo ""
fi

echo ""
echo "Done."
