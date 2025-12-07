/* Unity build file for parallel library (Windows)
 * Combines all source files into single translation unit
 *
 * Windows version uses ncpus.c instead of fork.c (no fork on Windows)
 */

/* Other source files */
#include "rngstream.c"
#include "ncpus.c"

/* init.c must be last - contains R_init_parallel */
#include "init.c"
