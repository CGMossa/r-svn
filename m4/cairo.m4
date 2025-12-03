### cairo.m4 -- extra macros for configuring R for cairo    -*- Autoconf -*-
### Simplified to require pkg-config pangocairo.

AC_DEFUN([R_PANGO_CAIRO], [
  AC_REQUIRE([PKG_PROG_PKG_CONFIG])
  save_CPPFLAGS=${CPPFLAGS}
  save_LIBS=${LIBS}

  PKG_CHECK_MODULES([PANGOCAIRO],[pangocairo >= 1.2],
    [r_cv_has_pangocairo=yes],
    [AC_MSG_ERROR([pangocairo >= 1.2 is required for cairo support])])

  modlist="pangocairo"
  for module in cairo-png cairo-pdf cairo-ps cairo-svg cairo-xlib; do
    if "${PKG_CONFIG}" --exists ${module}; then
      modlist="${modlist} ${module}"
      case ${module} in
        cairo-pdf) r_cairo_pdf=yes ;;
        cairo-ps)  r_cairo_ps=yes ;;
        cairo-svg) r_cairo_svg=yes ;;
        cairo-xlib) r_cairo_xlib=yes ;;
      esac
    fi
  done

  CAIRO_CPPFLAGS=`"${PKG_CONFIG}" --cflags ${modlist}`
  CAIRO_LIBS=`"${PKG_CONFIG}" --libs ${modlist}`
  CAIROX11_CPPFLAGS="${CAIRO_CPPFLAGS}"
  CAIROX11_LIBS="${CAIRO_LIBS}"

  CPPFLAGS="${CPPFLAGS} ${CAIRO_CPPFLAGS}"
  LIBS="${LIBS} ${CAIRO_LIBS}"

  AC_CACHE_CHECK([whether cairo including pango works], 
                 [r_cv_cairo_works],
  [AC_LINK_IFELSE([AC_LANG_SOURCE([[
#include <pango/pango.h>
#include <pango/pangocairo.h>
#include <stddef.h>
int main(void) {
    cairo_surface_t *cs = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 1, 1);
    cairo_t  *CC = cairo_create(cs);
    PangoLayout *pl = pango_cairo_create_layout(CC);
    pango_layout_set_text(pl, "test", -1);
    pango_font_description_free(pango_font_description_from_string("sans 12"));
    g_object_unref(pl);
    cairo_destroy(CC);
    cairo_surface_destroy(cs);
    return 0;
 }
	]])],[r_cv_cairo_works=yes],[r_cv_cairo_works=no])])
  CPPFLAGS=${save_CPPFLAGS}
  LIBS=${save_LIBS}

  AC_DEFINE(HAVE_PANGOCAIRO, 1, [Define to 1 if you have pangocairo.]) 
  if test "x${r_cv_cairo_works}" = xyes; then
     AC_DEFINE(HAVE_WORKING_CAIRO, 1, [Define to 1 if you have cairo.])
     if test "x${r_cairo_xlib}" = xyes; then
        AC_DEFINE(HAVE_WORKING_X11_CAIRO, 1,
                 [Define to 1 if you have cairo including Xlib.])
     fi
  fi
  if test "x${r_cairo_pdf}" = xyes; then
     AC_DEFINE(HAVE_CAIRO_PDF, 1, [Define to 1 if you have cairo-ps.]) 
  fi
  if test "x${r_cairo_ps}" = xyes; then
     AC_DEFINE(HAVE_CAIRO_PS, 1, [Define to 1 if you have cairo-pdf.]) 
  fi
  if test "x${r_cairo_svg}" = xyes; then
     AC_DEFINE(HAVE_CAIRO_SVG, 1, [Define to 1 if you have cairo-svg.]) 
  fi
  AC_SUBST(CAIRO_CPPFLAGS)
  AC_SUBST(CAIROX11_CPPFLAGS)
  AC_SUBST(CAIRO_LIBS)
  AC_SUBST(CAIROX11_LIBS)
])
