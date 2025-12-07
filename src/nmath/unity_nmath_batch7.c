/* Unity build batch 7 for src/nmath - Binomial (qbinom uses qDiscrete_search.h) */

#include "dbinom.c"
#include "pbinom.c"

/* qbinom.c defines _thisDIST_ = binom and includes qDiscrete_search.h
 * which creates a static do_search() specific to binomial */
#include "qbinom.c"
#undef _thisDIST_
#undef _dist_PARS_DECL_
#undef _dist_PARS_
#undef _dist_MAX_y
#undef PST_0
#undef PASTE
#undef CHR_0
#undef AS_CHAR
#undef _pDIST_
#undef _qDIST_
#undef DO_SEARCH_FUN
#undef DO_SEARCH_
#undef P_DIST
#undef MAYBE_R_CheckUserInterrupt
#undef q_DISCRETE_01_CHECKS
#undef q_DISCR_CHECK_BOUNDARY
#undef q_DISCRETE_BODY
#undef R_DBG_printf

#include "rbinom.c"
#undef repeat

#include "rmultinom.c"
