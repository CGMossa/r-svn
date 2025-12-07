# ===========================================================================
#  m4/rust.m4 - Rust compiler detection and edition support for R
# ===========================================================================
#
# SYNOPSIS
#
#   AX_RUST_COMPILE_EDITION(EDITION, [ext|noext], [mandatory|optional])
#   R_PROG_RUST
#   R_PROG_RUST_FLAG(FLAG, [ACTION-IF-TRUE])
#   R_PROG_RUST_MAKEFRAG
#   R_RUST_NATIVE_STATIC_LIBS
#
# DESCRIPTION
#
#   Macros for detecting Rust compiler support and edition features.
#   Modeled after cxx.m4 for C++ compiler detection.
#
#   Rust editions: 2015, 2018, 2021, 2024
#
# LICENSE
#
#   Copyright (c) 2024 R Core Team
#   Copying and distribution permitted under the same terms as R.

# rust.m4 serial 1

## AX_RUST_COMPILE_EDITION(EDITION, [mandatory|optional])
## --------------------------------------------------------
## Check for Rust edition support in the compiler.
## EDITION may be '2015', '2018', '2021', or '2024'.
##
## The second argument, if specified 'mandatory' or if left unspecified,
## indicates that support for the specified Rust edition is required.
## If specified 'optional', then configuration proceeds regardless.
##
AC_DEFUN([AX_RUST_COMPILE_EDITION], [dnl
  m4_if([$1], [2015], [],
        [$1], [2018], [],
        [$1], [2021], [],
        [$1], [2024], [],
        [m4_fatal([invalid first argument `$1' to AX_RUST_COMPILE_EDITION])])dnl
  m4_if([$2], [], [ax_rust_compile_edition_$1_required=true],
        [$2], [mandatory], [ax_rust_compile_edition_$1_required=true],
        [$2], [optional], [ax_rust_compile_edition_$1_required=false],
        [m4_fatal([invalid second argument `$2' to AX_RUST_COMPILE_EDITION])])
  ac_success=no

  if test "x${RUSTC}" != "x:" && test -n "${RUSTC}"; then
    AC_MSG_CHECKING([whether ${RUSTC} supports Rust $1 edition])

    dnl Create a test file for the edition
    cat > conftest.rs << '_ACEOF'
_AX_RUST_COMPILE_EDITION_testbody_$1
_ACEOF

    dnl Try compiling with the edition flag
    if ${RUSTC} --edition=$1 --emit=metadata -o conftest.rmeta conftest.rs 2>/dev/null; then
      AC_MSG_RESULT([yes])
      ac_success=yes
      RUST$1=yes
      RUST$1STD="--edition=$1"
    else
      AC_MSG_RESULT([no])
      RUST$1=no
      RUST$1STD=""
    fi
    rm -f conftest.rs conftest.rmeta
  fi

  if test x$ax_rust_compile_edition_$1_required = xtrue; then
    if test x$ac_success = xno; then
      AC_MSG_ERROR([*** A Rust compiler with support for edition $1 is required.])
    fi
  fi

  if test x$ac_success = xno; then
    HAVE_RUST$1=0
    AC_MSG_NOTICE([No Rust compiler with edition $1 support was found])
  else
    HAVE_RUST$1=1
  fi
  AC_SUBST(HAVE_RUST$1)
  AC_SUBST(RUST$1)
  AC_SUBST(RUST$1STD)
])


## Test bodies for each Rust edition
## These test edition-specific features

dnl Test body for Rust 2015 (baseline)
m4_define([_AX_RUST_COMPILE_EDITION_testbody_2015], [[
// Rust 2015 edition test
fn main() {
    let x: i32 = 42;
    println!("{}", x);
}
]])

dnl Test body for Rust 2018 (module system changes, async/await preview)
m4_define([_AX_RUST_COMPILE_EDITION_testbody_2018], [[
// Rust 2018 edition test - uses 2018-specific module system
// In 2018, 'dyn Trait' is required instead of bare 'Trait'
fn takes_trait_object(_: &dyn std::fmt::Debug) {}

fn main() {
    let x = 42;
    takes_trait_object(&x);
}
]])

dnl Test body for Rust 2021 (disjoint captures, IntoIterator for arrays)
m4_define([_AX_RUST_COMPILE_EDITION_testbody_2021], [[
// Rust 2021 edition test - uses 2021-specific features
fn main() {
    // IntoIterator for arrays is stable in 2021
    let arr = [1, 2, 3];
    for x in arr {
        let _ = x;
    }

    // Disjoint capture in closures (2021 feature)
    let s = (String::from("hello"), String::from("world"));
    let c = || {
        let _ = &s.0;  // Only captures s.0, not all of s
    };
    c();
    let _ = s.1;  // s.1 is still accessible
}
]])

dnl Test body for Rust 2024 (unsafe_op_in_unsafe_fn, etc.)
m4_define([_AX_RUST_COMPILE_EDITION_testbody_2024], [[
// Rust 2024 edition test
// 2024 makes unsafe_op_in_unsafe_fn a hard error
#![deny(unsafe_op_in_unsafe_fn)]

unsafe fn unsafe_inner() {}

unsafe fn unsafe_outer() {
    // In 2024, must explicitly use unsafe block
    unsafe { unsafe_inner(); }
}

fn main() {
    unsafe { unsafe_outer(); }
}
]])


## R_PROG_RUST
## -----------
## Detect Rust compiler and set up variables
## Uses AC_DEFUN_ONCE to prevent duplicate expansion from AC_REQUIRE chains
AC_DEFUN_ONCE([R_PROG_RUST],
[
AC_ARG_VAR([RUSTC], [Rust compiler command])
AC_ARG_VAR([RUSTFLAGS], [Rust compiler flags])

AC_ARG_ENABLE([rust],
  AS_HELP_STRING([--disable-rust], [disable Rust compiler support]),
  [want_rust=$enableval], [want_rust=yes])

if test "x${want_rust}" = "xyes"; then
  AC_PATH_PROG([RUSTC], [rustc])
  if test -z "${RUSTC}"; then
    AC_MSG_WARN([rustc not found: Rust sources will not be built])
    RUSTC=:
    HAVE_RUST=0
  else
    HAVE_RUST=1

    # Check and report rustc version
    AC_MSG_CHECKING([rustc version])
    RUST_VERSION=`${RUSTC} --version 2>/dev/null | cut -d' ' -f2`
    if test -n "${RUST_VERSION}"; then
      AC_MSG_RESULT([${RUST_VERSION}])
      AC_SUBST(RUST_VERSION)
    else
      AC_MSG_RESULT([unknown])
      RUST_VERSION=unknown
    fi

    # Extract major.minor for comparison
    RUST_VERSION_MAJOR=`echo ${RUST_VERSION} | cut -d. -f1`
    RUST_VERSION_MINOR=`echo ${RUST_VERSION} | cut -d. -f2`
    AC_SUBST(RUST_VERSION_MAJOR)
    AC_SUBST(RUST_VERSION_MINOR)

    # Check for each edition (optional) - skip if fast-config enabled
    if test "x${enable_fast_config}" = "xyes"; then
      AC_MSG_NOTICE([fast-config: assuming Rust 2021 edition support])
      RUST2015=yes
      RUST2015STD="--edition=2015"
      HAVE_RUST2015=1
      RUST2018=yes
      RUST2018STD="--edition=2018"
      HAVE_RUST2018=1
      RUST2021=yes
      RUST2021STD="--edition=2021"
      HAVE_RUST2021=1
      RUST2024=no
      RUST2024STD=""
      HAVE_RUST2024=0
      RUST_DEFAULT_EDITION=2021
    else
      AX_RUST_COMPILE_EDITION([2015], [optional])
      AX_RUST_COMPILE_EDITION([2018], [optional])
      AX_RUST_COMPILE_EDITION([2021], [optional])
      AX_RUST_COMPILE_EDITION([2024], [optional])

      # Set default edition based on what's available
      if test "x${RUST2021}" = "xyes"; then
        RUST_DEFAULT_EDITION=2021
      elif test "x${RUST2018}" = "xyes"; then
        RUST_DEFAULT_EDITION=2018
      else
        RUST_DEFAULT_EDITION=2015
      fi
    fi
    AC_SUBST(RUST_DEFAULT_EDITION)

    # Check for cargo (optional but useful)
    AC_PATH_PROG([CARGO], [cargo])
    if test -z "${CARGO}"; then
      CARGO=:
      HAVE_CARGO=0
    else
      HAVE_CARGO=1
    fi
    AC_SUBST(CARGO)
    AC_SUBST(HAVE_CARGO)

    # Get target triple
    AC_MSG_CHECKING([rustc target triple])
    RUST_TARGET=`${RUSTC} --version --verbose 2>/dev/null | grep "^host:" | cut -d' ' -f2`
    if test -n "${RUST_TARGET}"; then
      AC_MSG_RESULT([${RUST_TARGET}])
    else
      AC_MSG_RESULT([unknown])
      RUST_TARGET=unknown
    fi
    AC_SUBST(RUST_TARGET)
  fi
else
  AC_MSG_NOTICE([Rust support disabled by user])
  RUSTC=:
  HAVE_RUST=0
fi

# Set up flags
if test -z "${RUSTFLAGS}"; then
  RUSTFLAGS=""
fi
if test -z "${RUSTPICFLAGS}"; then
  RUSTPICFLAGS="-C relocation-model=pic"
fi

# Optimization flags
if test -z "${RUSTOPTFLAGS}"; then
  RUSTOPTFLAGS="-C opt-level=2"
fi

# Debug flags
if test -z "${RUSTDEBUGFLAGS}"; then
  RUSTDEBUGFLAGS="-g -C opt-level=0"
fi

AC_SUBST(RUSTC)
AC_SUBST(RUSTFLAGS)
AC_SUBST(RUSTPICFLAGS)
AC_SUBST(RUSTOPTFLAGS)
AC_SUBST(RUSTDEBUGFLAGS)
AC_SUBST(HAVE_RUST)
AM_CONDITIONAL(BUILD_RUST, [test "x${RUSTC}" != "x:"])
AM_CONDITIONAL(BUILD_RUST_TEST, [test "x${RUSTC}" != "x:"])
])# R_PROG_RUST


## R_PROG_RUST_FLAG(FLAG, [ACTION-IF-TRUE])
## -----------------------------------------
## Check whether the Rust compiler accepts FLAG
AC_DEFUN([R_PROG_RUST_FLAG],
[ac_safe=AS_TR_SH($1)
AC_MSG_CHECKING([whether ${RUSTC} accepts $1])
AC_CACHE_VAL([r_cv_prog_rust_flag_${ac_safe}],
[
if test "x${RUSTC}" != "x:" && test -n "${RUSTC}"; then
  cat > conftest.rs << 'EOF'
fn main() {}
EOF
  if ${RUSTC} $1 --emit=metadata -o conftest.rmeta conftest.rs 2>/dev/null; then
    eval "r_cv_prog_rust_flag_${ac_safe}=yes"
  else
    eval "r_cv_prog_rust_flag_${ac_safe}=no"
  fi
  rm -f conftest.rs conftest.rmeta
else
  eval "r_cv_prog_rust_flag_${ac_safe}=no"
fi
])
if eval "test \"`echo '$r_cv_prog_rust_flag_'$ac_safe`\" = yes"; then
  AC_MSG_RESULT([yes])
  [$2]
else
  AC_MSG_RESULT([no])
fi
])# R_PROG_RUST_FLAG


## R_RUST_NATIVE_STATIC_LIBS
## -------------------------
## Detect the native static libraries needed when linking Rust code
AC_DEFUN_ONCE([R_RUST_NATIVE_STATIC_LIBS],
[
if test "x${enable_fast_config}" = "xyes"; then
  AC_MSG_NOTICE([fast-config: assuming standard Rust native static libs])
  RUST_NATIVE_STATIC_LIBS=""
else
  AC_MSG_CHECKING([for Rust native static libs])
  if test "x${RUSTC}" != "x:" && test -n "${RUSTC}"; then
    cat > conftest.rs << 'EOF'
#[no_mangle]
pub extern "C" fn rust_dummy() -> i32 { 0 }
EOF
    RUST_NATIVE_STATIC_LIBS=`${RUSTC} --crate-type=staticlib --print native-static-libs conftest.rs 2>&1 | grep "native-static-libs:" | sed 's/.*native-static-libs: //'`
    rm -f conftest.rs libconftest.a
    if test -n "${RUST_NATIVE_STATIC_LIBS}"; then
      AC_MSG_RESULT([${RUST_NATIVE_STATIC_LIBS}])
    else
      AC_MSG_RESULT([none detected])
      RUST_NATIVE_STATIC_LIBS=""
    fi
  else
    AC_MSG_RESULT([rustc not available])
    RUST_NATIVE_STATIC_LIBS=""
  fi
fi
AC_SUBST(RUST_NATIVE_STATIC_LIBS)
])# R_RUST_NATIVE_STATIC_LIBS


## R_PROG_RUST_MAKEFRAG
## --------------------
## Generate a Make fragment with suffix rules for the Rust compiler.
AC_DEFUN_ONCE([R_PROG_RUST_MAKEFRAG],
[r_rust_rules_frag=Makefrag.rs
AC_SUBST([r_rust_rules_frag], [Makefrag.rs])
AC_SUBST_FILE(r_rust_rules_frag)
m4_ifndef([_R_RUST_RULES_FRAG_SEEN],
[m4_define([_R_RUST_RULES_FRAG_SEEN], 1)
AC_CONFIG_COMMANDS([r_rust_rules_frag],[
cat << 'EOF' > Makefrag.rs
# Rust compilation rules
# Crate types: staticlib (for linking into C), cdylib (for dynamic loading)
# Note: ALL_RUSTFLAGS already includes RUST_EDITION_FLAG

.rs.o:
	@if test "x$(RUSTC)" = "x:"; then \
	  $(ECHO) "rustc is not available but a Rust source was encountered: $<" 1>&2; \
	  exit 1; \
	fi
	$(RUSTC) --crate-type=staticlib -C panic=abort $(ALL_RUSTFLAGS) --emit=dep-info,obj -o $[@] $<

.rs.d:
	@if test "x$(RUSTC)" = "x:"; then \
	  $(ECHO) "rustc is not available but a Rust source was encountered: $<" 1>&2; \
	  exit 1; \
	fi
	@$(ECHO) "making $[@] from $<"
	@$(RUSTC) --crate-type=staticlib -C panic=abort $(ALL_RUSTFLAGS) --emit=dep-info -o $[@] $<

# Rule for building Rust libraries (.rlib)
.rs.rlib:
	@if test "x$(RUSTC)" = "x:"; then \
	  $(ECHO) "rustc is not available but a Rust source was encountered: $<" 1>&2; \
	  exit 1; \
	fi
	$(RUSTC) --crate-type=rlib $(ALL_RUSTFLAGS) -o $[@] $<
EOF
])])
])# R_PROG_RUST_MAKEFRAG


## R_PROG_RUST_SHLIB_MAKEFRAG
## --------------------------
## Generate Make fragment for Rust shared libraries (cdylib)
AC_DEFUN([R_PROG_RUST_SHLIB_MAKEFRAG],
[r_rust_shlib_rules_frag=Makefrag.rs_shlib
AC_SUBST([r_rust_shlib_rules_frag], [Makefrag.rs_shlib])
AC_SUBST_FILE(r_rust_shlib_rules_frag)
m4_ifndef([_R_RUST_SHLIB_RULES_FRAG_SEEN],
[m4_define([_R_RUST_SHLIB_RULES_FRAG_SEEN], 1)
AC_CONFIG_COMMANDS([r_rust_shlib_rules_frag],[
cat << 'EOF' > Makefrag.rs_shlib
# Rust shared library (cdylib) compilation rules
# Use this for building R packages with Rust code
# Note: ALL_RUSTFLAGS already includes RUST_EDITION_FLAG

.rs$(SHLIB_EXT):
	@if test "x$(RUSTC)" = "x:"; then \
	  $(ECHO) "rustc is not available but a Rust source was encountered: $<" 1>&2; \
	  exit 1; \
	fi
	$(RUSTC) --crate-type=cdylib -C panic=abort $(ALL_RUSTFLAGS) --print native-static-libs -o $[@] $<
EOF
])])
])# R_PROG_RUST_SHLIB_MAKEFRAG
