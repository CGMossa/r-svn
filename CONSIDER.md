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

## Deprecated Libtool Macros

The following macros from `m4/libtool.m4` are deprecated (defined via `AU_DEFUN`) and should be migrated to their modern equivalents if still used:

| Deprecated Macro | Modern Replacement |
|-----------------|-------------------|
| `AC_LIBTOOL_CXX` | `LT_LANG([CXX])` |
| `AC_LIBTOOL_F77` | `LT_LANG([F77])` |
| `AC_LIBTOOL_FC` | `LT_LANG([FC])` |
| `AC_LIBTOOL_GCJ` | `LT_LANG([GCJ])` |
| `AC_LIBTOOL_RC` | `LT_LANG([RC])` |
| `AC_LIBTOOL_DLOPEN` | `LT_INIT([dlopen])` |
| `AC_LIBTOOL_WIN32_DLL` | `LT_INIT([win32-dll])` |
| `AC_LIBTOOL_PICMODE` | N/A (obsolete) |
| `AM_ENABLE_SHARED` | `LT_INIT` with `--enable-shared` |
| `AM_DISABLE_SHARED` | `LT_INIT` with `--disable-shared` |
| `AM_ENABLE_STATIC` | `LT_INIT` with `--enable-static` |
| `AM_DISABLE_STATIC` | `LT_INIT` with `--disable-static` |
| `AC_ENABLE_FAST_INSTALL` | `LT_INIT` options |
| `AC_DISABLE_FAST_INSTALL` | `LT_INIT` options |

**Status**: ✅ Audited. Results:

- `configure.ac`: Clean - uses `LT_INIT([disable-static])` (not deprecated `AC_DISABLE_STATIC`)
- `m4/R.m4`: Fixed `AC_TRY_LINK_FUNC` → `AC_LINK_IFELSE([AC_LANG_CALL(...)])` (2 occurrences)
- `m4/libtool.m4`: Contains deprecated macros (`AC_LANG_SAVE`, `AS_SHELL_SANITIZE`) but this is the standard libtool distribution file - **do not modify**

### Other Deprecated Macros (Not Used)

| Macro | Status |
|-------|--------|
| `AC_FOREACH` | Not used (alias of `m4_foreach_w`) |
| `AS_SHELL_SANITIZE` | Only in libtool.m4 (standard file) |
| `AC_TRY_LINK` | Not used; fixed `AC_TRY_LINK_FUNC` |
| `AC_TRY_COMPILE` | Not used |
| `AC_TRY_RUN` | Not used |
| `AC_TRY_CPP` | Not used |

**Note**: `AS_INIT` is automatically called by `AC_INIT`, so no explicit invocation needed.

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
| `m4/libtool.m4` | Libtool support | Standard - do not modify |
| `m4/ltoptions.m4` | Libtool options | Internal |
| `m4/ltsugar.m4` | Libtool helper macros | Internal |
| `m4/ltversion.m4` | Libtool version info | Internal |
| `m4/lt~obsolete.m4` | Deprecated libtool macros | Compatibility only |

---

## Autoconf Warning

```text
configure.ac: warning: AC_REQUIRE: 'AC_FC_LIBRARY_LDFLAGS' was expanded before it was required
```

**Root cause**: `LT_INIT` internally calls `AC_FC_LIBRARY_LDFLAGS` before `R_PROG_FC_APPEND_UNDERSCORE` (which uses `AC_FC_WRAPPERS`) runs. This is an ordering issue inside autoconf/libtool internals.

**Status**: ⚠️ Cannot fix without patching autoconf. The warning is harmless - `AC_FC_LIBRARY_LDFLAGS` has already been expanded by the time it's "required", so the check succeeds. This is a cosmetic warning only.

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
