#!/bin/sh
# Generate unity build for src/nmath/
# Usage: tools/make-unity-nmath.sh
#
# Creates unity_nmath_batch*.c in src/nmath/
# Files are batched to avoid macro/symbol conflicts

set -eu

SRCDIR="src/nmath"

# Known conflicts in nmath:
# - gamma.c defines xmax, xmin, dxrel macros
# - lgamma.c redefines xmax, dxrel
# - polygamma.c uses xmin as variable (conflicts with gamma.c macro)
# - pnorm.c defines swap_tail macro
# - qbeta.c uses swap_tail as variable
# - qbinom.c, qnbinom.c, qnbinom_mu.c, qpois.c each define their own
#   _dist_* macros and include qDiscrete_search.h (macro pollution)
#
# Files that define problematic macros (must be in separate batches):
BATCH1_ISOLATE="gamma.c lgamma.c polygamma.c"
BATCH2_ISOLATE="pnorm.c qbeta.c"
# Each of these files must be isolated - they define _dist_* macros
BATCH3_ISOLATE="qbinom.c qnbinom.c qnbinom_mu.c qpois.c"

# Get all .c files, excluding certain ones
cd "$SRCDIR"
all_files=""
for f in *.c; do
    case "$f" in
        unity_*.c) continue ;;           # Existing unity files
        mlutils.c) continue ;;           # This is a header-like file included by others
        sunif.c) continue ;;             # Old/unused
        *.c)
            if [ -z "$all_files" ]; then
                all_files="$f"
            else
                all_files="$all_files $f"
            fi
            ;;
    esac
done
cd - > /dev/null

# Separate files into batches
batch1=""  # Contains gamma.c conflicts - isolated files
batch2=""  # Contains pnorm/qbeta conflicts - isolated files
batch3=""  # Contains qDiscrete conflicts - isolated files
main_batch=""  # Everything else

for f in $all_files; do
    case " $BATCH1_ISOLATE " in
        *" $f "*)
            if [ -z "$batch1" ]; then batch1="$f"; else batch1="$batch1 $f"; fi
            continue
            ;;
    esac
    case " $BATCH2_ISOLATE " in
        *" $f "*)
            if [ -z "$batch2" ]; then batch2="$f"; else batch2="$batch2 $f"; fi
            continue
            ;;
    esac
    case " $BATCH3_ISOLATE " in
        *" $f "*)
            if [ -z "$batch3" ]; then batch3="$f"; else batch3="$batch3 $f"; fi
            continue
            ;;
    esac
    # Default: add to main batch
    if [ -z "$main_batch" ]; then main_batch="$f"; else main_batch="$main_batch $f"; fi
done

echo "Processing nmath files..."
echo "  Batch 1 (gamma conflicts): $batch1"
echo "  Batch 2 (pnorm conflicts): $batch2"
echo "  Batch 3 (qDiscrete conflicts): $batch3"
main_count=0
for f in $main_batch; do main_count=$((main_count + 1)); done
echo "  Main batch: $main_count files"

# Remove old unity files
rm -f "$SRCDIR"/unity_nmath*.c

# Create isolated batches for all conflict files
batch_num=1

# Batch 1 - gamma conflicts (each isolated)
for f in $batch1; do
    unity_file="$SRCDIR/unity_nmath_batch${batch_num}.c"
    {
        echo "/* Unity build for nmath - batch $batch_num (isolated: $f) */"
        echo "/* Regenerate with: tools/make-unity-nmath.sh */"
        echo ""
        echo "#include \"$f\""
    } > "$unity_file"
    echo "Created: $unity_file ($f)"
    batch_num=$((batch_num + 1))
done

# Batch 2 - pnorm/qbeta conflicts (each isolated)
for f in $batch2; do
    unity_file="$SRCDIR/unity_nmath_batch${batch_num}.c"
    {
        echo "/* Unity build for nmath - batch $batch_num (isolated: $f) */"
        echo "/* Regenerate with: tools/make-unity-nmath.sh */"
        echo ""
        echo "#include \"$f\""
    } > "$unity_file"
    echo "Created: $unity_file ($f)"
    batch_num=$((batch_num + 1))
done

# Batch 3 - qDiscrete conflicts (each isolated)
for f in $batch3; do
    unity_file="$SRCDIR/unity_nmath_batch${batch_num}.c"
    {
        echo "/* Unity build for nmath - batch $batch_num (isolated: $f) */"
        echo "/* Regenerate with: tools/make-unity-nmath.sh */"
        echo ""
        echo "#include \"$f\""
    } > "$unity_file"
    echo "Created: $unity_file ($f)"
    batch_num=$((batch_num + 1))
done

# Create main batch with remaining files
unity_file="$SRCDIR/unity_nmath_batch${batch_num}.c"
{
    echo "/* Unity build for nmath - batch $batch_num (main) */"
    echo "/* $main_count files */"
    echo "/* Regenerate with: tools/make-unity-nmath.sh */"
    echo ""
    for f in $main_batch; do
        echo "#include \"$f\""
    done
} > "$unity_file"
echo "Created: $unity_file ($main_count files)"

echo ""
echo "Done. Created $batch_num batch files."
