/* Unity build file for parallel library
 * Combines all source files into single translation unit
 *
 * IMPORTANT: Files that include Defn.h must come FIRST to ensure
 * USE_RINTERNALS is defined before any file includes Rinternals.h.
 */

/* fork.c includes Defn.h - must come first */
#include "fork.c"

/* Other source files */
#include "rngstream.c"

/* init.c must be last - contains R_init_parallel */
#include "init.c"
