# Unity Builds for R - Investigation Results

Unity builds (also called jumbo builds) compile multiple source files together as a single translation unit, potentially enabling faster compilation through reduced I/O and better optimization opportunities.

## Summary

**Unity builds are NOT viable for R without significant code refactoring.**

After extensive testing, we found that virtually every R subproject has static symbol/macro conflicts that prevent combining source files into single translation units.

## Scripts Created (Experimental)

| Script | Purpose | Status |
|--------|---------|--------|
| `tools/make-unity-library.sh` | Generate unity files for library packages | Generates files, but they don't compile |
| `tools/make-unity-nmath.sh` | Generate unity files for nmath | Disabled |

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

### src/library/grDevices/

- `colors.c` and `devPS.c` both define `CheckAlpha()` with different signatures
- `devPS.c` and `devPicTeX.c` both define `SetFont()` with different signatures

### src/library/graphics/

- `plot.c` and `plot3d.c` both define `TypeCheck()`
- `graphics.c` defines `Edge` as a struct type
- `plot3d.c` defines `Edge` as a static array

### src/library/tools/

- `gramLatex.c` and `gramRd.c` are yacc-generated with conflicting `YYSYMBOL_*` enums
- `md5.c` uses local `rol` macro
- `sha256.c` has similar issues

### src/library/utils/

- `utils.c` declares `IS_UTF8`/`ENC_KNOWN` as function prototypes
- These are macros in `Defn.h`, causing macro expansion at declaration sites

## Why Unity Builds Don't Work in R

The R codebase has characteristics that fundamentally conflict with unity builds:

1. **Macro Pollution**: Many `.c` files define short macros (`eps`, `max`, `min`, `Edge`) without namespacing that leak into other files

2. **Static Function Name Collisions**: Different files define `static` functions with identical names but different signatures (`CheckAlpha`, `SetFont`, `TypeCheck`)

3. **Header-as-Implementation**: Files like `Trunmed.c` are `#include`d by other `.c` files

4. **Yacc/Bison Conflicts**: Generated parser files have identical symbol names

5. **Macro/Function Declaration Conflicts**: Some symbols are macros in headers but declared as functions in source files

6. **Global Variable Initialization**: The `__MAIN__` pattern requires specific compilation order

## Recommendations

Unity builds would require significant refactoring of R's C codebase:

1. Prefix all local macros with file-specific prefixes (e.g., `ARIMA_eps` instead of `eps`)
2. `#undef` macros immediately after use
3. Rename static functions to be unique across the codebase
4. Move away from `#include`ing `.c` files
5. Restructure global variable initialization to avoid `__MAIN__`

Given the scope of changes required, unity builds are not a practical optimization for R at this time.
