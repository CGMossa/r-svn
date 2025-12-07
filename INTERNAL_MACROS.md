# R Internal Compile-Time Macros

These are preprocessor macros used in R's C source code that are **not** configure options. They're primarily for debugging, testing, or represent dead/experimental code.

To enable any of these, add to `CPPFLAGS` or `DEFS`:

```bash
./configure CPPFLAGS="-DMACRO_NAME"
# or in config.site:
DEFS="-DMACRO_NAME"
```

## Package Development (for packages, not R itself)

| Macro | Description |
|-------|-------------|
| `R_NO_REMAP` | Don't remap R API (use `Rf_allocVector` not `allocVector`) |
| `R_NO_REMAP_RMATH` | Don't remap Rmath function names |
| `STRICT_R_HEADERS` | Stricter header checking, hide deprecated APIs |
| `USE_RINTERNALS` | Access to internal SEXPREC structure (use with caution) |
| `R_USE_C99_IN_CXX` | Use C99 features in C++ code |

## Vector & Memory Layout

| Macro | Files | Description |
|-------|-------|-------------|
| `LONG_VECTOR_SUPPORT` | 66 | Support vectors > 2^31 elements (default on 64-bit) |
| `INLINE_PROTECT` | 6 | Inline PROTECT/UNPROTECT macros |
| `NA_TO_COMPLEX_NA` | 5 | NA handling for complex numbers |

## Reference Counting vs NAMED

| Macro | Files | Description |
|-------|-------|-------------|
| `SWITCH_TO_NAMED` | 2 | Use old NAMED mechanism instead of refcounting |
| `SWITCH_TO_REFCNT` | 10 | Use reference counting (default since R 4.0) |
| `COMPUTE_REFCNT_VALUES` | 3 | Compute reference counts (auto-enabled with REFCNT) |
| `ADJUST_ENVIR_REFCNTS` | 10 | Adjust environment refcounts (auto-enabled with REFCNT) |

Note: `SWITCH_TO_REFCNT` is the default. Define `SWITCH_TO_NAMED` to revert to old behavior.

## Memory & GC Debugging

| Macro | Files | Description |
|-------|-------|-------------|
| `GC_TORTURE` | 1 | Force GC on every allocation (extremely slow) |
| `PROTECTCHECK` | 15 | Validate PROTECT/UNPROTECT stack operations |
| `TESTING_WRITE_BARRIER` | 8 | Test write barrier for generational GC |
| `DEBUG_GC` | 1 | Print GC debugging info |
| `DEBUG_ADJUST_HEAP` | 1 | Debug heap adjustment |
| `DEBUG_RELEASE_MEM` | 1 | Debug memory release |
| `R_MEMORY_PROFILING` | 24 | Enable memory profiling (configure option exists) |
| `SORT_NODES` | 2 | Sort nodes during GC |
| `EXPEL_OLD_TO_NEW` | 1 | GC strategy flag |
| `IMMEDIATE_FINALIZERS` | 2 | Run finalizers immediately |
| `SMALL_MEMORY` | 1 | Optimize for small memory systems |

## Bytecode Compiler

| Macro | Files | Description |
|-------|-------|-------------|
| `BC_PROFILING` | 8 | Profile bytecode execution |
| `THREADED_CODE` | 2 | Use threaded code dispatch |
| `SUPPORT_TAILCALL` | 6 | Enable tail call optimization (defined in eval.c) |
| `DEBUG_JIT` | 1 | Debug JIT compilation |
| `TIMING_ON` | 1 | Enable timing instrumentation |

## Evaluation & Dispatch

| Macro | Files | Description |
|-------|-------|-------------|
| `INLINE_GETVAR` | 1 | Inline variable lookup |
| `USE_BINDING_CACHE` | 1 | Cache binding lookups |
| `USE_GLOBAL_CACHE` | 18 | Use global method cache |
| `FAST_BASE_CACHE_LOOKUP` | 4 | Fast base package cache |
| `CACHE_DLL_SYM` | 5 | Cache DLL symbol lookups |
| `USE_BROWSER_HOOK` | 6 | Enable browser hook |
| `USEMETHOD_FORWARD_LOCALS` | 1 | Forward locals in UseMethod |
| `NO_CALL_FRAME_ARGS_NR` | 1 | Disable call frame args |
| `NO_COMPUTED_MISSINGS` | 1 | Disable computed missing args |
| `IMMEDIATE_PROMISE_VALUES` | 5 | Immediate promise evaluation |
| `REPORT_OVERRIDEN_BUILTINS` | 1 | Warn when builtins overridden |

## ALTREP (Alternative Representations)

| Macro | Files | Description |
|-------|-------|-------------|
| `ALTREP` | many | ALTREP framework (usually enabled) |
| `COMPACT_INTSEQ` | 7 | Compact integer sequences |
| `COMPACT_INTSEQ_MUTABLE` | 7 | Mutable compact int sequences |
| `COMPACT_REALSEQ_MUTABLE` | 2 | Mutable compact real sequences |
| `USE_ALTREP_COMPACT_INTRANGE` | 1 | Use ALTREP for int ranges |
| `SIMPLEMMAP` | 4 | Simple mmap interface (standalone testing) |

## String/Character Handling

| Macro | Files | Description |
|-------|-------|-------------|
| `DEBUG_SHOW_CHARSXP_CACHE` | 1 | Debug CHARSXP cache |
| `DEBUG_GLOBAL_STRING_HASH` | 2 | Debug global string hash |
| `DEBUG_GETTEXT` | 1 | Debug gettext translations |
| `ALLOW_PRECIOUS_HASH` | 1 | Allow precious hash entries |
| `WARN_ABOUT_NAMES_IN_PERSISTENT_STRINGS` | 1 | Warn about names in persistent strings |
| `WARN_DESERIALIZE_INVALID_UTF8` | 1 | Warn on invalid UTF-8 |

## Debugging Output

| Macro | Files | Description |
|-------|-------|-------------|
| `DEBUG` | many | General debug output |
| `DEBUG_DEPARSE` | 6 | Debug deparsing |
| `DEBUG_STACK_DETECTION` | 1 | Debug stack detection |
| `CHECK_INTERNALS` | 1 | Check internal consistency |
| `CHECK_VISIBILITY` | 3 | Check symbol visibility |
| `CHECK_CROSS_USAGE` | 1 | Check cross-usage |
| `CATCH_ZERO_LENGTH_ACCESS` | 1 | Catch zero-length vector access |
| `USE_TYPE_CHECKING` | 1 | Enable type checking |
| `THREADCHECK` | 1 | Thread safety checks |
| `MIKE_DEBUG` | 2 | Developer-specific debug code |
| `R_GE_DEBUG` | 1 | Graphics engine debug |
| `R_ARITHMETIC_ARRAY_1_SPECIAL` | 1 | Debug array arithmetic |
| `WARN_ON_FORWARDING` | 1 | Warn on argument forwarding |

## Dead/Experimental Code

| Macro | Files | Description |
|-------|-------|-------------|
| `OLD` | 1 | Old implementation |
| `OLD_RHS_NAMED` | 3 | Old RHS naming behavior |
| `OLDCODE_LONG_VECTOR` | 1 | Old long vector code |
| `NOTYET` | 1 | Not yet implemented |
| `NEVER` | 1 | Never enabled code |
| `DODO` | 1 | Dead code marker |
| `UNIMP` | 2 | Unimplemented code |
| `_NOT_YET_` | ? | Not yet implemented |
| `NO_LONGER_IN_R_4_` | ? | Removed in R 4.x |

## Profiling & Valgrind

| Macro | Files | Description |
|-------|-------|-------------|
| `R_PROFILING` | 5 | Enable R profiling support (configure option) |
| `VALGRIND_LEVEL` | config | Valgrind instrumentation level (0-2, configure option) |
| `NVALGRIND` | config | Disable Valgrind entirely |

## Signals & Unix

| Macro | Files | Description |
|-------|-------|-------------|
| `R_USE_SIGNALS` | many | Use signal handling (defined in Parse.h) |
| `UNIX_EXTRAS` | 5 | Enable Unix-specific extras |

## Platform-Specific

| Macro | Files | Description |
|-------|-------|-------------|
| `USE_INTERNAL_MKTIME` | many | Use internal mktime |
| `R_MACOS_LIBICONV_WORKAROUND` | ? | macOS iconv workaround |
| `R_MACOS_LIBICONV_HANDLE_BOM` | ? | Handle BOM on macOS |
| `R_MACOS_LIBICONV_RESET_AFTER_ERROR` | ? | Reset iconv on error |
| `USE_ICU` | many | Use ICU library |
| `USE_ICU_APPLE` | ? | Use Apple's ICU |
| `USE_NEW_ACCELERATE` | ? | Use new Accelerate framework |
| `USE_RI18N_*` | several | R i18n functions |
| `WC_NOT_UNICODE` | ? | Wide char not Unicode |
| `OS_MUSL` | ? | musl libc support |

## Math Library

| Macro | Files | Description |
|-------|-------|-------------|
| `MATHLIB_STANDALONE` | many | Build math library standalone |
| `MATHLIB_FAST_` | ? | Fast math operations |
| `USE_POWL_IN_R_POW` | ? | Use powl for R's pow |
| `_NO_LOG_DBINOM_` | ? | Disable log dbinom |
| `WHEN_MATH5_IS_THERE` | ? | Future math functions |
| `NO_DENORMS` | ? | Disable denormal handling |
| `RMIN_ONLY` | ? | Minimal R math |

## Rarely Used / Single Letter

| Macro | Files | Description |
|-------|-------|-------------|
| `H` | ? | Unknown |
| `U` | ? | Unknown |
| `W` | ? | Unknown |
| `_` | ? | Unknown (likely gettext) |
| `S_` | ? | S compatibility |
| `R_` | ? | R marker |
| `S3_` | ? | S3 dispatch |
| `_S4_` | ? | S4 dispatch |
| `_R_` | ? | R marker |

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
```

## Notes

- These are **not** documented configure options
- Many are for R-core internal use only
- Some may break the build or cause crashes
- The "Files" count indicates how many `#ifdef` occurrences exist
- Some macros enable code that requires other changes to work
