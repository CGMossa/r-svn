/* Unity build batch 3 for src/main */
#define R_USE_SIGNALS 1

/* cbuff conflict - character.c */
#define cbuff character_cbuff
#include "character.c"
#undef cbuff

#include "clippath.c"
#include "coerce.c"
#include "colors.c"
#include "complex.c"

/* con_cleanup conflict - connections.c */
#define con_cleanup connections_con_cleanup
#include "connections.c"
#undef con_cleanup

#include "context.c"
#include "cum.c"
