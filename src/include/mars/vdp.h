/*
 * 32X VDP related routines
 */


#ifndef __VDP_H__
#define __VDP_H__

#include "mars.h"


#define DISPLAY_MODE_BLANK          0x0000
#define DISPLAY_MODE_PACKED         0x0001
#define DISPLAY_MODE_DIRECT_COLOR   0x0002
#define DISPLAY_MODE_REL            0x0003


extern void vdp_vsync_wait();
extern void vdp_clear_frame_buffer();
extern void vdp_set_display_mode(u32 mode);
extern void vdp_swap_frame_buffer();
extern void vdp_update_palette(u16* colors, u32 offset, u32 count);


#endif
