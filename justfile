# Build/test recipes for R configure modernisation

set positional-arguments := true

# Run configure with minimal optional deps (no X, cairo, recommended pkgs)
configure-min:
	srcdir="{{justfile_directory()}}" \
	&& tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX) \
	&& cd "$tmpdir" \
	&& CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include" \
	   LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib" \
	   builddir="$tmpdir" "$srcdir"/configure \
	      --prefix=$tmpdir/install \
		  --disable-site-config \
	      --with-aqua=no \
	      --disable-R-framework \
	      --without-x \
	      --without-cairo \
	      --without-recommended-packages \
	&& ls -a "$tmpdir"

# Run configure with defaults (recommended packages required)
configure-full:
	srcdir="{{justfile_directory()}}" \
	&& tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX) \
	&& cd "$tmpdir" \
	&& CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include" \
	   LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib" \
	   builddir="$tmpdir" "$srcdir"/configure \
	      --with-aqua=no \
		  --disable-site-config \
	      --prefix=$tmpdir/install

# Smoke-test --disable-site-config and --no-create handling.
configure-sandbox:
    #!/usr/bin/env bash
    set -euo pipefail

    srcroot="{{justfile_directory()}}"
    tmpdir="$(mktemp -d /tmp/r-conf-build-XXXXXX)"
    echo "Using sandbox: $tmpdir"

    rsync -a --delete --exclude='.git' --exclude='autom4te.cache' "$srcroot"/ "$tmpdir/src/"
    mkdir -p "$tmpdir/build"
    cd "$tmpdir/build"

    CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include" \
    LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib" \
    builddir="$tmpdir/build" ../src/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --with-aqua=no \
        --no-create

    ls -a .

build-r-min:
    #!/usr/bin/env bash
    set -euo pipefail

    srcdir="{{justfile_directory()}}"
    tmpdir="$(mktemp -d /tmp/r-conf-build-XXXXXX)"
    echo "Using build directory: $tmpdir"

    cd "$tmpdir"

    CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include" \
    LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib" \
    "$srcdir"/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --with-aqua=no \
        --disable-R-framework \
        --without-x \
        --without-cairo \
        --without-recommended-packages

    make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)"
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

    rsync -a --delete --exclude='.git' --exclude='autom4te.cache' "$srcroot"/ "$tmpdir/src/"
    mkdir -p "$tmpdir/build"
    cd "$tmpdir/build"

    CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include" \
    LDFLAGS="-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib" \
    builddir="$tmpdir/build" ../src/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --with-aqua=no \
        --disable-R-framework

    make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)"
    make install

    echo "Launching R from $tmpdir/install/bin/R"
    exec "$tmpdir/install/bin/R" --vanilla
