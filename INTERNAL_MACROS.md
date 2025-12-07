# R Internal Compile-Time Macros

These are preprocessor macros used in R's C source code that are **not** configure options. They're primarily for debugging, testing, or represent dead/experimental code.

To enable any of these, add to `CPPFLAGS` or `DEFS`:

```bash
./configure CPPFLAGS="-DMACRO_NAME"
# or in config.site:
DEFS="-DMACRO_NAME"
```

## Package Development (for packages, not R itself)

| Macro | Default | Description |
|-------|---------|-------------|
| `R_NO_REMAP` | OFF | Don't remap R API (use `Rf_allocVector` not `allocVector`) |
| `R_NO_REMAP_RMATH` | OFF | Don't remap Rmath function names |
| `STRICT_R_HEADERS` | OFF | Stricter header checking, hide deprecated APIs |
| `USE_RINTERNALS` | OFF | Access to internal SEXPREC structure (use with caution) |
| `R_USE_C99_IN_CXX` | OFF | Use C99 features in C++ code |

## Vector & Memory Layout

| Macro | Default | Description |
|-------|---------|-------------|
| `LONG_VECTOR_SUPPORT` | **ON** | Support vectors > 2^31 elements (on 64-bit) |
| `INLINE_PROTECT` | **ON** | Inline PROTECT/UNPROTECT macros |
| `NA_TO_COMPLEX_NA` | OFF | NA handling for complex numbers |

## Reference Counting vs NAMED

| Macro | Default | Description |
|-------|---------|-------------|
| `SWITCH_TO_NAMED` | OFF | Use old NAMED mechanism instead of refcounting |
| `SWITCH_TO_REFCNT` | **ON** | Use reference counting (default since R 4.0) |
| `COMPUTE_REFCNT_VALUES` | **ON** | Compute reference counts (auto-enabled with REFCNT) |
| `ADJUST_ENVIR_REFCNTS` | **ON** | Adjust environment refcounts (auto-enabled with REFCNT) |

Note: `SWITCH_TO_REFCNT` is the default. Define `SWITCH_TO_NAMED` to revert to old behavior.

## Memory & GC Debugging

| Macro | Default | Description |
|-------|---------|-------------|
| `GC_TORTURE` | OFF | Force GC on every allocation (extremely slow) |
| `PROTECTCHECK` | OFF | Validate PROTECT/UNPROTECT stack operations |
| `TESTING_WRITE_BARRIER` | OFF | Test write barrier for generational GC |
| `DEBUG_GC` | OFF | Print GC debugging info |
| `DEBUG_ADJUST_HEAP` | OFF | Debug heap adjustment |
| `DEBUG_RELEASE_MEM` | OFF | Debug memory release |
| `R_MEMORY_PROFILING` | OFF | Enable memory profiling (configure: `--enable-memory-profiling`) |
| `SORT_NODES` | OFF | Sort nodes during GC |
| `EXPEL_OLD_TO_NEW` | OFF | GC strategy flag |
| `IMMEDIATE_FINALIZERS` | OFF | Run finalizers immediately |
| `SMALL_MEMORY` | OFF | Optimize for small memory systems |

## Bytecode Compiler

| Macro | Default | Description |
|-------|---------|-------------|
| `BC_PROFILING` | OFF | Profile bytecode execution |
| `THREADED_CODE` | OFF | Use threaded code dispatch |
| `SUPPORT_TAILCALL` | **ON** | Enable tail call optimization (defined in eval.c) |
| `DEBUG_JIT` | OFF | Debug JIT compilation |
| `TIMING_ON` | OFF | Enable timing instrumentation |

## Evaluation & Dispatch

| Macro | Default | Description |
|-------|---------|-------------|
| `INLINE_GETVAR` | OFF | Inline variable lookup |
| `USE_BINDING_CACHE` | OFF | Cache binding lookups |
| `USE_GLOBAL_CACHE` | **ON** | Use global method cache |
| `FAST_BASE_CACHE_LOOKUP` | OFF | Fast base package cache |
| `CACHE_DLL_SYM` | **ON** | Cache DLL symbol lookups |
| `USE_BROWSER_HOOK` | OFF | Enable browser hook |
| `USEMETHOD_FORWARD_LOCALS` | OFF | Forward locals in UseMethod |
| `NO_CALL_FRAME_ARGS_NR` | OFF | Disable call frame args |
| `NO_COMPUTED_MISSINGS` | OFF | Disable computed missing args |
| `IMMEDIATE_PROMISE_VALUES` | **ON** | Immediate promise evaluation |
| `REPORT_OVERRIDEN_BUILTINS` | OFF | Warn when builtins overridden |

## ALTREP (Alternative Representations)

| Macro | Default | Description |
|-------|---------|-------------|
| `ALTREP` | **ON** | ALTREP framework (macro to access alt flag) |
| `COMPACT_INTSEQ` | **ON** | Compact integer sequences |
| `COMPACT_INTSEQ_MUTABLE` | OFF | Mutable compact int sequences |
| `COMPACT_REALSEQ_MUTABLE` | OFF | Mutable compact real sequences |
| `USE_ALTREP_COMPACT_INTRANGE` | OFF | Use ALTREP for int ranges |
| `SIMPLEMMAP` | OFF | Simple mmap interface (standalone testing) |

## String/Character Handling

| Macro | Default | Description |
|-------|---------|-------------|
| `DEBUG_SHOW_CHARSXP_CACHE` | OFF | Debug CHARSXP cache |
| `DEBUG_GLOBAL_STRING_HASH` | OFF | Debug global string hash |
| `DEBUG_GETTEXT` | OFF | Debug gettext translations |
| `ALLOW_PRECIOUS_HASH` | OFF | Allow precious hash entries |
| `WARN_ABOUT_NAMES_IN_PERSISTENT_STRINGS` | OFF | Warn about names in persistent strings |
| `WARN_DESERIALIZE_INVALID_UTF8` | OFF | Warn on invalid UTF-8 |

## Debugging Output

| Macro | Default | Description |
|-------|---------|-------------|
| `DEBUG` | OFF | General debug output |
| `DEBUG_DEPARSE` | OFF | Debug deparsing |
| `DEBUG_STACK_DETECTION` | OFF | Debug stack detection |
| `CHECK_INTERNALS` | OFF | Check internal consistency |
| `CHECK_VISIBILITY` | OFF | Check symbol visibility |
| `CHECK_CROSS_USAGE` | OFF | Check cross-usage |
| `CATCH_ZERO_LENGTH_ACCESS` | OFF | Catch zero-length vector access |
| `USE_TYPE_CHECKING` | OFF | Enable type checking |
| `THREADCHECK` | OFF | Thread safety checks |
| `MIKE_DEBUG` | OFF | Developer-specific debug code |
| `R_GE_DEBUG` | OFF | Graphics engine debug |
| `R_ARITHMETIC_ARRAY_1_SPECIAL` | OFF | Debug array arithmetic |
| `WARN_ON_FORWARDING` | OFF | Warn on argument forwarding |

## Dead/Experimental Code

| Macro | Default | Description |
|-------|---------|-------------|
| `OLD` | OFF | Old implementation |
| `OLD_RHS_NAMED` | OFF | Old RHS naming behavior |
| `OLDCODE_LONG_VECTOR` | OFF | Old long vector code |
| `NOTYET` | OFF | Not yet implemented |
| `NEVER` | OFF | Never enabled code |
| `DODO` | OFF | Dead code marker |
| `UNIMP` | OFF | Unimplemented code |
| `_NOT_YET_` | OFF | Not yet implemented |
| `NO_LONGER_IN_R_4_` | OFF | Removed in R 4.x |

## Profiling & Valgrind

| Macro | Default | Description |
|-------|---------|-------------|
| `R_PROFILING` | **ON** | Enable R profiling support (configure option) |
| `VALGRIND_LEVEL` | 0 | Valgrind instrumentation level (0-2, configure option) |
| `NVALGRIND` | **ON** | Disable Valgrind (default unless `--with-valgrind-instrumentation`) |

## Signals & Unix

| Macro | Default | Description |
|-------|---------|-------------|
| `R_USE_SIGNALS` | **ON** | Use signal handling (defined in Parse.h) |
| `UNIX_EXTRAS` | OFF | Enable Unix-specific extras |

## Platform-Specific

| Macro | Default | Description |
|-------|---------|-------------|
| `USE_INTERNAL_MKTIME` | varies | Use internal mktime (platform-dependent) |
| `R_MACOS_LIBICONV_WORKAROUND` | OFF | macOS iconv workaround |
| `R_MACOS_LIBICONV_HANDLE_BOM` | OFF | Handle BOM on macOS |
| `R_MACOS_LIBICONV_RESET_AFTER_ERROR` | OFF | Reset iconv on error |
| `USE_ICU` | varies | Use ICU library (configure detects) |
| `USE_ICU_APPLE` | OFF | Use Apple's ICU |
| `USE_NEW_ACCELERATE` | OFF | Use new Accelerate framework |
| `USE_RI18N_*` | OFF | R i18n functions |
| `WC_NOT_UNICODE` | OFF | Wide char not Unicode |
| `OS_MUSL` | OFF | musl libc support |

## Math Library

| Macro | Default | Description |
|-------|---------|-------------|
| `MATHLIB_STANDALONE` | OFF | Build math library standalone |
| `MATHLIB_FAST_` | OFF | Fast math operations |
| `USE_POWL_IN_R_POW` | OFF | Use powl for R's pow |
| `_NO_LOG_DBINOM_` | OFF | Disable log dbinom |
| `WHEN_MATH5_IS_THERE` | OFF | Future math functions |
| `NO_DENORMS` | OFF | Disable denormal handling |
| `RMIN_ONLY` | OFF | Minimal R math |

## Rarely Used / Single Letter

| Macro | Default | Description |
|-------|---------|-------------|
| `H` | OFF | Unknown |
| `U` | OFF | Unknown |
| `W` | OFF | Unknown |
| `_` | OFF | Unknown (likely gettext) |
| `S_` | OFF | S compatibility |
| `R_` | OFF | R marker |
| `S3_` | OFF | S3 dispatch |
| `_S4_` | OFF | S4 dispatch |
| `_R_` | OFF | R marker |

## How to Use

Most of these are for R core development debugging. Common useful ones:

```bash
# Memory debugging
./configure CPPFLAGS="-DPROTECTCHECK"

# GC torture (very slow!)
./configure CPPFLAGS="-DGC_TORTURE"

# Write barrier testing
./configure CPPFLAGS="-DTESTING_WRITE_BARRIER"

# Bytecode profiling
./configure CPPFLAGS="-DBC_PROFILING"

# Revert to old NAMED mechanism
./configure CPPFLAGS="-DSWITCH_TO_NAMED"
```

## Notes

- **ON** = enabled by default in standard R builds
- OFF = disabled, must explicitly define to enable
- These are **not** documented configure options (except where noted)
- Many are for R-core internal use only
- Some may break the build or cause crashes
- Some macros enable code that requires other changes to work
