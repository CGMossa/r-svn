/* Unity build file for utils library (Windows)
 * Combines all source files into single translation unit
 *
 * Windows version includes additional files from windows/ subdirectory
 */

/* Core utils files */
#include "hashtab.c"
#include "io.c"
#include "size.c"
#include "sock.c"
#include "stubs.c"
#include "utils.c"

/* Windows-specific files */
#include "windows/dataentry.c"
#include "windows/dialogs.c"
#include "windows/registry.c"
#include "windows/util.c"
#include "windows/widgets.c"

/* init.c must be last - contains R_init_utils */
#include "init.c"
