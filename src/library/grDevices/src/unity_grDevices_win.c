/* Unity build file for grDevices library (Windows)
 * Combines all source files into single translation unit
 *
 * Windows version uses devWindows.c and winbitmap.c instead of
 * devCairo.c and devQuartz.c (macOS-specific)
 */

/* Core grDevices files */
#include "axis_scales.c"
#include "chull.c"
#include "clippath.c"
#include "colors.c"
#include "devices.c"
#include "group.c"
#include "mask.c"
#include "patterns.c"
#include "stubs.c"

/* Device implementations */
#include "devPicTeX.c"
#include "devPS.c"

/* Windows-specific devices */
#include "devWindows.c"
#include "winbitmap.c"

/* init.c must be last - contains R_init_grDevices */
#include "init.c"
