/* Unity build batch 4 for src/nmath - snorm/sexp and gamma/beta distributions */

#include "snorm.c"
#undef repeat
#include "sexp.c"

/* Gamma distribution */
#include "dgamma.c"
#include "pgamma.c"
#include "qgamma.c"
#include "rgamma.c"
#undef repeat

/* Beta distribution */
#include "dbeta.c"
#include "pbeta.c"
#include "qbeta.c"
#include "rbeta.c"
