/* Unity build batch 2 for src/nmath - Gamma/Beta special functions */

#include "lgammacor.c"
#undef xbig
#undef nalgm
#include "gammalims.c"
#include "stirlerr.c"
#include "bd0.c"
#include "gamma.c"
#undef ngam
#undef xmin
#undef xmax
#undef xsml
#undef dxrel
#include "lgamma.c"
#undef xmax
#undef dxrel
#include "gamma_cody.c"
#include "beta.c"
#undef xmin
#undef xmax
#undef lnsml
#include "lbeta.c"
#include "polygamma.c"
#include "cospi.c"
#include "choose.c"
