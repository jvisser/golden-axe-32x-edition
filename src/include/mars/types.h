/*
 * General typedefs
 */

#ifndef __TYPES_H__
#define __TYPES_H__


typedef unsigned char       u8;
typedef unsigned short      u16;
typedef unsigned int        u32;
typedef unsigned long long  u64;

typedef signed char         s8;
typedef signed short        s16;
typedef signed int          s32;
typedef signed long long    s64;


#define ATTR_ALIGNED(a)     __attribute__((aligned(a)))
#define ATTR_UNCACHED       __attribute__ ((section ("uncached")))
#define HINT_ALIGN(d, a)    __builtin_assume_aligned(d, a)


#endif
