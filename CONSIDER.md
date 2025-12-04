# Considerations (pkg-config and simplifications)

- Extend pkg-config-first to BLAS/LAPACK (e.g., openblas, blas, lapack .pc files) before ACX_BLAS/legacy search.
- Add pkg-config hints for jpeg2000/webp2 or other optional bitmap codecs if we keep those features.
- Optionally silence libtool/clang probe logs in config.log if they bother users.
- ICU could use `icu-uc`/`icu-i18n` pkg-config instead of custom link tests; also consider `icucore` shim on macOS.
- Tcl/Tk can be resolved via pkg-config on Homebrew (`tcl`, `tk`), falling back to tclConfig.sh/tkConfig.sh only when needed.
- Capture Homebrew pkg-config availability snapshots for the above to guide which fallbacks remain necessary.
- If pkg-config readline remains elusive, harden the fallback to pull `-lncurses`/`-ltinfo` (or prefer a Homebrew PKG_CONFIG_PATH hint) to avoid linking against libedit.
- Decide whether missing docs (FAQ/resources.html) should be generated or dropped from install to keep out-of-tree builds clean.
- HTML/manual generation currently warns when `texi2any` is absent; consider gating those targets behind a switch or documenting the sandbox expectation.
