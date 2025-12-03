# Plan

- [x] Run `autoreconf -vif` to baseline regeneration; noted gettext macro warnings and removal of `tools/missing` by libtoolize.
- [x] Inventory runtime-facing configure switches and precious vars (see AGENTS.md).
- [x] Wire `configure.ac` to m4 directory cleanly (AC_CONFIG_MACRO_DIRS plus explicit gettext m4 includes); pkg-config required.
- [ ] Replace bespoke detection blocks (cairo/png/jpeg/tiff, PCRE, tre, curl, zstd, libdeflate, ICU, Tcl/Tk, BLAS/LAPACK) with pkg-config-first logic and drop non-pkg-config fallbacks where safe.
- [x] Prune arcane/obsolete platform conditionals and legacy workarounds (ancient AIX/Darwin guards, __libc_stack_end probes, duplicated --with-internal-tzcode blocks, 2025blas special-cases, Win32 hardcoding) while keeping minimal portability surface.
- [ ] Remove configure-time header templating that is no longer needed; rely on standard headers and pkg-config CFLAGS where possible.
- [ ] Re-run autoreconf after cleanups and verify generated `configure`/`config.h.in` stay lean; document remaining warnings.
