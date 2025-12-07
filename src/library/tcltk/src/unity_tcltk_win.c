/* Unity build file for tcltk library (Windows)
 * Combines all source files into single translation unit
 *
 * Windows version uses tcltk_win.c instead of tcltk_unix.c
 */

#include "tcltk.c"
#include "tcltk_win.c"

/* init.c must be last - contains R_init_tcltk */
#include "init.c"
