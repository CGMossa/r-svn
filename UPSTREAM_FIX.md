# Upstream Bug Fixes

This document tracks bugs discovered in R source code that should be reported/fixed upstream.

## graphics.c: Missing break in GConvert CHARS case

**File:** `src/library/graphics/src/graphics.c`
**Function:** `GConvert()`
**Line:** ~838 (around the CHARS case in the switch statement)

**Bug:** The `CHARS` case is missing a `break;` statement, causing it to fall through to the `NIC` case. This means when converting coordinates to CHARS units, the values are first computed correctly, then immediately overwritten with NIC (Normalised Inner Region Coordinates) values.

**Impact:** Any code calling `GConvert()` with `to = CHARS` would receive incorrect NIC coordinates instead of the expected character-based coordinates.

**Before (buggy):**
```c
case CHARS:
    *x = xDevtoChar(devx, dd);
    *y = yDevtoChar(devy, dd);
case NIC:  /* falls through! */
    *x = xDevtoNIC(devx, dd);
    *y = yDevtoNIC(devy, dd);
    break;
```

**After (fixed):**
```c
case CHARS:
    *x = xDevtoChar(devx, dd);
    *y = yDevtoChar(devy, dd);
    break;
case NIC:
    *x = xDevtoNIC(devx, dd);
    *y = yDevtoNIC(devy, dd);
    break;
```

**Fixed in commit:** 853b20f0f5

---

## altclasses.c: Wrong NA_STRING comparison in do_mmap_file

**File:** `src/main/altclasses.c`
**Function:** `do_mmap_file()`
**Line:** ~1375

**Bug:** The code compares `file == NA_STRING` directly, but `file` is a STRSXP (string vector) while `NA_STRING` is a CHARSXP (string element). This comparison will always be false. Should extract the element first with `STRING_ELT(file, 0)`.

**Impact:** The NA check for the file argument never triggers, allowing NA values to pass through unchecked (though the feature is disabled by default).

**Before (buggy):**
```c
if (TYPEOF(file) != STRSXP || LENGTH(file) != 1 || file == NA_STRING)
    error("invalid 'file' argument");
```

**After (fixed):**
```c
if (TYPEOF(file) != STRSXP || LENGTH(file) != 1 || STRING_ELT(file, 0) == NA_STRING)
    error("invalid 'file' argument");
```

**Fixed in commit:** 9f59863f8f

---

## configure.ac: Syntax error in sys_time.h check

**File:** `configure.ac`
**Line:** ~2251

**Bug:** Multiple issues in the shell conditional:
1. Wrong variable name `sys_times_h` instead of `sys_time_h`
2. Malformed quoting with mismatched braces: `${ac_cv_header_sys_times_h} = "no""`

**Impact:** Configure script has broken logic for checking sys/time.h header availability on Unix systems.

**Before (buggy):**
```sh
if test "${ac_cv_header_sys_select_h}" = "no" -a "${ac_cv_header_sys_times_h} = "no""; then
```

**After (fixed):**
```sh
if test "${ac_cv_header_sys_select_h}" = "no" -a "${ac_cv_header_sys_time_h}" = "no"; then
```

**Fixed in commit:** 9bd01576f6

---

## random.c / unique.c: Inconsistent NINTERRUPT constant

**Files:** `src/library/stats/src/random.c`, `src/main/unique.c`
**Line:** NINTERRUPT macro definition

**Bug:** These files define `NINTERRUPT` as 1000000, but other parts of R use 10000000 (10x larger). This causes more frequent interrupt checks in these modules, which may impact performance.

**Impact:** Inconsistent interrupt checking frequency across R modules. The smaller value causes 10x more interrupt checks than intended.

**Before (inconsistent):**
```c
#define NINTERRUPT 1000000
```

**After (consistent):**
```c
#define NINTERRUPT 10000000
```

**Fixed in commit:** ced8983631

---

## Makefile.in: Missing dependency rules for parallel builds

**File:** `src/main/Makefile.in`
**Line:** After the `../extra/intl/libintl.a` rule

**Bug:** The Makefile only had an explicit build rule for `libintl.a`, but not for `libtre.a`, `libtz.a`, or `libxdr.a`. When running `make -j` (parallel build), make would attempt to link the R binary before these static libraries were built, causing race conditions and build failures.

**Impact:** Parallel builds (`make -jN` with N > 1) would randomly fail with missing library errors. Serial builds worked fine because make happened to process directories in the right order.

**Before (buggy):**
```makefile
../extra/intl/libintl.a:
	(cd $(@D); $(MAKE))
# Missing rules for libtre.a, libtz.a, libxdr.a
```

**After (fixed):**
```makefile
../extra/intl/libintl.a:
	(cd $(@D); $(MAKE))

../extra/tre/libtre.a:
	(cd $(@D); $(MAKE))

../extra/tzone/libtz.a:
	(cd $(@D); $(MAKE))

../extra/xdr/libxdr.a:
	(cd $(@D); $(MAKE))
```

**Fixed in commit:** 76dc7e8b1c

---

## builtin.c: Inconsistent simple_as_environment macro

**Files:** `src/main/builtin.c` vs `src/main/eval.c` and `src/main/envir.c`
**Line:** builtin.c:290, eval.c:3866, envir.c:1861

**Bug:** The `simple_as_environment` macro is defined inconsistently across files:

- In `eval.c` and `envir.c`: Returns `R_NilValue` if the argument is not an S4 environment subclass
- In `builtin.c`: Returns `arg` (the original argument) if the argument is not an S4 environment subclass

The comment in all files says "get environment from a subclass if possible; else return NULL", but `builtin.c` returns `arg` instead of `R_NilValue`.

**Impact:** Different behavior when passing non-environment, non-S4 objects to functions that use this macro. In `builtin.c`, the original argument passes through; in `eval.c`/`envir.c`, it becomes `R_NilValue`.

**In eval.c and envir.c (correct per comment):**
```c
/* get environment from a subclass if possible; else return NULL */
#define simple_as_environment(arg) (IS_S4_OBJECT(arg) && (TYPEOF(arg) == OBJSXP) ? R_getS4DataSlot(arg, ENVSXP) : R_NilValue)
```

**In builtin.c (inconsistent with comment):**
```c
/* get environment from a subclass if possible; else return NULL */
#define simple_as_environment(arg) (IS_S4_OBJECT(arg) && (TYPEOF(arg) == OBJSXP) ? R_getS4DataSlot(arg, ENVSXP) : arg)
```

**Status:** Not yet fixed - needs analysis to determine which behavior is intended
