# Build/test recipes for R configure modernisation

set positional-arguments := true

# Run configure with minimal optional deps (no X, cairo, recommended pkgs)
configure-min:
	srcdir="{{justfile_directory()}}" \
	&& tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX) \
	&& cd "$tmpdir" \
	&& CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include" \
	   builddir="$tmpdir" "$srcdir"/configure \
	      --prefix=$tmpdir/install \
	      --with-aqua=no \
	      --disable-R-framework \
	      --without-x \
	      --without-cairo \
	      --without-recommended-packages

# Run configure with defaults (recommended packages required)
configure-full:
	srcdir="{{justfile_directory()}}" \
	&& tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX) \
	&& cd "$tmpdir" \
	&& CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include" \
	   builddir="$tmpdir" "$srcdir"/configure \
	      --with-aqua=no \
	      --prefix=$tmpdir/install

# Smoke-test --disable-site-config and --no-create handling.
configure-sandbox:
	srcdir="{{justfile_directory()}}" \
	&& tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX) \
	&& cd "$tmpdir" \
	&& CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/opt/xz/include -I/opt/homebrew/opt/readline/include" \
	   builddir="$tmpdir" "$srcdir"/configure \
	      --prefix=$tmpdir/install \
	      --disable-site-config \
	      --with-aqua=no \
	      --no-create \
	&& ls -a "$tmpdir"
