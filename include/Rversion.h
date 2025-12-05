/* Rversion.h.  Generated automatically. */
#ifndef R_VERSION_H
#define R_VERSION_H

#ifdef __cplusplus
extern "C" {
#endif

#define R_VERSION 263680
#define R_NICK "Unsuffered Consequences"
#define R_Version(v,p,s) (((v) * 65536) + ((p) * 256) + (s))
#define R_MAJOR  "4"
#define R_MINOR  "6.0"
#define R_STATUS "Under development (unstable)"
#define R_YEAR   "2006"
#define R_MONTH  "01"
#define R_DAY    "01"
#define R_SVN_REVISION 0
#ifdef __llvm__
# define R_FILEVERSION    4,60,0,0
#else
# define R_FILEVERSION    4,60,0,0
#endif

#ifdef __cplusplus
}
#endif

#endif /* not R_VERSION_H */
