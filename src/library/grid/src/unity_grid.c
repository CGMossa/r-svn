/* Unity build file for grid library
 * Combines all source files into single translation unit
 *
 * grid.c must be first - it defines GRID_MAIN which controls
 * whether R_gridEvalEnv is defined vs extern in grid.h.
 * Due to header guards, the first includer of grid.h wins.
 */

#include "grid.c"
#include "clippath.c"
#include "gpar.c"
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
