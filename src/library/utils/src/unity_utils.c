/* Unity build file for utils library
 * Combines all source files into single translation unit
 *
 * Files that include Defn.h must come FIRST for USE_RINTERNALS.
 * Then #undef conflicting macros before including utils.c which
 * declares IS_UTF8/ENC_KNOWN as function prototypes.
 */

/* Define USE_RINTERNALS before any includes for size.c compatibility */
#define USE_RINTERNALS

/* Files that include Defn.h - must come first for USE_RINTERNALS */
#include "io.c"
#include "size.c"
#include "stubs.c"

/* Undefine macros that conflict with function declarations in utils.c */
#undef IS_UTF8
#undef ENC_KNOWN
#undef IS_ASCII

/* utils.c declares IS_UTF8/ENC_KNOWN as function prototypes */
#include "utils.c"

/* These files don't include Defn.h */
#include "hashtab.c"
#include "sock.c"

/* init.c must be last - contains R_init_utils */
#include "init.c"
