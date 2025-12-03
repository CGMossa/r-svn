# Plan

## Done
- `autoreconf -vif` now succeeds (only gettext version warning) after fixing Makefrag AC_CONFIG_COMMANDS duplication and libcurl/libdeflate/pkg-config wiring.
- Added pkg-config-first detection for zlib/bzip2/lzma/zstd/libdeflate/tre/libcurl/readline, cairo/pango, BLAS/LAPACK, X11 stack, TIFF extras (webp/jbig/zstd), and TI-RPC; restored `m4` dir and `tools/missing`.
- Added `--disable-site-config` toggle to keep builds from pulling config.site / ~/.R/config; documented runtime knobs in AGENTS.md.
- Justfile smoke tests: `configure-min` (no X/cairo/recommended) and `configure-full` pass; new `configure-sandbox` exercises `--disable-site-config --no-create`.
- Investigated `--no-create`: configure still writes `config.log` and `config.status` but skips Makefiles; captured in sandbox recipe.
- Reviewed autom4te.cache outputs (no latent errors) and removed backup artefacts.

## Next
- Map remaining “system invasion” points (config.site default, prefix defaults, R_HOME install paths) and decide if sandbox mode should flip defaults.
- Broaden pkg-config coverage candidates where still manual (ICU, Tcl/Tk, jpeg2000/webp2); log feasibility with Homebrew pkg-config probes in CONSIDER.md.
- Verify config.h.in coverage for key defines after header generation cleanups; flag anything that would regress runtime.
- Keep libcurl HTTPS test stable across SecureTransport/openssl builds; note current success with pkg-config `-lcurl`.
- Optional: trim legacy platform checks that survived the first pass once pkg-config coverage is expanded.
