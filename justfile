# Build/test recipes for R configure modernisation

set positional-arguments := true

# Run configure with minimal optional deps (no X, cairo, recommended pkgs)
configure-min:
	srcdir="{{justfile_directory()}}" \
	&& tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX) \
	&& cd "$tmpdir" \
	&& CPPFLAGS=${CPPFLAGS:-"-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include"} \
	   LDFLAGS=${LDFLAGS:-"-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib"} \
	   PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-"/opt/homebrew/opt/readline/lib/pkgconfig"} \
	   HTML_DOCS=${HTML_DOCS:-yes} \
	   html_flag="" \
	   if [ "$HTML_DOCS" = "no" ]; then html_flag="--disable-html-docs"; fi; \
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
	&& CPPFLAGS=${CPPFLAGS:-"-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include"} \
	   LDFLAGS=${LDFLAGS:-"-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib"} \
	   PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-"/opt/homebrew/opt/readline/lib/pkgconfig"} \
	   HTML_DOCS=${HTML_DOCS:-yes} \
	   html_flag="" \
	   if [ "$HTML_DOCS" = "no" ]; then html_flag="--disable-html-docs"; fi; \
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

    CPPFLAGS=${CPPFLAGS:-"-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include"} \
    LDFLAGS=${LDFLAGS:-"-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib"} \
    PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-"/opt/homebrew/opt/readline/lib/pkgconfig"} \
    HTML_DOCS=${HTML_DOCS:-yes} \
    html_flag=""; if [ "$HTML_DOCS" = "no" ]; then html_flag="--disable-html-docs"; fi; \
    builddir="$tmpdir/build" ../src/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --with-aqua=no \
        ${html_flag} \
        --no-create

    ls -a .

build-r-min:
    #!/usr/bin/env bash
    set -euo pipefail

    srcdir="{{justfile_directory()}}"
    tmpdir="$(mktemp -d /tmp/r-conf-build-XXXXXX)"
    echo "Using build directory: $tmpdir"

    cd "$tmpdir"

    CPPFLAGS=${CPPFLAGS:-"-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include"} \
    LDFLAGS=${LDFLAGS:-"-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib"} \
    PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-"/opt/homebrew/opt/readline/lib/pkgconfig"} \
    html_flag=$([ "${HTML_DOCS:-no}" = "no" ] && echo "--disable-html-docs" || true) \
    "$srcdir"/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --with-aqua=no \
        --disable-R-framework \
        --without-x \
        --without-cairo \
        --without-recommended-packages \
        ${html_flag}

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

    CPPFLAGS=${CPPFLAGS:-"-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include"} \
    LDFLAGS=${LDFLAGS:-"-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib"} \
    PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-"/opt/homebrew/opt/readline/lib/pkgconfig"} \
    html_flag=$([ "${HTML_DOCS:-no}" = "no" ] && echo "--disable-html-docs" || true) \
    builddir="$tmpdir/build" ../src/configure \
        --prefix="$tmpdir/install" \
        --disable-site-config \
        --with-aqua=no \
        --disable-R-framework \
        --enable-fast-config \
        --without-x \
        --without-cairo \
        --without-tcltk \
        --without-recommended-packages \
        ${html_flag}

    make -j"$(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)"
    make install

    echo "Launching R from $tmpdir/install/bin/R"
    exec "$tmpdir/install/bin/R" --vanilla

# Fast configure: skips X11/cairo/tcltk/java/NLS/recommended checks via --enable-fast-config.
configure-fast:
	srcdir="{{justfile_directory()}}" \
	&& tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX) \
	&& cd "$tmpdir" \
	&& CPPFLAGS=${CPPFLAGS:-"-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include"} \
	   LDFLAGS=${LDFLAGS:-"-L/opt/homebrew/lib -L/opt/homebrew/opt/xz/lib -L/opt/homebrew/opt/readline/lib"} \
	   PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-"/opt/homebrew/opt/readline/lib/pkgconfig"} \
	   html_flag=$([ \"${HTML_DOCS:-no}\" = \"no\" ] && echo \"--disable-html-docs\" || true) \
	   builddir="$tmpdir" "$srcdir"/configure \
	      --prefix=$tmpdir/install \
		  --disable-site-config \
	      --with-aqua=no \
		  --enable-fast-config \
		  --without-x \
		  --without-cairo \
		  --without-tcltk \
		  --without-recommended-packages \
		  ${html_flag} \
	&& ls -a "$tmpdir"
