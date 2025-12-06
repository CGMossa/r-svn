/* Unity build file for tcltk library
 * Combines all source files into single translation unit
 *
 * IMPORTANT: Files that include Defn.h must come FIRST to ensure
 * USE_RINTERNALS is defined before any file includes Rinternals.h.
 */

/* Files that include Defn.h - must come first */
#include "tcltk.c"
#include "tcltk_unix.c"

/* init.c must be last - contains R_init_tcltk */
#include "init.c"
