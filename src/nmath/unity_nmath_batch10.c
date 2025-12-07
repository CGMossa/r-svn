/* Unity build batch 10 for src/nmath - Poisson and remaining distributions */

/* Poisson distribution - qpois uses qDiscrete_search.h */
#include "dpois.c"
#include "ppois.c"
#include "qpois.c"
#undef _thisDIST_
#undef _dist_PARS_DECL_
#undef _dist_PARS_
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

#include "rpois.c"
#undef repeat
#undef a0
#undef a1
#undef a2
#undef a3
#undef a4
#undef a5
#undef a6
#undef a7
#undef one_7
#undef one_12
#undef one_24

/* Weibull distribution */
#include "dweibull.c"
#include "pweibull.c"
#include "qweibull.c"
#include "rweibull.c"

/* Logistic distribution */
#include "dlogis.c"
#include "plogis.c"
#include "qlogis.c"
#include "rlogis.c"

/* Non-central distributions */
#include "dnchisq.c"
#include "pnchisq.c"
#include "qnchisq.c"
#include "dnbeta.c"
#include "pnbeta.c"
#include "qnbeta.c"
#include "pnf.c"
#include "pnt.c"
#include "qnf.c"
#include "qnt.c"

/* Tukey distribution */
#include "ptukey.c"
#include "qtukey.c"

/* toms708 only - wilcox and signrank have conflicting static symbols */
#include "toms708.c"
