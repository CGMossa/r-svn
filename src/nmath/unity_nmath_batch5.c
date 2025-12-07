/* Unity build batch 5 for src/nmath - Uniform and Normal distributions */

/* Uniform distribution */
#include "dunif.c"
#include "punif.c"
#include "qunif.c"
#include "runif.c"

/* Normal distribution */
#include "dnorm.c"
#include "pnorm.c"
#undef swap_tail
#undef do_del
#include "qnorm.c"
#include "rnorm.c"

/* Log-normal distribution */
#include "dlnorm.c"
#include "plnorm.c"
#include "qlnorm.c"
#include "rlnorm.c"
