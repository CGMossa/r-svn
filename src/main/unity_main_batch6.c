/* Unity build batch 6 for src/main */
#define R_USE_SIGNALS 1

#include "eval.c"
#include "gevents.c"
#include "graphics.c"
#include "grep.c"
#include "identical.c"
/* inlined.c excluded - must be compiled separately to export non-inline API functions */
/* inspect.c excluded - requires USE_RINTERNALS before Defn.h, compile separately */
#include "internet.c"
#include "iosupport.c"
