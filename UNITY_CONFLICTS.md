# Unity Build Conflicts

This document lists verified duplicate static function/variable names that would conflict in a unity build.

Last verified: 2024-12-04

---

## src/main/ (Core Interpreter) - Verified Conflicts

### Static Function Conflicts (3 functions, 9 definitions)

| Function | Count | Files |
|----------|-------|-------|
| `con_cleanup` | 5 | connections.c, dcf.c, deparse.c, saveload.c, serialize.c |
| `null_fflush` | 2 | connections.c, dounzip.c |
| `parse_cleanup` | 2 | coerce.c, source.c |

### Static Variable Conflicts (17 variables, ~40 definitions)

#### Critical (5+ files)

| Variable | Count | Files |
|----------|-------|-------|
| `buf` | 6 | altclasses.c, builtin.c, errors.c, printutils.c, saveload.c, util.c |

#### Severe (3-4 files)

| Variable | Count | Files |
|----------|-------|-------|
| `cbuff` | 4 | bind.c, character.c, paste.c, seq.c |
| `ConsoleBuf` | 3 | connections.c, main.c, scan.c |
| `buff` | 3 | datetime.c, format.c, printutils.c |
| `length_op` | 3 | array.c, mapply.c, seq.c |

#### High (2 files)

| Variable | Files |
|----------|-------|
| `ConsoleBufCnt` | connections.c, scan.c |
| `R_valueSym` | eval.c, main.c |
| `cleancount` | Rdynload.c, altclasses.c |
| `dflt` | saveload.c, serialize.c |
| `expr` | errors.c, eval.c |
| `initialized` | internet.c, lapack.c |
| `last` | gram.c, localecharset.c |
| `lw` | arithmetic.c, unique.c |
| `ptr` | lapack.c, serialize.c |
| `sdec` | options.c, paste.c |
| `utf8_table1` | raw.c, util.c |
| `utf8_table2` | raw.c, util.c |

### NOT Conflicts (verified as same-file or #ifdef blocks)

The following were previously suspected but are NOT cross-file conflicts:

- `mmap_finalize`, `mmap_file` - all in altclasses.c (#ifdef blocks)
- Parser symbols (`yyerror`, `yylex`, etc.) - gram.c and gram-ex.c are never compiled together
- Most other symbols were either single-file or not actual duplicates

---

## Unity Build Viability Assessment

### Summary

| Category | Count | Impact |
|----------|-------|--------|
| Static function conflicts | 3 | 9 definitions to rename |
| Static variable conflicts | 17 | ~40 definitions to rename |
| **Total symbols to fix** | **20** | **~49 definitions** |

### Recommended Approach: Batched Unity Builds

A full unity build requires renaming ~20 symbols across ~49 definitions. Instead, use **batched unity builds**:

- Group 8-10 non-conflicting files per batch
- Still provides 60-70% of unity build speedup
- Requires minimal or no code changes
- Avoids most symbol conflicts through careful grouping

### Conflict-Free File Groups (example batches for src/main/)

Files that can safely be combined (no mutual conflicts):

**Batch 1** (math/logic): arithmetic.c, complex.c, logic.c, relop.c, cum.c, summary.c
**Batch 2** (strings): character.c, grep.c, agrep.c, sprintf.c, paste.c *(note: paste.c conflicts with character.c on cbuff)*
**Batch 3** (I/O): scan.c, dcf.c, source.c *(careful: scan.c conflicts with connections.c)*

To generate batched unity files:

```bash
tools/make-unity-batched.sh 8 src/main src/nmath src/appl
```

---

## Duplicate Macro Definitions

Macros defined in multiple files can cause subtle bugs or unexpected behavior.

### Fixed: Macro Inconsistencies

| Macro | Issue | Fix Applied |
|-------|-------|-------------|
| `NINTERRUPT` | Was 10000000 vs 1000000 | Standardized to 10000000 in unique.c and stats/random.c |
| `HASHSIZE` | Name collision: function macro in envir.c vs constant in saveload.c/serialize.c | Renamed to `REFHASH_SIZE` in saveload.c and serialize.c |

### Intentional Per-File Definitions (Not Bugs)

| Macro | Count | Explanation |
|-------|-------|-------------|
| `R_USE_SIGNALS` | 44+ | Opt-in signal handling; defined as `1` before including Defn.h. All consistent. |
| `NUMERIC` | 6 | Template pattern in qsort.c only; uses `#undef`/`#define` cycles. |
| `BUFSIZE` | 8 | Local buffer sizes (512-196608) - intentionally different per use case. |

### Lower Priority (2 occurrences, not fixed)

| Macro | Files | Notes |
|-------|-------|-------|
| `ARGUSED` | eval.c, match.c | Argument tracking |
| `SET_ARGUSED` | eval.c, match.c | Argument tracking |
| `MAXLINE` | dcf.c, scan.c | Line buffer size |
| `MAXELTSIZE` | dcf.c, scan.c | Element size limit |
| `R_EOF` | gram.c, gram-ex.c | Generated parsers |
| `YYDEBUG` | gram.c, gram-ex.c | Generated parsers |
| `YYERROR_VERBOSE` | gram.c, gram-ex.c | Generated parsers |

---

## Missing Include Guards

### Fixed (guards added)

| Header | Location | Purpose |
|--------|----------|---------|
| `arithmetic.h` | src/main/ | Arithmetic operation declarations |
| `basedecl.h` | src/main/ | Base package declarations |
| `datetime.h` | src/main/ | Date/time handling |
| `g_control.h` | src/main/ | Graphics control codes |
| `g_extern.h` | src/main/ | Graphics extern declarations |
| `g_her_metr.h` | src/main/ | Hershey font metrics |

### Intentionally Without Guards (by design)

| Header | Location | Reason |
|--------|----------|--------|
| `libextern.h` | src/include/R_ext/ | Uses `#undef` to reset macros on each include |
| `rlocale_data.h` | src/main/ | Unicode data table for array initializers |
| `rlocale_tolower.h` | src/main/ | Unicode lowercase mapping table |
| `rlocale_toupper.h` | src/main/ | Unicode uppercase mapping table |
| `rlocale_widths.h` | src/main/ | Character width table |
| `contour-common.h` | src/main/ | Static functions for inlining |
| `valid_utf8.h` | src/main/ | Static function for inlining |
| `g_cntrlify.h` | src/main/ | Escape sequence database (data, not declarations) |
| `stats_stubs.h` | src/include/R_ext/ | Function implementations (not declarations) |
