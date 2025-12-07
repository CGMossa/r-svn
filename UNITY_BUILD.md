# Unity Builds for R - Investigation Results

Unity builds (also called jumbo builds) compile multiple source files together as a single translation unit, potentially enabling faster compilation through reduced I/O and better optimization opportunities.

## Summary

**7 of 8 R library packages now use unity builds** (methods, parallel, tcltk, grDevices, graphics, utils, grid).

**src/nmath now uses batched unity builds** (114 → 13 files, 89% reduction).

**src/main now uses batched unity builds** (98 → 15 files, 85% reduction).

All conflicts resolved via preprocessor techniques (`#define`/`#undef`) in the unity files. Only `grid.h` required source modification (adding include guards). Only stats and tools remain non-unity due to complex conflicts (`.c` file includes, yacc parser conflicts).

### Compilation Unit Savings

| Component | Original | Unity | Saved |
|-----------|----------|-------|-------|
| methods | 7 | 1 | 6 |
| parallel | 3 | 1 | 2 |
| tcltk | 3 | 1 | 2 |
| grDevices | 14 | 2* | 12 |
| graphics | 7 | 1 | 6 |
| utils | 6 | 1 | 5 |
| grid | 14 | 1 | 13 |
| **nmath** | **114** | **13** | **101 (89%)** |
| **main** | **98** | **15** | **83 (85%)** |
| **Total** | **266** | **36** | **230 (86%)** |

*grDevices: `devQuartz.c` compiled separately due to macOS header conflict

### Build Time Comparison

Measured on Apple M1 (8-core, `-j8`):

**Full unity-enabled build (main + nmath + libs):**

| Mode | Compilation Units | Time |
|------|-------------------|------|
| Unity | 36 | ~10s |
| Non-unity | 238 | ~9s |

**Note:** With high parallelism (8 cores), non-unity builds can be slightly faster because 238 small files distribute across cores more evenly than 36 larger batches. Unity builds provide more benefit with:

- Single-threaded or low-parallelism builds
- Slow I/O (network drives, HDDs)
- Incremental builds (fewer files to check)

To disable unity builds: `make UNITY_BUILD=no`

Timing recipes: `just time-full`, `just time-full-no-unity`, `just time-full-compare`

## Working Unity Builds

| Library | File | Notes |
|---------|------|-------|
| `methods` | `unity_methods.c` | Files including `Defn.h` must come first for `USE_RINTERNALS` |
| `parallel` | `unity_parallel.c` | `fork.c` includes `Defn.h` - must come first |
| `tcltk` | `unity_tcltk.c` | `tcltk.c` and `tcltk_unix.c` include `Defn.h` |
| `grDevices` | `unity_grDevices.c` | Static functions renamed; `devQuartz.c` excluded (macOS header conflict) |
| `graphics` | `unity_graphics.c` | `TypeCheck` and `Edge` renamed in `plot3d.c` |
| `utils` | `unity_utils.c` | `#undef IS_UTF8/ENC_KNOWN/IS_ASCII` before `utils.c` |
| `grid` | `unity_grid.c` | Added include guards to `grid.h` |

### Key Insight: Include Order Matters

Files that include `Defn.h` must come **before** files that only include `Rinternals.h`. This ensures `USE_RINTERNALS` is defined before any file references inline functions like `ALTCOMPLEX_ELT`, which would otherwise be declared as external symbols.

## Conflicts Found By Component

### src/main/ (RESOLVED)

Batched unity builds (12 batches + 3 separate files) with extensive `#undef` and `#define` renaming:

**Files compiled separately:**

- `main.c`: Must define `__MAIN__` before `Defn.h` for global variable initialization
- `memory.c`: Defines non-inline versions of `STRING_ELT`, `VECTOR_ELT` etc.
- `inlined.c`: Defines `COMPILING_R` to export non-inline API functions

**Conflicts resolved:**

- `RNG.c`: `#define long Int32` → `#undef long` after inclusion
- `envir.c`/`eval.c`: Both define `SET_BINDING_VALUE`/`BINDING_VALUE` → separate batches
- `gram.c`/`eval.c`: Both define `SymbolValue()` → separate batches
- `saveload.c`/`serialize.c`: Both define `MakeHashTable`, `HashAdd`, `HashGet` → separate batches
- `subassign.c`/`subset.c`: Both define `VECTOR_ELT_FIX_NAMED`, `R_DispatchOrEvalSP` → separate batches
- `cbuff` static variable in 4 files → `#define cbuff filename_cbuff` renaming
- `con_cleanup` static function in 5 files → `#define con_cleanup filename_con_cleanup` renaming
- `radixsort.c`: Redefines `warning` macro → placed last in batch after files using `warning()`
- `serialize.c`: Defines `PTRHASH` macro → `#undef PTRHASH` before `unique.c`

### src/nmath/ (RESOLVED)

Batched unity builds (13 batches) with extensive `#undef` between files:

- `gamma.c`, `lgamma.c`: xmax/xbig/dxrel macros → `#undef` between files
- `qbinom.c`, `qnbinom.c`, `qnbinom_mu.c`, `qpois.c`: Each uses `qDiscrete_search.h` which generates static `do_search()` with different signatures → separate batches
- `wilcox.c`, `signrank.c`: Both define `w`, `w_free`, `w_init_maybe` with different types → separate batches
- `rpois.c`: Defines `a0`-`a7` macros that conflict with `pnbeta.c` variables → `#undef` after inclusion

### src/library/stats/

- `Srunmed.c` includes `Trunmed.c`, causing double-definition issues
- `arima.c` defines `eps` macro that conflicts with `Defn.h` and `statsR.h`
- `_` macro redefinitions between `statsErr.h` and `Defn.h`
- Multiple files define conflicting `max`/`min` macros

### src/library/grDevices/ (RESOLVED)

- ~~`colors.c` and `devPS.c` both define `CheckAlpha()` with different signatures~~ → Renamed to `colors_CheckAlpha()`
- ~~`devPS.c` and `devPicTeX.c` both define `SetFont()` with different signatures~~ → Renamed to `PicTeX_SetFont()`
- `devQuartz.c` excluded from unity build (macOS `CarbonCore/AIFF.h` conflicts with `devPS.c` `Comment` struct)

### src/library/graphics/ (RESOLVED)

- ~~`plot.c` and `plot3d.c` both define `TypeCheck()`~~ → Renamed to `plot3d_TypeCheck()`
- ~~`graphics.c` defines `Edge` as a struct type; `plot3d.c` defines `Edge` as a static array~~ → Renamed to `plot3d_Edge`

### src/library/tools/

- `gramLatex.c` and `gramRd.c` are yacc-generated with conflicting `YYSYMBOL_*` enums
- `md5.c` uses local `rol` macro
- `sha256.c` has similar issues

### src/library/utils/ (RESOLVED)

- ~~`utils.c` declares `IS_UTF8`/`ENC_KNOWN` as function prototypes; these are macros in `Defn.h`~~ → `#undef` before `utils.c`

## Conflict Types and Solutions

| Conflict Type | Solution | Example |
|---------------|----------|---------|
| Static function name collision | `#define OldName NewName` before include, `#undef` after | `CheckAlpha` → `colors_CheckAlpha` |
| Macro/function declaration conflict | `#undef` macros before file with function declarations | `IS_UTF8` macro vs function prototype |
| `USE_RINTERNALS` ordering | Files with `Defn.h` must come first | Prevents `ALTCOMPLEX_ELT` undefined |
| macOS framework header conflict | Exclude file from unity, compile separately | `devQuartz.c` (Comment struct) |

## Remaining Blockers (stats, tools)

**stats**: `Srunmed.c` includes `Trunmed.c` (double-definition), extensive macro pollution (`eps`, `max`, `min`, `_`)

**tools**: yacc-generated `gramLatex.c`/`gramRd.c` have conflicting `YYSYMBOL_*` enums - would need parser regeneration with prefixed symbols

**splines**: Only 1 source file - unity build not applicable.

## Future Work

To enable unity builds for remaining packages:

**stats**: Would require either converting `Trunmed.c` to a header (or merging with `Srunmed.c`), plus extensive `#undef` work for `eps`, `max`, `min`, `_` macros

**tools**: Would require regenerating yacc parsers with prefixed symbols (`gramLatex_*`, `gramRd_*`)
