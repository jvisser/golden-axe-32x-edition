/*
 * 32X registers
 */

#ifndef __MARS_H__
#define __MARS_H__

#include "types.h"


#define MARS_ROM                        ((u8*)  0x02000000 )
#define MARS_CRAM                       ((u16*) 0x20004200 )
#define MARS_FRAMEBUFFER                ((u16*) 0x24000000 )
#define MARS_OVERWRITE_IMG              ((u16*) 0x24020000 )
#define MARS_SDRAM                      ((u16*) 0x26000000 )

#define MARS_SYS_INTMSK                 (*(volatile u16*) 0x20004000 )
#define MARS_SYS_INTMSK_FM              0x8000

#define MARS_COMM0                      (*(volatile u16*) 0x20004020 )
#define MARS_COMM1                      (*(volatile u16*) 0x20004022 )
#define MARS_COMM2                      (*(volatile u16*) 0x20004024 )
#define MARS_COMM3                      (*(volatile u16*) 0x20004026 )
#define MARS_COMM4                      (*(volatile u16*) 0x20004028 )
#define MARS_COMM5                      (*(volatile u16*) 0x2000402A )
#define MARS_COMM6                      (*(volatile u16*) 0x2000402C )
#define MARS_COMM7                      (*(volatile u16*) 0x2000402E )

#define MARS_COMM0L                     (*(volatile u32*) &MARS_COMM0 )
#define MARS_COMM2L                     (*(volatile u32*) &MARS_COMM2 )
#define MARS_COMM4L                     (*(volatile u32*) &MARS_COMM4 )
#define MARS_COMM6L                     (*(volatile u32*) &MARS_COMM6 )

#define MARS_VDP_DISPMODE               (*(volatile u16*) 0x20004100 )
#define MARS_VDP_DISPMODE_BLANK         0x0000
#define MARS_VDP_DISPMODE_PACKED        0x0001
#define MARS_VDP_DISPMODE_DIRECT_COLOR  0x0002
#define MARS_VDP_DISPMODE_RLE           0x0003

#define MARS_VDP_SHIFTREG               (*(volatile u16*) 0x20004102 )
#define MARS_VDP_FILLLEN                (*(volatile u16*) 0x20004104 )
#define MARS_VDP_FILLADR                (*(volatile u16*) 0x20004106 )
#define MARS_VDP_FILLDAT                (*(volatile u16*) 0x20004108 )

#define MARS_VDP_FBCTL                  (*(volatile u16*) 0x2000410A )
#define MARS_VDP_FBCTL_VBLK             0x8000
#define MARS_VDP_FBCTL_HBLK             0x4000
#define MARS_VDP_FBCTL_PEN              0x2000
#define MARS_VDP_FBCTL_FS               0x0001


#define ROM_ADDR(address)               (MARS_ROM + (u32) (address))


// There is no memory allocator atm.
// This can be used as free memory up until the top of the master cpu stack.
extern u8* __free_ram_start;


#endif
