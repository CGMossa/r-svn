/* Unity build batch 10 for src/main */
#define R_USE_SIGNALS 1

/* con_cleanup conflict - saveload.c */
#define con_cleanup saveload_con_cleanup
#include "saveload.c"
#undef con_cleanup

#include "scan.c"

/* cbuff conflict - seq.c */
#define cbuff seq_cbuff
#include "seq.c"
#undef cbuff

/* serialize.c moved to batch11 - conflicts with saveload.c (MakeHashTable, HashAdd, HashGet) */

#include "sort.c"
#include "source.c"
#include "split.c"
#include "sprintf.c"
#include "startup.c"
