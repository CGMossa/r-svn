# Agents

- Build Modernizer: cleans `configure.ac`, removes obsolete platform guards and header-generation detours.
- Dependency Scout: switches dependency detection to pkg-config first, prunes non-pkg-config fallbacks.
- Runtime Switchboard: tracks configure-time knobs that affect the running R binary; ensures defaults are sane.
- Tooling Shepherd: keeps the Autotools stack minimal (m4 dir, autoreconf hygiene, no redundant helpers).
- Legacy cleanup: removed SVN revision stamping/checks; dist naming falls back to UTC date + r0, doc installs skip missing legacy FAQ/resources.

## Rust build path
- `rustc` is auto-detected (`RUSTC`, `RUSTFLAGS`, `RUSTPICFLAGS`), and a new `Makefrag.rs` supplies `.rs -> .o/.d` rules.
- Package tooling (`R CMD COMPILE`, `R CMD check`, `R CMD INSTALL`) now recognises `*.rs` as valid sources alongside C/C++/Fortran/ObjC.
- Rust sources are built only if `rustc` is present; otherwise builds fail fast with a clear diagnostic when `.rs` files are encountered.

## Runtime switches map (pkg-config is required; compression + tre + iconv/Tcl resolved via pkg-config; Recommended pkgs auto-disable if missing)
### Feature toggles (AC_ARG_ENABLE)
| Flag | Purpose | Default | configure.ac |
| --- | --- | --- | --- |
| --enable-R-profiling | Enable Rprof sampling | yes | configure.ac:228 |
| --enable-memory-profiling | Enable tracemem/Rprofmem | no | configure.ac:240 |
| --enable-R-framework | macOS framework build | no | configure.ac:252 |
| --enable-R-shlib | Build libR shared | no (inherits framework) | configure.ac:294 |
| --enable-R-static-lib | Build libR.a | no | configure.ac:300 |
| --enable-BLAS-shlib | Split BLAS into shared lib | unset | configure.ac:318 |
| --enable-maintainer-mode | Extra maintainer rules | no | configure.ac:332 |
| --enable-strict-barrier | Compile-time write-barrier traps | no | configure.ac:340 |
| --enable-prebuilt-html | Prebuild static HTML help | no | configure.ac:352 |
| --enable-lto | Link-time optimisation | no | configure.ac:358 |
| --enable-java | Java/JNI support | yes | configure.ac:409 |
| --enable-byte-compiled-packages | Byte-compile base + recommended | yes | configure.ac:570 |
| --disable-site-config | Skip sourcing config.site / ~/.R/config | no (enabled) | configure.ac:130 |
| --enable-long-double | Use long double type | yes | configure.ac:1138 |

### Library / subsystem selection (AC_ARG_WITH)
| Flag | Purpose | Default | configure.ac |
| --- | --- | --- | --- |
| --with-C23 | Prefer C23 mode | yes | configure.ac:312 |
| --with-blas | External BLAS | unset | configure.ac:418 |
| --with-lapack | External LAPACK | unset | configure.ac:424 |
| --with-readline | Readline support | yes | configure.ac:435 |
| --with-pcre2 | PCRE2 regex | yes | configure.ac:441 |
| --with-pcre1 | PCRE1 fallback | no | configure.ac:447 |
| --with-aqua | macOS Aqua/quartz | yes | configure.ac:453 |
| --with-tcltk | Tcl/Tk GUI | yes | configure.ac:463 |
| --with-tcl-config | Path to tclConfig.sh | empty | configure.ac:475 |
| --with-tk-config | Path to tkConfig.sh | empty | configure.ac:479 |
| --with-cairo | Cairo/Pango graphics | yes | configure.ac:485 |
| --with-libpng | libpng | yes | configure.ac:494 |
| --with-jpeglib | libjpeg | yes | configure.ac:498 |
| --with-libtiff | libtiff | yes | configure.ac:502 |
| --with-system-tre | tre regex library | no | configure.ac:506 |
| --with-valgrind-instrumentation | Valgrind level 0/1/2 | 0 | configure.ac:512 |
| --with-internal-tzcode | Use bundled tzcode | default (yes on macOS) | configure.ac:498 |
| --with-internal-towlower | Internal towlower/upper | default | configure.ac:526 |
| --with-internal-iswxxxxx | Internal wide-char funcs | default | configure.ac:531 |
| --with-internal-wcwidth | Internal wcwidth | yes | configure.ac:536 |
| --with-recommended-packages | Install recommended pkgs | yes | configure.ac:557 |
| --with-ICU | ICU i18n | yes | configure.ac:564 |
| --with-static-cairo | Allow static cairo | default (yes on macOS) | configure.ac:578 |
| --with-libdeflate-compression | libdeflate for lazyload (via pkg-config) | yes | configure.ac:2646 |
| --with-newAccelerate | macOS Accelerate BLAS/LAPACK | no | configure.ac:3001 |

### Precious environment variables (AC_ARG_VAR)
| Var | Effect on runtime | configure.ac |
| --- | --- | --- |
| R_PRINTCMD | Print command used by `options("printcmd")` | configure.ac:595 |
| R_PAPERSIZE | Default papersize in base utils | configure.ac:597 |
| R_BATCHSAVE | Default save action on quit | configure.ac:599 |
| MAIN_CFLAGS / SHLIB_CFLAGS | Extra C flags for main/shlibs | configure.ac:601 / 603 |
| MAIN_FFLAGS / SHLIB_FFLAGS | Extra Fortran flags | configure.ac:605 / 607 |
| MAIN_LD / MAIN_LDFLAGS | Linker + flags for R binary | configure.ac:609 / 611 |
| CPICFLAGS / FPICFLAGS | PIC flags for C/Fortran | configure.ac:614 / 617 |
| SHLIB_LD / SHLIB_LDFLAGS | Linker + flags for shlibs | configure.ac:620 / 623 |
| DYLIB_LD / DYLIB_LDFLAGS | Linker + flags for dylibs | configure.ac:625 / 628 |
| CXXPICFLAGS | PIC flags for C++ | configure.ac:630 |
| SHLIB_CXXLD / SHLIB_CXXLDFLAGS | C++ shlib linker + flags | configure.ac:633 / 636 |
| TCLTK_LIBS / TCLTK_CPPFLAGS | Tcl/Tk linkage/includes | configure.ac:638 / 640 |
| MAKE / TAR | Tool overrides | configure.ac:642 / 643 |
| R_BROWSER / R_PDFVIEWER | Default browser/pdf viewer | configure.ac:644 / 645 |
| BLAS_LIBS / LAPACK_LIBS | External BLAS/LAPACK link flags | configure.ac:646 / 648 |
| LIBnn | lib vs lib64 install libdir | configure.ac:650 |
| SAFE_FFLAGS | Safe Fortran flags (dlamc) | configure.ac:651 |
| r_arch | Multi-arch subdir name | configure.ac:653 |
| DEFS | C preprocessor defines | configure.ac:655 |
| JAVA_HOME | JDK/JRE root | configure.ac:656 |
| R_SHELL | Shell used in scripts | configure.ac:658 |
