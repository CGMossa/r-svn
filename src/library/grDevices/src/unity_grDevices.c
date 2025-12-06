/* Unity build file for grDevices library
 * Combines all source files into single translation unit
 *
 * IMPORTANT: Files that include Defn.h must come FIRST to ensure
 * USE_RINTERNALS is defined before any file includes Rinternals.h.
 *
 * Static function conflicts resolved via preprocessor renames:
 * - colors.c: CheckAlpha -> colors_CheckAlpha (conflicts with devPS.c)
 * - devPicTeX.c: SetFont -> PicTeX_SetFont (conflicts with devPS.c)
 *
 * Note: devQuartz.c excluded due to macOS framework header conflicts
 * (Comment struct in devPS.c conflicts with CarbonCore AIFF.h)
 */

/* Files that include Defn.h - must come first */
#include "devices.c"
#include "stubs.c"

/* colors.c has CheckAlpha that conflicts with devPS.c */
#define CheckAlpha colors_CheckAlpha
#include "colors.c"
#undef CheckAlpha

#include "clippath.c"
#include "patterns.c"
#include "mask.c"
#include "group.c"
#include "devCairo.c"

/* devPicTeX.c has SetFont that conflicts with devPS.c */
#define SetFont PicTeX_SetFont
#include "devPicTeX.c"
#undef SetFont

/* devPS.c has the "canonical" CheckAlpha and SetFont */
#include "devPS.c"

/* devQuartz.c excluded - conflicts with macOS CarbonCore headers */

/* Files that don't include Defn.h */
#include "axis_scales.c"
#include "chull.c"

/* init.c must be last - contains R_init_grDevices */
#include "init.c"
