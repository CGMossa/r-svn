/* Unity build batch 4 for src/main */
#define R_USE_SIGNALS 1

/* con_cleanup conflict - dcf.c */
#define con_cleanup dcf_con_cleanup
#include "dcf.c"
#undef con_cleanup

#include "datetime.c"
#include "debug.c"

/* con_cleanup conflict - deparse.c */
#define con_cleanup deparse_con_cleanup
#include "deparse.c"
#undef con_cleanup

#include "devices.c"
#include "dotcode.c"
#include "dounzip.c"
#include "dstruct.c"
#include "duplicate.c"
