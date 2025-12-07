/* Unity build batch 7 for src/main */
#define R_USE_SIGNALS 1

#include "gram.c"
#undef NEXT  /* gram.c defines NEXT as token number */
#include "gram-ex.c"
#include "lapack.c"
#include "list.c"
#include "localecharset.c"
#include "logic.c"
#include "machine.c"
/* main.c excluded - must be compiled separately due to __MAIN__ */
#include "mapply.c"
#include "mask.c"
#include "match.c"
#include "names.c"
/* memory.c excluded - must be compiled separately due to STRING_ELT redefinition */
