# Considerations (pkg-config and simplifications)

- Extend pkg-config-first to BLAS/LAPACK (e.g., openblas, blas, lapack .pc files) before ACX_BLAS/legacy search.
- Add pkg-config hints for jpeg2000/webp2 or other optional bitmap codecs if we keep those features.
- Optionally silence libtool/clang probe logs in config.log if they bother users.
- ICU could use `icu-uc`/`icu-i18n` pkg-config instead of custom link tests; also consider `icucore` shim on macOS.
- Tcl/Tk can be resolved via pkg-config on Homebrew (`tcl`, `tk`), falling back to tclConfig.sh/tkConfig.sh only when needed.
- Capture Homebrew pkg-config availability snapshots for the above to guide which fallbacks remain necessary.
