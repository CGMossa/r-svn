# Unity Builds for R - Investigation Results

Unity builds (also called jumbo builds) compile multiple source files together as a single translation unit, potentially enabling faster compilation through reduced I/O and better optimization opportunities.

## Summary

**7 of 8 R library packages now use unity builds** (methods, parallel, tcltk, grDevices, graphics, utils, grid).

All conflicts resolved via preprocessor techniques (`#define`/`#undef`) in the unity files. Only `grid.h` required source modification (adding include guards). Only stats and tools remain non-unity due to complex conflicts (`.c` file includes, yacc parser conflicts).

### Compilation Unit Savings

| Library | Original | Unity | Saved |
|---------|----------|-------|-------|
| methods | 7 | 1 | 6 |
| parallel | 3 | 1 | 2 |
| tcltk | 3 | 1 | 2 |
| grDevices | 14 | 2* | 12 |
| graphics | 7 | 1 | 6 |
| utils | 6 | 1 | 5 |
| grid | 14 | 1 | 13 |
| **Total** | **54** | **8** | **46 (85%)** |

*grDevices: `devQuartz.c` compiled separately due to macOS header conflict

### Build Time Comparison

Measured on Apple M1 (8-core, `-j8`):

**7 unity-enabled libraries only:**

| Mode | Compilation Units | Time | Speedup |
|------|-------------------|------|---------|
| Unity (default) | 8 | 6.2s | **1.5x faster** |
| Non-unity | 54 | 9.3s | baseline |

**Full R build** (libraries are ~10% of total):

| Mode | Time |
|------|------|
| Unity (default) | 72s |
| Non-unity | 69s |

Unity builds save ~3s on library compilation but don't affect src/main, src/nmath, or other components.

To disable unity builds: `make UNITY_BUILD=no`

Timing recipes: `just time-libs` and `just time-libs-no-unity`

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

### src/main/

- `main.c` must define `__MAIN__` before `Defn.h` is included for global variable initialization
- Unity batch design includes headers before source files, breaking this requirement
- Extensive macro pollution between files

### src/nmath/

- `gamma.c`, `lgamma.c`, `polygamma.c` share xmin/xmax/dxrel macros
- `pnorm.c`, `qbeta.c` have swap_tail conflicts
- `qbinom.c`, `qnbinom.c`, `qnbinom_mu.c`, `qpois.c` have _dist_* macro conflicts

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

**src/main** and **src/nmath**: More complex due to `__MAIN__` pattern and extensive macro pollution - not recommended for unity builds
