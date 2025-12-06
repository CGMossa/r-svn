/* Unity build file for grid library
 * Combines all source files into single translation unit
 *
 * No Defn.h includes - no USE_RINTERNALS ordering needed
 * No static function conflicts between files
 */

#include "clippath.c"
#include "gpar.c"
#include "grid.c"
#include "just.c"
#include "layout.c"
#include "mask.c"
#include "matrix.c"
#include "path.c"
#include "state.c"
#include "typeset.c"
#include "unit.c"
#include "util.c"
#include "viewport.c"

/* register.c must be last - contains R_init_grid */
#include "register.c"
