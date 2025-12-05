/* Unity build batch 5 - auto-generated */
/* 5 files - conflict-aware grouping */
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

#include "deparse.c"
#include "errors.c"
#include "paste.c"
#include "scan.c"
#include "sort.c"
