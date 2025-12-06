/* Unity build file for graphics library
 * Combines all source files into single translation unit
 *
 * Static symbol conflicts resolved via preprocessor renames:
 * - plot3d.c: TypeCheck -> plot3d_TypeCheck (conflicts with plot.c)
 * - plot3d.c: Edge -> plot3d_Edge (conflicts with graphics.c struct)
 *
 * Note: par-common.c is #included by par.c, not compiled standalone
 */

/* All files include Defn.h - order doesn't matter for USE_RINTERNALS */
#include "base.c"

/* graphics.c has Edge struct type - include before plot3d.c rename */
#include "graphics.c"

#include "par.c"
#include "plot.c"
#include "stem.c"

/* plot3d.c has TypeCheck and Edge conflicts */
#define TypeCheck plot3d_TypeCheck
#define Edge plot3d_Edge
#include "plot3d.c"
#undef TypeCheck
#undef Edge

/* init.c must be last - contains R_init_graphics */
#include "init.c"
