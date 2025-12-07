/* Unity build batch 8 for src/main */
#define R_USE_SIGNALS 1

#include "objects.c"
#include "options.c"

/* cbuff conflict - paste.c */
#define cbuff paste_cbuff
#include "paste.c"
#undef cbuff

#include "patterns.c"
#include "platform.c"
#include "plot.c"
#include "plot3d.c"
#include "plotmath.c"
