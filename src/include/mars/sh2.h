/*
 * SH2 registers
 */

#ifndef __SH2_H__
#define __SH2_H__

#include "types.h"


#define CACHED(address)     (((u32) (address)) & ~0x20000000)
#define UNCACHED(address)   (((u32) (address)) | 0x20000000)


#define SH2_CCR             (*(volatile u8*) 0xfffffe92)
#define SH2_CCR_CP          0x10

#define SH2_CACHE_PURGE     SH2_CCR |= SH2_CCR_CP


#endif
