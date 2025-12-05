# Plan

## Done

- `autoreconf -vif` now succeeds (only gettext version warning) after fixing Makefrag AC_CONFIG_COMMANDS duplication and libcurl/libdeflate/pkg-config wiring.
- Added pkg-config-first detection for zlib/bzip2/lzma/zstd/libdeflate/tre/libcurl/readline, cairo/pango, BLAS/LAPACK, X11 stack, TIFF extras (webp/jbig/zstd), and TI-RPC; restored `m4` dir and `tools/missing`.
- Added `--disable-site-config` toggle to keep builds from pulling config.site / ~/.R/config; documented runtime knobs in AGENTS.md.
- Justfile smoke tests: `configure-min` (no X/cairo/recommended) and `configure-full` pass; new `configure-sandbox` exercises `--disable-site-config --no-create`.
- Investigated `--no-create`: configure still writes `config.log` and `config.status` but skips Makefiles; captured in sandbox recipe.
- Ran `just configure-sandbox` with `PKG_CONFIG_PATH=/opt/homebrew/opt/readline/lib/pkgconfig`: fallback works; pkg-config still missing `xt` and `libjbig` (Homebrew lacks `xt.pc`, jbigkit ships no `.pc`), message emitted but X stack found via legacy probe.
- Reviewed autom4te.cache `output.*`: only expected warnings (bundled libintl, missing TeX bits); no hidden errors. Removed stray backup files.
- Added Rust toolchain detection + `Makefrag.rs`; R CMD tooling accepts `*.rs`. ECHO cleanup for new rules and shared shlib.mk.
- Removed SVN revision stamping/checks; doc install tolerates missing FAQ/resources; GETDISTNAME falls back to date when no SVN-REVISION.
- Sandbox builds now copy the tree into `/tmp` and configure via relative `../src`; new `sandbox-repl` recipe builds/installs to a temp prefix and launches R; LDFLAGS/CPPFLAGS pinned for Homebrew readline/xz and PKG_CONFIG_PATH defaults to Homebrew readline.
- Out-of-tree build hygiene: Makeconf now pulls `share/make/vars.mk` and mkinstalldirs from the build tree, no absolute includes; `top_srcdir` stops clobbering per-dir values; helper scripts resolve without symlinks.
- `--enable-fast-config` added to skip slow optional subsystems; wired into `configure-fast`/`sandbox-repl`.
- Full end-to-end `just sandbox-repl` now succeeds, installs under a temp prefix, and drops into R; remaining warnings are texi2any/html-doc gaps and missing doc/resources.html when absent in source.
- `--disable-site-config` now also removes the default user library path (`~/Library/...`) so sandboxed `.libPaths()` stays within the temp prefix.
- New `--disable-html-docs` switch (and `HTML_DOCS=no` env toggle in justfile) skips building/installing HTML manuals/NEWS, silencing texi2any/resources warnings during fast sandbox builds.
- Streamlined `tools/rsync-recommended` (mktemp, cleaner path handling) and added VS Code file associations for Makefile-like infiles.
- **Removed libtool dependency entirely.** R already had its own complete shared library detection (SHLIB_LD, SHLIB_LDFLAGS, CPICFLAGS, etc.) and never actually used libtool for building. Changes:
  - Removed `LT_INIT([disable-static])` from configure.ac
  - Replaced `LT_LIB_M` with inline LIBM detection (checks `-lm` on non-Darwin/Cygwin)
  - Added default `wl="-Wl,"`, `shlibpath_var`, `striplib`/`old_striplib` platform detection
  - Removed `LIBTOOL` variable from both Makeconf.in files
  - Removed libtool installation from src/scripts/Makefile.in
  - Removed libtool build rule and deps from root Makefile.in
  - Deleted 5 m4 files: libtool.m4, ltoptions.m4, ltsugar.m4, ltversion.m4, lt~obsolete.m4 (~13k lines)
  - Deleted tools/ltmain.sh (~11k lines) - the libtool script template
  - Removed `AC_REQUIRE([LT_INIT])` from m4/R.m4 (R_INTERNAL_XDR_USABLE macro)
  - No libtool script generated (~364KB savings per build)
  - Configure output is significantly quieter (no libtool probes for C/C++/Fortran)
- **Added Homebrew auto-detection to config.site** for macOS builds:
  - Automatically detects Homebrew prefix (works on Intel `/usr/local` and Apple Silicon `/opt/homebrew`)
  - Sets CPPFLAGS/LDFLAGS for keg-only packages: readline, xz, gettext
  - Sets PKG_CONFIG_PATH for: readline, xz, zstd, icu4c, libffi, openssl@3
  - Guard variable `R_CONFIG_SITE_HOMEBREW_DONE` prevents double-loading when config.site is sourced twice
  - Can be disabled with `--disable-site-config` configure flag
  - R now builds out-of-the-box on macOS with Homebrew without manual CPPFLAGS/LDFLAGS
- **Fixed GitHub Actions CI workflows**:
  - `justfile-ci.yaml`: Added step to relink Homebrew packages after cache restore (fixes `just: command not found`)
  - `justfile-ci.yaml`: Added `$(brew --prefix)/bin` to `$GITHUB_PATH` after installing just
  - `build-svn.yaml`: Fixed macOS artifact upload to use `${{ env.ARCH }}` instead of hardcoded architecture
  - Linux builds (ubuntu-22.04, ubuntu-24.04, ubuntu-24.04-arm) now passing
  - Windows and macOS builds in progress
- **Added `--enable-strict-warnings` configure option** for code quality:
  - Enables `-Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wdouble-promotion -Wimplicit-fallthrough`
  - Suppresses `-Wno-unused-parameter -Wno-unused-function` to reduce noise
  - GCC/Clang only, checks each flag for compiler support
  - Useful for code quality audits and modernization

## Next

- Map remaining “system invasion” points (config.site default, prefix defaults, R_HOME install paths) and decide if sandbox mode should flip defaults.
- Broaden pkg-config coverage candidates where still manual (ICU, Tcl/Tk, jpeg2000/webp2); log feasibility with Homebrew pkg-config probes in CONSIDER.md.
- Verify config.h.in coverage for key defines after header generation cleanups; flag anything that would regress runtime.
- Keep libcurl HTTPS test stable across SecureTransport/openssl builds; note current success with pkg-config `-lcurl`.
- Decide how to handle missing `xt.pc` (Homebrew `libxt` or XQuartz path) and `libjbig` (add stub .pc or keep manual flags) so pkg-config path stays clean.
- Optional: trim legacy platform checks that survived the first pass once pkg-config coverage is expanded.
- Decide whether to ship/replace doc/FAQ + resources.html when missing from source tarball; current install skips them quietly.
- Evaluate if readline detection should inject `-lncurses`/`-ltinfo` automatically (now handled by config.site Homebrew detection on macOS).
- Consider moving texi2any/html doc generation behind a toggle or documenting the current warning in sandbox builds.
