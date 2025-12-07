/* Unity build batch 11 for src/main */
#define R_USE_SIGNALS 1

/* con_cleanup conflict - serialize.c (moved from batch10 - conflicts with saveload.c) */
#define con_cleanup serialize_con_cleanup
#include "serialize.c"
#undef con_cleanup
#undef PTRHASH  /* serialize.c macro conflicts with unique.c function */

#include "subassign.c"
#include "subscript.c"
/* subset.c moved to batch12 - conflicts with subassign.c (VECTOR_ELT_FIX_NAMED, R_DispatchOrEvalSP) */
#include "summary.c"
#include "sysutils.c"
#include "times.c"
#include "unique.c"
#include "util.c"
#include "version.c"
