# Considerations (pkg-config and simplifications)

- Extend pkg-config-first to BLAS/LAPACK (e.g., openblas, blas, lapack .pc files) before ACX_BLAS/legacy search.
- Add pkg-config hints for X11 stack (x11, xext, xft, xrender) while retaining legacy probes.
- Keep bitmap fallbacks but prefer pkg-config for webp/jbig/zstd extras in tiff if needed.
- Optionally silence libtool/clang probe logs in config.log if they bother users.
- Evaluate whether internal XDR/TI-RPC probes should use pkg-config for libtirpc.
