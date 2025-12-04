# Build/test recipes for R configure modernisation

set positional-arguments := true

# Platform-specific defaults (set via environment or detected)
# On macOS with Homebrew, set HOMEBREW_PREFIX; on Linux, leave empty for system paths

# Helper: set up platform-specific library paths
# Usage: eval "$(setup_paths)"
[private]
setup-paths := '''
if [ "$(uname)" = "Darwin" ]; then
    BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null || echo /opt/homebrew)}"
    : ${CPPFLAGS:="-I${BREW_PREFIX}/include -I${BREW_PREFIX}/opt/xz/include -I${BREW_PREFIX}/opt/readline/include -I${BREW_PREFIX}/opt/bzip2/include"}
    : ${LDFLAGS:="-L${BREW_PREFIX}/lib -L${BREW_PREFIX}/opt/xz/lib -L${BREW_PREFIX}/opt/readline/lib -L${BREW_PREFIX}/opt/bzip2/lib"}
    : ${PKG_CONFIG_PATH:="${BREW_PREFIX}/opt/readline/lib/pkgconfig:${BREW_PREFIX}/lib/pkgconfig"}
    export CPPFLAGS LDFLAGS PKG_CONFIG_PATH
fi
'''

# Run configure with minimal optional deps (no X, cairo, recommended pkgs)
configure-min:
    #!/usr/bin/env bash
    set -euo pipefail

    srcdir="{{justfile_directory()}}"
    tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX)
    echo "Using temp dir: $tmpdir"
    cd "$tmpdir"

    # Platform-specific library paths
    {{setup-paths}}

    html_flag=""
    if [ "${HTML_DOCS:-yes}" = "no" ]; then
        html_flag="--disable-html-docs"
    fi

    "$srcdir"/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --enable-fast-config \
        --with-aqua=no \
        --disable-R-framework \
        --without-x \
        --without-cairo \
        --without-recommended-packages \
        $html_flag

    ls -a "$tmpdir"

# Run configure with defaults (recommended packages required)
configure-full:
    #!/usr/bin/env bash
    set -euo pipefail

    srcdir="{{justfile_directory()}}"
    tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX)
    echo "Using temp dir: $tmpdir"
    cd "$tmpdir"

    # Platform-specific library paths
    {{setup-paths}}

    html_flag=""
    if [ "${HTML_DOCS:-yes}" = "no" ]; then
        html_flag="--disable-html-docs"
    fi

    "$srcdir"/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --enable-fast-config \
        --with-aqua=no \
        $html_flag

# Smoke-test --disable-site-config and --no-create handling.
configure-sandbox:
    #!/usr/bin/env bash
    set -euo pipefail

    srcroot="{{justfile_directory()}}"
    tmpdir="$(mktemp -d /tmp/r-conf-build-XXXXXX)"
    echo "Using sandbox: $tmpdir"

    # Exclude generated headers that would interfere with out-of-tree builds
    rsync -a --delete \
        --exclude='.git' \
        --exclude='autom4te.cache' \
        --exclude='src/include/Rversion.h' \
        --exclude='src/include/Rconfig.h' \
        --exclude='src/include/Rmath.h' \
        --exclude='src/include/config.h' \
        "$srcroot"/ "$tmpdir/src/"
    mkdir -p "$tmpdir/build"
    cd "$tmpdir/build"

    # Platform-specific library paths
    {{setup-paths}}

    html_flag=""
    if [ "${HTML_DOCS:-yes}" = "no" ]; then
        html_flag="--disable-html-docs"
    fi

    ../src/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --enable-fast-config \
        --with-aqua=no \
        $html_flag \
        --no-create

    ls -a .

build-r-min:
    #!/usr/bin/env bash
    set -euo pipefail

    srcroot="{{justfile_directory()}}"
    tmpdir="$(mktemp -d /tmp/r-conf-build-XXXXXX)"
    echo "Using build directory: $tmpdir"

    # Copy source tree to temp (required for out-of-tree builds)
    # Exclude generated headers that would interfere with out-of-tree builds
    rsync -a --delete \
        --exclude='.git' \
        --exclude='autom4te.cache' \
        --exclude='src/include/Rversion.h' \
        --exclude='src/include/Rconfig.h' \
        --exclude='src/include/Rmath.h' \
        --exclude='src/include/config.h' \
        "$srcroot"/ "$tmpdir/src/"
    if [ ! -f "$tmpdir/src/share/make/vars.mk" ]; then
        mkdir -p "$tmpdir/src/share/make"
        if [ -f "$srcroot/share/make/vars.mk" ]; then
            cp "$srcroot/share/make/vars.mk" "$tmpdir/src/share/make/vars.mk"
        else
            echo "R_PKGS_RECOMMENDED =" > "$tmpdir/src/share/make/vars.mk"
        fi
    fi
    mkdir -p "$tmpdir/build"
    cd "$tmpdir/build"

    # Platform-specific library paths
    {{setup-paths}}

    html_flag=""
    if [ "${HTML_DOCS:-no}" = "no" ]; then
        html_flag="--disable-html-docs"
    fi

    ../src/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --enable-fast-config \
        --with-aqua=no \
        --disable-R-framework \
        --without-x \
        --without-cairo \
        --without-recommended-packages \
        $html_flag

    # Build R binary only (no docs to avoid PDF/texi2any requirements)
    make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)" R
    # Ensure include headers are generated before install
    make -C src/include R
    make install

    echo
    echo "R installed under: $tmpdir/install"
    echo "R binary:          $tmpdir/install/bin/R"

# Build in an isolated temp dir and drop into the REPL.
sandbox-repl:
    #!/usr/bin/env bash
    set -euo pipefail

    srcroot="{{justfile_directory()}}"
    tmpdir="$(mktemp -d /tmp/r-conf-build-XXXXXX)"
    echo "Using sandbox: $tmpdir"

    # Exclude generated headers that would interfere with out-of-tree builds
    rsync -a --delete \
        --exclude='.git' \
        --exclude='autom4te.cache' \
        --exclude='src/include/Rversion.h' \
        --exclude='src/include/Rconfig.h' \
        --exclude='src/include/Rmath.h' \
        --exclude='src/include/config.h' \
        "$srcroot"/ "$tmpdir/src/"
    if [ ! -f "$tmpdir/src/share/make/vars.mk" ]; then
      mkdir -p "$tmpdir/src/share/make"
      if [ -f "$srcroot/share/make/vars.mk" ]; then
        cp "$srcroot/share/make/vars.mk" "$tmpdir/src/share/make/vars.mk"
      else
        echo "R_PKGS_RECOMMENDED =" > "$tmpdir/src/share/make/vars.mk"
      fi
    fi
    mkdir -p "$tmpdir/build"
    cd "$tmpdir/build"

    # Platform-specific library paths
    {{setup-paths}}

    html_flag=""
    if [ "${HTML_DOCS:-no}" = "no" ]; then
        html_flag="--disable-html-docs"
    fi

    ../src/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --with-aqua=no \
        --disable-R-framework \
        --enable-fast-config \
        --without-x \
        --without-cairo \
        --without-tcltk \
        --without-recommended-packages \
        $html_flag

    # Build R binary only (no docs to avoid PDF/texi2any requirements)
    make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)" R
    # Ensure include headers are generated before install
    make -C src/include R
    make install

    echo "Launching R from $tmpdir/install/bin/R"
    exec "$tmpdir/install/bin/R" --vanilla

# Fast configure: skips X11/cairo/tcltk/java/NLS/recommended checks via --enable-fast-config.
configure-fast:
    #!/usr/bin/env bash
    set -euo pipefail

    srcdir="{{justfile_directory()}}"
    tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX)
    echo "Using temp dir: $tmpdir"
    cd "$tmpdir"

    # Platform-specific library paths
    {{setup-paths}}

    html_flag=""
    if [ "${HTML_DOCS:-no}" = "no" ]; then
        html_flag="--disable-html-docs"
    fi

    "$srcdir"/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --with-aqua=no \
        --enable-fast-config \
        --without-x \
        --without-cairo \
        --without-tcltk \
        --without-recommended-packages \
        $html_flag

    ls -a "$tmpdir"

# Quick rebuild - reuse existing build directory
rebuild *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ]; then
        echo "No existing build dir found. Run configure-min first."
        exit 1
    fi
    echo "Rebuilding in: $BUILD"
    cd "$BUILD"
    make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)" R {{ARGS}}

# Clean rebuild of a specific component (e.g., main, nmath, extra/blas)
rebuild-component component:
    #!/usr/bin/env bash
    set -euo pipefail
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ]; then
        echo "No existing build dir found. Run configure-min first."
        exit 1
    fi
    echo "Rebuilding component: {{component}} in $BUILD"
    cd "$BUILD/src/{{component}}"
    make clean && make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)"

# Run R tests from latest build
test-r *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ]; then
        echo "No existing build dir found. Run build-r-min first."
        exit 1
    fi
    echo "Running tests in: $BUILD"
    cd "$BUILD"
    make check-devel {{ARGS}}

# Run just the Rust tests
test-rust:
    #!/usr/bin/env bash
    set -euo pipefail
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ]; then
        echo "No existing build dir found. Run configure-min first."
        exit 1
    fi
    echo "Testing Rust compilation in: $BUILD"
    # Handle both in-tree (configure-min) and out-of-tree (build-r-min) builds
    if [ -d "$BUILD/src/extra/rust_test" ]; then
        cd "$BUILD/src/extra/rust_test"
    elif [ -d "$BUILD/build/src/extra/rust_test" ]; then
        cd "$BUILD/build/src/extra/rust_test"
    else
        echo "Error: rust_test directory not found in build"
        echo "Checked: $BUILD/src/extra/rust_test"
        echo "Checked: $BUILD/build/src/extra/rust_test"
        exit 1
    fi
    make clean 2>/dev/null || true
    make
    echo
    echo "Rust objects:"
    ls -la *.o *.d 2>/dev/null || echo "None found"

# Show configure summary from last build
show-config:
    #!/usr/bin/env bash
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -n "$BUILD" ]; then
        echo "Build dir: $BUILD"
        echo
        echo "=== Configure Summary ==="
        grep -A 100 "R is now configured" "$BUILD/config.log" 2>/dev/null | head -30 || \
            tail -50 "$BUILD/config.log" | head -30
    else
        echo "No build found"
    fi

# Regenerate autotools files
regen-autotools:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "{{justfile_directory()}}"
    autoconf
    echo "configure regenerated from configure.ac"

# Show all configure options
configure-help:
    #!/usr/bin/env bash
    "{{justfile_directory()}}"/configure --help

# Build with AddressSanitizer for debugging memory issues (macOS only)
configure-asan:
    #!/usr/bin/env bash
    set -euo pipefail

    srcdir="{{justfile_directory()}}"
    tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX)
    echo "Using temp dir: $tmpdir (ASAN build)"
    cd "$tmpdir"

    # Platform-specific library paths
    {{setup-paths}}

    export CC="clang"
    export CFLAGS="-g -O0 -fno-omit-frame-pointer -fsanitize=address"
    export LDFLAGS="-fsanitize=address ${LDFLAGS:-}"

    "$srcdir"/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --enable-fast-config \
        --with-aqua=no \
        --disable-R-framework \
        --without-x \
        --without-cairo \
        --without-recommended-packages \
        --disable-html-docs

    echo
    echo "ASAN build configured in: $tmpdir"
    echo "Run 'just rebuild' to build with AddressSanitizer"

# Build with debug symbols and no optimization
configure-debug:
    #!/usr/bin/env bash
    set -euo pipefail

    srcdir="{{justfile_directory()}}"
    tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX)
    echo "Using temp dir: $tmpdir (debug build)"
    cd "$tmpdir"

    # Platform-specific library paths
    {{setup-paths}}

    export CFLAGS="-g -O0 -UNDEBUG"
    export CXXFLAGS="-g -O0 -UNDEBUG"
    export FFLAGS="-g -O0"

    "$srcdir"/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --enable-fast-config \
        --with-aqua=no \
        --disable-R-framework \
        --without-x \
        --without-cairo \
        --without-recommended-packages \
        --disable-html-docs \
        --enable-strict-barrier

    echo
    echo "Debug build configured in: $tmpdir"

# List all build directories
list-builds:
    @ls -ltdh /tmp/r-conf-build-* 2>/dev/null | head -10 || echo "No builds found"

# Clean old build directories (keep latest 3)
clean-builds:
    #!/usr/bin/env bash
    builds=$(ls -td /tmp/r-conf-build-* 2>/dev/null || true)
    count=0
    for b in $builds; do
        count=$((count + 1))
        if [ $count -gt 3 ]; then
            echo "Removing: $b"
            rm -rf "$b"
        fi
    done
    if [ $count -le 3 ]; then
        echo "Only $count build(s) found, nothing to clean"
    fi

# Clean ALL build directories
clean-all-builds:
    #!/usr/bin/env bash
    builds=$(ls -td /tmp/r-conf-build-* 2>/dev/null || true)
    if [ -z "$builds" ]; then
        echo "No builds to clean"
        exit 0
    fi
    for b in $builds; do
        echo "Removing: $b"
        rm -rf "$b"
    done

# Export compile_commands.json for IDE integration (requires bear)
compile-commands:
    #!/usr/bin/env bash
    set -euo pipefail
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ]; then
        echo "No existing build dir found. Run configure-min first."
        exit 1
    fi
    if ! command -v bear &>/dev/null; then
        echo "Error: 'bear' not found. Install with: brew install bear (macOS) or apt install bear (Linux)"
        exit 1
    fi
    cd "$BUILD"
    bear -- make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)" R
    echo "compile_commands.json generated in: $BUILD"

# Quick R expression test
run-expr expr:
    #!/usr/bin/env bash
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ] || [ ! -x "$BUILD/install/bin/R" ]; then
        echo "No installed R found. Run build-r-min first."
        exit 1
    fi
    "$BUILD/install/bin/R" --vanilla -e "{{expr}}"

# Run R with specific arguments
run-r *ARGS:
    #!/usr/bin/env bash
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ] || [ ! -x "$BUILD/install/bin/R" ]; then
        echo "No installed R found. Run build-r-min first."
        exit 1
    fi
    exec "$BUILD/install/bin/R" {{ARGS}}

# Show R version info from latest build
r-version:
    #!/usr/bin/env bash
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ] || [ ! -x "$BUILD/install/bin/R" ]; then
        echo "No installed R found. Run build-r-min first."
        exit 1
    fi
    "$BUILD/install/bin/R" --version

# Compare Makeconf files (top-level vs etc for packages)
compare-makeconf:
    #!/usr/bin/env bash
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ]; then
        echo "No existing build dir found. Run configure-min first."
        exit 1
    fi
    echo "Comparing $BUILD/Makeconf vs $BUILD/etc/Makeconf"
    diff -u "$BUILD/Makeconf" "$BUILD/etc/Makeconf" || true

# Show what Rust would link against
rust-link-info:
    #!/usr/bin/env bash
    if ! command -v rustc &>/dev/null; then
        echo "rustc not found"
        exit 0
    fi
    echo "Native static libs for a minimal Rust crate:"
    rustc --crate-type=cdylib -C panic=abort --print native-static-libs - <<< 'pub fn dummy() {}' 2>&1 | grep native-static-libs || echo "(no extra libs needed)"

# Test R CMD COMPILE and R CMD SHLIB with Rust sources
test-rust-shlib:
    #!/usr/bin/env bash
    set -euo pipefail
    BUILD=$(ls -td /tmp/r-conf-build-* 2>/dev/null | head -1)
    if [ -z "$BUILD" ] || [ ! -x "$BUILD/install/bin/R" ]; then
        echo "No installed R found. Run build-r-min first."
        exit 1
    fi

    R_HOME="$BUILD/install/lib/R"
    R_CMD="$BUILD/install/bin/R"
    srcdir="{{justfile_directory()}}"

    # Get platform-specific shared library extension from R
    SHLIB_EXT=$("$R_CMD" CMD config SHLIB_EXT)
    echo "Platform shared library extension: $SHLIB_EXT"

    # Create temp directory for test
    testdir=$(mktemp -d /tmp/rust-shlib-test-XXXXXX)
    echo "Testing R CMD COMPILE/SHLIB with Rust in: $testdir"
    cd "$testdir"

    # Copy test Rust source
    cp "$srcdir/src/extra/rust_test/hello.rs" .

    echo
    echo "=== Testing R CMD COMPILE ==="
    "$R_CMD" CMD COMPILE hello.rs
    echo "Compiled objects:"
    ls -la *.o 2>/dev/null || echo "No .o files found"

    echo
    echo "=== Testing R CMD SHLIB ==="
    # Clean and rebuild with SHLIB (use platform extension)
    rm -f *.o *"$SHLIB_EXT" 2>/dev/null || true
    "$R_CMD" CMD SHLIB hello.rs
    echo "Shared library:"
    ls -la "hello$SHLIB_EXT" 2>/dev/null || echo "No shared library found"

    echo
    echo "=== Checking exported symbols ==="
    shlib="hello$SHLIB_EXT"
    if [ ! -f "$shlib" ]; then
        echo "FAILED: No shared library produced ($shlib)"
        exit 1
    fi

    echo "Symbols in $shlib:"
    # Use nm with appropriate flags for the platform
    if [ "$(uname)" = "Darwin" ]; then
        nm -gU "$shlib" | grep -E "rust_hello|rust_add" || { echo "Expected symbols not found!"; exit 1; }
    else
        nm -g --defined-only "$shlib" | grep -E "rust_hello|rust_add" || { echo "Expected symbols not found!"; exit 1; }
    fi
    echo
    echo "SUCCESS: Rust SHLIB test passed!"

    # Cleanup
    rm -rf "$testdir"

# Run all Rust-related tests
test-all-rust: test-rust test-rust-shlib
    @echo
    @echo "=== All Rust tests passed! ==="
