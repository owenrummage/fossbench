/*
 * Compiler-optimised C implementation of the benchmark kernels.
 *
 * Keep this translation unit separate from the assembly backend so release
 * builds can apply their strongest safe optimisation settings to it.  The
 * implementation is shared with the portable i386 backend; symbol renaming
 * lets both backends live in the same executable.
 */
#define fb_int_math fb_c_int_math
#define fb_fp_math fb_c_fp_math
#define fb_primes fb_c_primes
#define fb_simd fb_c_simd
#define fb_compress fb_c_compress
#define fb_chacha20 fb_c_chacha20
#define fb_physics fb_c_physics
#define fb_sort fb_c_sort
#define fb_chase fb_c_chase

#include "fossbench-i386.c"
