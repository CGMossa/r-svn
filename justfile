# Build/test recipes for R configure modernisation

set positional-arguments := true

# Run configure with minimal optional deps (no X, cairo, recommended pkgs)
configure-min:
	tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX) \
	&& cd "$tmpdir" \
	&& /Users/elea/Documents/GitHub/r_svn_reconfigure/configure \
	      --prefix=$tmpdir/install \
	      --disable-R-framework \
	      --without-x \
	      --without-cairo \
	      --without-recommended-packages

# Run configure with defaults (recommended packages required)
configure-full:
	tmpdir=$(mktemp -d /tmp/r-conf-build-XXXXXX) \
	&& cd "$tmpdir" \
	&& /Users/elea/Documents/GitHub/r_svn_reconfigure/configure \
	      --prefix=$tmpdir/install

