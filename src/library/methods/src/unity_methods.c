/* Unity build file for methods library
 * Combines all source files into single translation unit
 *
 * IMPORTANT: Files that include Defn.h must come FIRST to ensure
 * USE_RINTERNALS is defined before any file includes Rinternals.h.
 * Otherwise, ALTCOMPLEX_ELT etc. are declared as external instead of inline.
 */

/* Files that include Defn.h (defines USE_RINTERNALS) - must come first */
#include "do_substitute_direct.c"
#include "methods_list_dispatch.c"
#include "utils.c"

#undef STRING_VALUE  /* Avoid redefinition warning from Rdefines.h */

/* Files that only include R.h/Rinternals.h */
#include "class_support.c"
#include "slot.c"
#include "tests.c"

/* init.c must be last - contains R_init_methods */
#include "init.c"
