/* Unity build batch 2 for src/main */
#define R_USE_SIGNALS 1

#include "arithmetic.c"
#undef R_INT_MIN
#include "array.c"
#include "attrib.c"

/* cbuff conflict - bind.c */
#define cbuff bind_cbuff
#define imax2 bind_imax2
#include "bind.c"
#undef cbuff
#undef imax2

#include "builtin.c"
