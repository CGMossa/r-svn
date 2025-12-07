/* Unity build batch 1 for src/main */
#define R_USE_SIGNALS 1

#include "CommandLineArgs.c"
#include "Rdynload.c"
#include "Renviron.c"
#include "RNG.c"
#undef long  /* RNG.c defines long as Int32 */

#include "agrep.c"
#include "altclasses.c"
#include "altrep.c"
#include "apply.c"
