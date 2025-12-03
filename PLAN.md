# Plan

- [x] Run `autoreconf -vif` to baseline regeneration; noted gettext macro warnings and removal of `tools/missing` by libtoolize.
- [x] Inventory runtime-facing configure switches and precious vars (see AGENTS.md).
- [x] Wire `configure.ac` to m4 directory cleanly (AC_CONFIG_MACRO_DIRS plus explicit gettext m4 includes); pkg-config required.
- [x] Replace bespoke detection blocks for compression libs with pkg-config (`liblzma`, `libzstd`, `libdeflate`); more simplification pending for other subsystems.
- [x] Prune arcane/obsolete platform conditionals and legacy workarounds (ancient AIX/Darwin guards, __libc_stack_end probes, duplicated --with-internal-tzcode blocks, 2025blas special-cases, Win32 hardcoding) while keeping minimal portability surface.
- [ ] Remove configure-time header templating that is no longer needed; rely on standard headers and pkg-config CFLAGS where possible.
- [x] Re-run autoreconf after cleanups and verify generated `configure`/`config.h.in` stay lean; documented remaining gettext warning.

Next steps
- [x] Optional: tweak cairo stack to drop legacy branches now that pkg-config is required.
- [x] Optional: restore `tools/missing` if we want to match upstream layout.
