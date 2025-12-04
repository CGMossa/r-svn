#!/bin/sh
# Generate conflict-aware unity build batches for src/main/
# Uses known static symbol conflicts to create safe file groupings
#
# Usage: tools/make-unity-smart.sh [output_dir]
# Output: Creates unity_batch*.c files in output_dir (default: src/main)

set -eu

OUTPUT_DIR="${1:-src/main}"
SRCDIR="src/main"

# Temp files for conflict tracking
TMPDIR="${TMPDIR:-/tmp}"
CONFLICT_FILE="$TMPDIR/unity_conflicts_$$"
BATCH_FILE="$TMPDIR/unity_batches_$$"
trap 'rm -f "$CONFLICT_FILE"* "$BATCH_FILE"*' EXIT

# Files that must be compiled alone (macro pollution, etc.)
# RNG.c defines "#define long Int32" (Knuth license prohibits changes)
# dounzip.c defines "#define local static" (zlib compatibility)
# agrep.c does "#undef pmatch" which breaks other files
ISOLATE_FILES="RNG.c dounzip.c agrep.c"

# Write known conflicts (files that cannot be in same batch)
cat > "$CONFLICT_FILE" << 'EOF'
connections.c dcf.c
connections.c deparse.c
connections.c saveload.c
connections.c serialize.c
dcf.c deparse.c
dcf.c saveload.c
dcf.c serialize.c
deparse.c saveload.c
deparse.c serialize.c
saveload.c serialize.c
connections.c dounzip.c
coerce.c source.c
altclasses.c builtin.c
altclasses.c errors.c
altclasses.c printutils.c
altclasses.c saveload.c
altclasses.c util.c
builtin.c errors.c
builtin.c printutils.c
builtin.c saveload.c
builtin.c util.c
errors.c printutils.c
errors.c saveload.c
errors.c util.c
printutils.c saveload.c
printutils.c util.c
saveload.c util.c
bind.c character.c
bind.c paste.c
bind.c seq.c
character.c paste.c
character.c seq.c
paste.c seq.c
connections.c main.c
connections.c scan.c
main.c scan.c
datetime.c format.c
datetime.c printutils.c
format.c printutils.c
array.c mapply.c
array.c seq.c
mapply.c seq.c
eval.c main.c
Rdynload.c altclasses.c
errors.c eval.c
internet.c lapack.c
gram.c localecharset.c
arithmetic.c unique.c
lapack.c serialize.c
options.c paste.c
raw.c util.c
# Macro conflicts discovered during unity compilation
envir.c eval.c
builtin.c envir.c
connections.c Renviron.c
connections.c gram.c
eval.c gram.c
builtin.c eval.c
EOF

# Check if a file must be isolated
is_isolated() {
    echo "$ISOLATE_FILES" | grep -qw "$1"
}

# Check if two files conflict
files_conflict() {
    f1="$1"
    f2="$2"
    # Isolated files conflict with everything
    if is_isolated "$f1" || is_isolated "$f2"; then
        return 0
    fi
    grep -q "^$f1 $f2$\|^$f2 $f1$" "$CONFLICT_FILE" 2>/dev/null
}

# Get all .c files (excluding unity files, gram-ex.c, and template files)
# Template files are included by other .c files and not compiled standalone
cd "$SRCDIR"
all_files=$(ls *.c 2>/dev/null | grep -v '^unity_' | grep -v '^gram-ex\.c$' | \
    grep -v '^machar\.c$' | grep -v '^qsort-body\.c$' | \
    grep -v '^split-incl\.c$' | grep -v '^xspline\.c$' | sort)
file_count=$(echo "$all_files" | wc -l | tr -d ' ')
cd - > /dev/null

echo "Processing $file_count files from $SRCDIR"
echo ""

# Initialize batch tracking
batch_num=0
for file in $all_files; do
    echo "" > "$BATCH_FILE.$file"  # Mark as unassigned
done

# Greedy batch assignment
for file in $all_files; do
    assigned=false

    # Try to add to existing batch
    b=1
    while [ $b -le $batch_num ]; do
        can_add=true

        # Get files in batch b
        batch_files=$(cat "$BATCH_FILE.batch$b" 2>/dev/null || echo "")

        for bf in $batch_files; do
            if files_conflict "$file" "$bf"; then
                can_add=false
                break
            fi
        done

        if $can_add; then
            echo "$file" >> "$BATCH_FILE.batch$b"
            assigned=true
            break
        fi
        b=$((b + 1))
    done

    # Create new batch if needed
    if ! $assigned; then
        batch_num=$((batch_num + 1))
        echo "$file" > "$BATCH_FILE.batch$batch_num"
    fi
done

echo "Created $batch_num batches:"
echo ""

# Clean old unity files
rm -f "$OUTPUT_DIR"/unity_batch*.c

# Generate unity files
b=1
while [ $b -le $batch_num ]; do
    batch_files=$(cat "$BATCH_FILE.batch$b")
    count=$(echo "$batch_files" | wc -l | tr -d ' ')

    unity_file="$OUTPUT_DIR/unity_batch${b}.c"

    {
        echo "/* Unity build batch $b - auto-generated */"
        echo "/* $count files - conflict-aware grouping */"
        echo "/* Regenerate with: tools/make-unity-smart.sh */"
        echo ""
        echo "#ifdef HAVE_CONFIG_H"
        echo "#include <config.h>"
        echo "#endif"
        echo ""
        echo "/* Enable all features needed by source files */"
        echo "#define R_USE_SIGNALS 1"
        echo "#define NEED_CONNECTION_PSTREAMS 1"
        echo "#ifndef Win32"
        echo "#define Unix 1"
        echo "#endif"
        echo "#define R_INTERFACE_PTRS 1"
        echo "#include <Defn.h>"
        echo "#include <Internal.h>"
        echo "#include <Rinterface.h>"
        echo ""
        echo "/* Forward declarations for internal functions used across files */"
        echo "/* Note: pmatch is #defined to Rf_pmatch in Rinternals.h */"
        echo "Rboolean Rf_pmatch(SEXP, SEXP, Rboolean);"
        echo ""
        for f in $batch_files; do
            echo "#include \"$f\""
        done
    } > "$unity_file"

    echo "  Batch $b: $count files -> $(basename "$unity_file")"
    printf "    "
    for f in $batch_files; do
        printf "%s " "$f"
    done
    echo ""
    echo ""

    b=$((b + 1))
done

echo "Done. Unity files in: $OUTPUT_DIR/"
echo ""
echo "To build with unity, modify Makefile to compile unity_batch*.c"
