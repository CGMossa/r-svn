/* Unity build batch 1 - auto-generated */
/* 79 files - conflict-aware grouping */
/* Regenerate with: tools/make-unity-smart.sh */

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

/* Enable all features needed by source files */
#define R_USE_SIGNALS 1
#define NEED_CONNECTION_PSTREAMS 1
#ifndef Win32
#define Unix 1
#endif
#define R_INTERFACE_PTRS 1
#include <Defn.h>
#include <Internal.h>
#include <Rinterface.h>

/* Forward declarations for internal functions used across files */
/* Note: pmatch is #defined to Rf_pmatch in Rinternals.h */
Rboolean Rf_pmatch(SEXP, SEXP, Rboolean);

#include "CommandLineArgs.c"
#include "Rdynload.c"
#include "Renviron.c"
#include "Rmain.c"
#include "alloca.c"
#include "altrep.c"
#include "apply.c"
#include "arithmetic.c"
#include "array.c"
#include "attrib.c"
#include "bind.c"
#include "builtin.c"
#include "clippath.c"
#include "coerce.c"
#include "colors.c"
#include "complex.c"
#include "connections.c"
#include "context.c"
#include "cum.c"
#include "datetime.c"
#include "debug.c"
#include "devices.c"
#include "dotcode.c"
#include "dstruct.c"
#include "duplicate.c"
#include "edit.c"
#include "engine.c"
#include "flexiblas.c"
#include "g_alab_her.c"
#include "g_cntrlify.c"
#include "g_fontdb.c"
#include "g_her_glyph.c"
#include "gevents.c"
#include "graphics.c"
#include "grep.c"
#include "identical.c"
#include "inlined.c"
#include "inspect.c"
#include "internet.c"
#include "iosupport.c"
#include "list.c"
#include "localecharset.c"
#include "logic.c"
#include "machine.c"
#include "mask.c"
#include "match.c"
#include "memory.c"
#include "mkdtemp.c"
#include "names.c"
#include "objects.c"
#include "options.c"
#include "patterns.c"
#include "platform.c"
#include "plot.c"
#include "plot3d.c"
#include "plotmath.c"
#include "print.c"
#include "printarray.c"
#include "printvector.c"
#include "qsort.c"
#include "radixsort.c"
#include "random.c"
#include "raw.c"
#include "registration.c"
#include "relop.c"
#include "rlocale.c"
#include "sort.c"
#include "split.c"
#include "sprintf.c"
#include "startup.c"
#include "strdup.c"
#include "strncasecmp.c"
#include "subassign.c"
#include "subscript.c"
#include "subset.c"
#include "summary.c"
#include "sysutils.c"
#include "times.c"
#include "version.c"
