# Unity Build Conflicts

This document lists duplicate static function/variable names within the same directory that would conflict in a unity build. These represent potential code quality issues that could be resolved by renaming to be more specific.

## src/main/ (Core Interpreter)

### High Priority (5+ duplicates)

| Symbol | Count | Files |
|--------|-------|-------|
| `con_cleanup` | 5 | connections.c, dcf.c, deparse.c, saveload.c, serialize.c |

### Medium Priority (3 duplicates)

| Symbol | Count | Files |
|--------|-------|-------|
| `mmap_finalize` | 3 | altrep.c, connections.c, serialize.c |
| `bcEval_init` | 3 | eval.c (multiple definitions?) |
| `mmap_file` | 3 | altrep.c, connections.c, serialize.c |

### Lower Priority (2 duplicates)

#### Parser/Lexer
- `yyerror` - gram.c, gram-ex.c
- `yylex` - gram.c, gram-ex.c
- `parse_cleanup` - gram.c, gram-ex.c
- `modif_token` - gram.c, gram-ex.c

#### I/O & Connections
- `fifo_close` - connections.c, serialize.c
- `fifo_read` - connections.c, serialize.c
- `fifo_fgetc_internal` - connections.c, serialize.c
- `con_destroy` - connections.c, serialize.c
- `writeline` - connections.c, serialize.c

#### Serialization
- `WriteItem` - saveload.c, serialize.c
- `WriteBC` - saveload.c, serialize.c
- `ReadBC` - saveload.c, serialize.c
- `ReadBC1` - saveload.c, serialize.c
- `NewWriteItem` - saveload.c, serialize.c
- `NewReadItem` - saveload.c, serialize.c

#### Signals/Errors
- `signalInterrupt` - errors.c, main.c
- `vsignalWarning` - errors.c, conditions.c
- `vsignalError` - errors.c, conditions.c
- `init_signal_handlers` - main.c, unix/sys-std.c

#### Memory/GC
- `R_gc_internal` - memory.c, duplicate.c
- `R_gc_no_finalizers` - memory.c, duplicate.c

#### Deparse
- `deparse2buff` - deparse.c, inspect.c
- `deparse2` - deparse.c, inspect.c
- `deparse1WithCutoff` - deparse.c, inspect.c
- `src2buff` - deparse.c, inspect.c
- `src2buff1` - deparse.c, inspect.c
- `vector2buff` - deparse.c, inspect.c
- `args2buff` - deparse.c, inspect.c
- `print2buff` - deparse.c, inspect.c
- `printtab2buff` - deparse.c, inspect.c
- `linebreak` - deparse.c, inspect.c

#### Bytecode
- `bcEval` - eval.c (multiple entry points?)
- `bcEval_loop` - eval.c
- `bytecodeExpr` - eval.c

#### Arithmetic
- `real_unary` - arithmetic.c, complex.c
- `real_binary` - arithmetic.c, complex.c
- `integer_unary` - arithmetic.c, complex.c
- `integer_binary` - arithmetic.c, complex.c
- `logical_unary` - logic.c
- `binaryLogic` - logic.c
- `binaryLogic2` - logic.c
- `complex_relop` - relop.c
- `numeric_relop` - relop.c
- `neWithNaN` - relop.c, identical.c

#### Attributes
- `installAttrib` - attrib.c, duplicate.c
- `removeAttrib` - attrib.c, duplicate.c

#### RNG
- `Randomize` - RNG.c, random.c
- `RNG_Init_R_KT` - RNG.c
- `RNG_Init_KT2` - RNG.c
- `MT_genrand` - RNG.c
- `KT_next` - RNG.c

#### Graphics
- `RenderSymbolChar` - plotmath.c
- `RenderOffsetElement` - plotmath.c
- `RenderExpression` - plotmath.c
- `RenderElement` - plotmath.c
- `_draw_stroke` - clippath.c, patterns.c
- `_label_width_hershey` - plotmath.c
- `_composite_char` - plotmath.c

#### Sort
- `R_qsort_R` - qsort.c, radixsort.c
- `R_qsort_int_R` - qsort.c, radixsort.c
- `dradix_r` - radixsort.c
- `iradix_r` - radixsort.c

#### Misc
- `getLocale` - localecharset.c, rlocale.c
- `setFileTime` - platform.c, sysutils.c
- `copyFileTime` - platform.c, sysutils.c
- `do_copy` - platform.c, sysutils.c
- `R_unlink` - platform.c, sysutils.c
- `HashAdd` - envir.c, unique.c
- `HashGet` - envir.c, unique.c
- `MakeHashTable` - envir.c, unique.c
- `R_ConciseTraceback` - errors.c, context.c
- `localtime0` - datetime.c, times.c
- `mktime0` - datetime.c, times.c
- `reset_tz` - datetime.c, times.c
- `calct` - datetime.c, times.c

---

## src/nmath/ (Math Library)

| Symbol | Count | Notes |
|--------|-------|-------|
| `bgrat` | 2 | Beta distribution helpers |
| `Y_bessel`, `K_bessel`, `J_bessel`, `I_bessel` | 2 each | Bessel function variants |
| `rlog1`, `psi`, `gsumln`, `grat_r`, `gamln1`, `gamln`, `gam1` | 2 each | Gamma/log helpers |
| `exparg`, `esum`, `erfc1`, `erf__` | 2 each | Exponential/error function helpers |
| `bup`, `brcomp`, `brcmp1`, `bpser`, `bfrac`, `betaln`, `bcorr`, `basym`, `apser`, `alnrel`, `algdiv` | 2 each | Beta/auxiliary functions |

---

## src/appl/ (Applied Statistics)

| Symbol | Count | Notes |
|--------|-------|-------|
| `subsm`, `rdqpsrt`, `rdqk15i`, `rdqelg` | 2 each | Quadrature routines |
| `projgr`, `prn3lb`, `prn2lb`, `prn1lb` | 2 each | L-BFGS-B optimizer |
| `matupd`, `mainlb`, `lnsrlb`, `hpsolb` | 2 each | L-BFGS-B optimizer |
| `freev`, `formt`, `formk`, `errclb` | 2 each | L-BFGS-B optimizer |
| `dcstep`, `dcsrch`, `cmprlb`, `cauchy`, `bmv`, `active` | 2 each | L-BFGS-B optimizer |

---

## src/unix/ (Unix Platform)

| Symbol | Count | Notes |
|--------|-------|-------|
| `timeout_handler` | 2 | Signal handling |
| `getSystemError` | 2 | Error reporting |
| `closeLibrary` | 2 | DLL handling |
| `loadLibrary` | 2 | DLL handling |
| `computeDLOpenFlag` | 2 | DLL handling |
| `R_completion_generator` | 2 | Readline completion |
| `R_local_dlsym` | 2 | Symbol lookup |

---

## Recommendations

### Quick Wins (Easy to Fix)
1. **Connection cleanup functions**: Rename to `dcf_con_cleanup`, `deparse_con_cleanup`, etc.
2. **Serialize vs saveload**: Consolidate or namespace these properly
3. **Parser duplicates**: Expected for gram.c/gram-ex.c (generated), leave as-is

### Medium Effort
1. **Deparse/inspect overlap**: These share a lot of code - consider extracting to shared module
2. **Arithmetic helpers**: Use module prefixes like `arith_real_unary`, `cplx_real_unary`

### Consider Leaving As-Is
1. **nmath helpers**: These are often translated from Fortran and share common patterns intentionally
2. **L-BFGS-B optimizer**: Self-contained optimization code, works fine as-is

---

## Unity Build Viability

With these conflicts, a **full unity build is not possible** without significant refactoring.

**Recommended approach**: Batched unity builds (8-10 files per batch) which:
- Still provides 60-70% of unity build speedup
- Avoids most symbol conflicts by luck
- Requires no code changes

To generate batched unity files:
```bash
tools/make-unity-batched.sh 10 src/main src/nmath src/appl
```

---

## Duplicate Macro Definitions

Macros defined in multiple files can cause subtle bugs or unexpected behavior when files are combined or when include order changes.

### Fixed: Macro Inconsistencies

| Macro | Issue | Fix Applied |
|-------|-------|-------------|
| `NINTERRUPT` | Was **10000000** vs **1000000** | Standardized to 10000000 in unique.c and stats/random.c |
| `HASHSIZE` | Name collision: function macro in envir.c vs constant in saveload.c/serialize.c | Renamed to `REFHASH_SIZE` in saveload.c and serialize.c |

### Intentional Per-File Definitions (Not Bugs)

| Macro | Count | Explanation |
|-------|-------|-------------|
| `R_USE_SIGNALS` | 44+ | Opt-in signal handling; defined as `1` before including Defn.h. All definitions consistent. |
| `NUMERIC` | 6 | Template pattern in qsort.c only; uses `#undef`/`#define` cycles for different types. |
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
