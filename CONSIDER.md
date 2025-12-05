# Considerations for Future Work

This document tracks potential improvements and items for future investigation.

## pkg-config and Simplifications

- Extend pkg-config-first to BLAS/LAPACK (e.g., openblas, blas, lapack .pc files) before ACX_BLAS/legacy search.
- Add pkg-config hints for jpeg2000/webp2 or other optional bitmap codecs if we keep those features.
- ~~Optionally silence libtool/clang probe logs in config.log if they bother users.~~
  **Analysis**: Libtool's `_LT_LINKER_SHLIBS` and `_LT_SYS_DYNAMIC_LINKER` macros don't use `AC_CACHE_*` by design. They probe for each language (C, C++, Fortran) fresh every time (~70 uncacheable checks). Practical workarounds:
  - Use `QUIET=1` to suppress configure output
  - Use `just sandbox-quick` for rebuilds (skips configure entirely)
  - Accept ~7s configure time with cache (vs ~40s without)
- ICU could use `icu-uc`/`icu-i18n` pkg-config instead of custom link tests; also consider `icucore` shim on macOS.
- Tcl/Tk can be resolved via pkg-config on Homebrew (`tcl`, `tk`), falling back to tclConfig.sh/tkConfig.sh only when needed.
- Capture Homebrew pkg-config availability snapshots for the above to guide which fallbacks remain necessary.
- If pkg-config readline remains elusive, harden the fallback to pull `-lncurses`/`-ltinfo` (or prefer a Homebrew PKG_CONFIG_PATH hint) to avoid linking against libedit.
- Decide whether missing docs (FAQ/resources.html) should be generated or dropped from install to keep out-of-tree builds clean.
- HTML/manual generation currently warns when `texi2any` is absent; consider gating those targets behind a switch or documenting the sandbox expectation.

---

## m4 Macro Audit Results

### Unused Macros

**Result: 0 unused R_* macros found.** All defined macros are either directly called in `configure.ac` or used internally by other macros.

### m4 Files and Status

| File | Purpose | Status |
|------|---------|--------|
| `m4/R.m4` | R-specific autoconf macros | Core - all macros used |
| `m4/rust.m4` | Rust compiler detection | Active |
| `m4/cairo.m4` | Cairo/Pango graphics | Active |
| `m4/cxx.m4` | C++ standard detection | Active |
| `m4/openmp.m4` | OpenMP detection | Active |
| `m4/bigendian.m4` | Byte order detection | Active |
| `m4/codeset.m4` | Character encoding | Active |
| `m4/stat-time.m4` | File stat time handling | Active |
| `m4/clibs.m4` | Library linking (AC_LIB_*) | Active |
| `m4/gettext.m4` | GNU gettext/NLS | Active (when NLS enabled) |
| `m4/gettext-lib.m4` | Gettext library detection | Active (when NLS enabled) |

---

## Fast-Config Coverage

The `--enable-fast-config` option now skips:

### Subsystem Checks (original)

- X11, Cairo, Tcl/Tk, Aqua, Java, NLS
- Recommended packages

### Tool Checks (added)

- TeX/LaTeX tools (tex, pdftex, pdflatex, makeindex, texi2any, texi2dvi)
- Browser detection (xdg-open, firefox, etc.)
- PDF viewer detection (acroread, evince, xpdf, gv, okular, etc.)
- Maintainer tools (aclocal, autoconf, autoheader, yacc, notangle)

### Potential Future Additions

- [ ] `R_BITMAPS2` - PNG/JPEG library checks (could default to "not found")
- [ ] Library version checks with known-good modern defaults

---

## Documentation Needs

Priority macros lacking documentation:

- `R_PROG_CC_MAKEFRAG` / `R_PROG_CXX_MAKEFRAG` / `R_PROG_OBJC_MAKEFRAG`
- `R_PROG_CC_LO_MAKEFRAG`
- `R_BLAS_LIBS` / `R_LAPACK_LIBS`
- `R_ICONV` / `R_ICU`

---

## External Dependency Notes

| Library | Macro | Notes |
|---------|-------|-------|
| PCRE | `R_PCRE` | PCRE1 is deprecated, prefer PCRE2 |
| ICU | `R_ICU` | Check minimum version requirements |
| libcurl | `R_LIBCURL` | Essential for modern R |

---

## Testing Recommendations

- [ ] Out-of-tree builds (covered by `just configure-sandbox`)
- [ ] Cross-compilation scenarios
- [ ] Minimal dependency builds
- [ ] All compiler combinations (GCC, Clang)

---

## Unity Build Conflicts in src/main/

This section documents all conflicts preventing a single-file unity build of R's `src/main/` directory. Currently requires **11 batches** to compile 103 source files. Fixing these issues would enable faster compilation through better unity builds.

### Files Requiring Isolation (Macro Pollution)

These files define macros that pollute the global namespace and break other files:

| File | Problem | Fixable? |
|------|---------|----------|
| `RNG.c` | `#define long Int32` | ❌ Knuth license prohibits modification |
| `dounzip.c` | `#define local static` | ⚠️ zlib compatibility layer |
| `agrep.c` | `#undef pmatch` at line 33 | ✅ Could wrap in push/pop pragma |
| `radixsort.c` | `#define warning(...) Do not use warning in this file` | ✅ Should use different mechanism |
| `memory.c` | Provides external linkage versions of inline functions (STRING_ELT, etc.) | ⚠️ Architectural - needs careful handling |

### Template Files (Not Directly Compiled)

These `.c` files are actually templates included by other files:

| File | Included By | Notes |
|------|-------------|-------|
| `machar.c` | `platform.c` | Uses `DTYPE` template parameter |
| `qsort-body.c` | `qsort.c` | Sorting template |
| `split-incl.c` | `split.c` | String splitting template |
| `xspline.c` | `graphics.c` | X-spline drawing template |

### Macro Conflicts (Same Name, Different Values)

These macros are defined differently in different files:

| Macro | Files | Values | Priority |
|-------|-------|--------|----------|
| `NINTERRUPT` | `unique.c`, `random.c` (stats) | Was 1000000 vs 10000000 | ✅ **FIXED** - unified to 10000000 |
| `HASHSIZE` | `envir.c`, `saveload.c`, `serialize.c` | 1099 (function) vs 1099 (constant) | ✅ **FIXED** - renamed to REFHASH_SIZE |
| `simple_as_environment` | `builtin.c` vs `envir.c`/`eval.c` | Returns `arg` vs `R_NilValue` | ⚠️ Inconsistent with comment |
| `imax2` | `bind.c`, `summary.c`, `paste.c` vs `Rmath.h` | Local definition vs `Rf_imax2` | ✅ Use Rmath.h version |
| `BUF_SIZE` | `Renviron.c` vs `connections.c` | 100000 vs 1000 | ✅ Rename to context-specific names |
| `BUFSIZE` | `deparse.c` vs `errors.c` | 512 vs 8192 | ✅ Rename to context-specific names |
| `R_INT_MIN` | `arithmetic.c` vs `sort.c` vs `summary.c` vs `altclasses.c` | `-INT_MAX` vs `1+INT_MIN` vs `(1+INT_MIN)` | ✅ Centralize in header |
| `SMALL` | `engine.c` vs `random.c` | 0.25 vs 10000 | ✅ Rename to context-specific names |
| `PTRHASH` | `memory.c` (macro) vs `unique.c` (function) | Macro vs inline function | ✅ Rename unique.c version |
| `I` | `<complex.h>` vs `qsort.c` | `_Complex_I` vs variable name | ✅ Rename variable in qsort.c |
| `COMMENT` | `gzio.h` vs `gram.c` | 0x10 vs enum value 290 | ⚠️ gram.c is generated |
| `NEXT` | `eval.c` vs `gram.c` | Macro vs token constant | ⚠️ gram.c is generated |

### Function/Symbol Redefinitions

These functions are defined identically in multiple files (code duplication):

| Symbol | Files | Type | Priority |
|--------|-------|------|----------|
| `VECTOR_ELT_FIX_NAMED` | `subassign.c:583`, `subset.c:48` | static inline | ✅ Move to shared header |
| `R_DispatchOrEvalSP` | `subassign.c:1546`, `subset.c:652` | function | ✅ Move to shared header |
| `R_strieql` | `platform.c:145`, `sysutils.c:586` | static function | ✅ Move to shared header |
| `DUPLICATE_ATTRIB` | `duplicate.c` (macro) vs `memory.c` (function) | macro vs function | ⚠️ Architectural |
| `SHALLOW_DUPLICATE_ATTRIB` | `coerce.c` (macro) vs `memory.c` (function) | macro vs function | ⚠️ Architectural |
| `CLEAR_ATTRIB` | `coerce.c` (macro) vs `memory.c` (function) | macro vs function | ⚠️ Architectural |
| `SET_BINDING_VALUE` | `envir.c` (macro) vs `eval.c` (function) | macro vs function | ⚠️ Architectural |
| `BINDING_VALUE` | `envir.c`, `eval.c` | static inline | ✅ Consolidate |
| `STRING_ELT` | `Rinlinedfuns.h` vs `memory.c` | inline vs external | ⚠️ Intentional (ABI) |

### Static Symbol Conflicts (Name Collisions)

These static functions/variables have the same name in different files:

#### Static Functions (9 definitions across 3 groups)

| Function | Files |
|----------|-------|
| `ScalarString1` | `altclasses.c`, `builtin.c`, `errors.c`, `printutils.c`, `saveload.c`, `util.c` |
| `APTS` | `bind.c`, `character.c`, `paste.c`, `seq.c` |
| `fillUp` | `datetime.c`, `format.c`, `printutils.c` |

#### Static Variables (~40 definitions across 17 groups)

| Variable | Files |
|----------|-------|
| `R_OutputCon` | `connections.c`, `dcf.c`, `deparse.c`, `saveload.c`, `serialize.c` |
| `streamerr` | `connections.c`, `dounzip.c` |
| `known` | `coerce.c`, `source.c` |
| `gcall` | `array.c`, `mapply.c`, `seq.c` |
| `do_fast` | `arithmetic.c`, `unique.c` |
| `scalar_stack_*` | `altclasses.c`, `errors.c`, `printutils.c`, `saveload.c`, `util.c` |
| `NasAttrib` | `lapack.c`, `serialize.c` |
| `Table` | `gram.c`, `localecharset.c` |
| And more... | See `tools/make-unity-smart.sh` for full list |

### Recommended Fixes (Priority Order)

#### High Priority (Easy Wins)

1. **Centralize `R_INT_MIN`** - Define once in a header, remove local definitions
2. **Rename local buffer macros** - `BUF_SIZE`, `BUFSIZE`, `SMALL` should have file-specific prefixes
3. **Move duplicate functions to headers** - `VECTOR_ELT_FIX_NAMED`, `R_DispatchOrEvalSP`, `R_strieql`
4. **Fix `simple_as_environment`** in `builtin.c` to match `envir.c`/`eval.c` (return `R_NilValue`)
5. **Rename `I` variable** in `qsort.c` to avoid conflict with `<complex.h>`

#### Medium Priority (Requires Care)

1. **Wrap `agrep.c`'s `#undef pmatch`** in a local scope or use different approach
2. **Replace `radixsort.c`'s warning poison** with static analysis annotation
3. **Rename `PTRHASH` function** in `unique.c` to `unique_ptrhash` or similar
4. **Consolidate `BINDING_VALUE`/`SET_BINDING_VALUE`** between `envir.c` and `eval.c`

#### Low Priority (Architectural)

1. **`memory.c` external linkage functions** - Needed for shared library ABI, must stay isolated
2. **`RNG.c` Knuth code** - Cannot modify due to license restrictions
3. **`dounzip.c` zlib compatibility** - Would need upstream coordination
4. **`gram.c` generated code** - Would need changes to grammar/bison input

### Current Unity Build Statistics

```text
103 source files → 11 batches
- Batch 1: 71 files (main batch)
- Batch 4: 16 files
- Batch 5: 5 files
- Batch 7: 4 files
- Batches 2,3,6,8,9,10,11: 1 file each (isolated)
```

**Goal**: Reduce to 2-3 batches by fixing the high/medium priority issues above.

### See Also

- `tools/make-unity-smart.sh` - Unity build generator with full conflict list
- `UNITY_CONFLICTS.md` - Original conflict investigation notes
