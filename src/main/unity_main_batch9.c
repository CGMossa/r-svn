/* Unity build batch 9 for src/main */
#define R_USE_SIGNALS 1

#include "print.c"
#include "printarray.c"
#include "printvector.c"
#include "printutils.c"
#include "qsort.c"
#include "random.c"
#include "raw.c"
#include "registration.c"
#include "relop.c"
#include "rlocale.c"
/* radixsort.c redefines warning macro - must come after files that use warning */
#include "radixsort.c"
