/* Unity build batch 9 for src/nmath - Negative binomial (qnbinom only) */

#include "dnbinom.c"
#include "pnbinom.c"

/* qnbinom.c defines _thisDIST_ = nbinom and includes qDiscrete_search.h
 * which creates a static do_search() specific to nbinom */
#include "qnbinom.c"

#include "rnbinom.c"
