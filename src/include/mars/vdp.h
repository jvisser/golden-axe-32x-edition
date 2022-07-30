/*
 * 32X VDP related routines
 */

#ifndef __VDP_H__
#define __VDP_H__

#include "types.h"
#include "mars.h"


#define DISPLAY_MODE_BLANK          MARS_VDP_DISPMODE_BLANK
#define DISPLAY_MODE_PACKED         MARS_VDP_DISPMODE_PACKED
#define DISPLAY_MODE_DIRECT_COLOR   MARS_VDP_DISPMODE_DIRECT_COLOR
#define DISPLAY_MODE_RLE            MARS_VDP_DISPMODE_RLE


extern void vdp_vsync_wait(u32 frames);
extern void vdp_set_display_mode(u32 mode);
extern void vdp_swap_frame_buffer(void);
extern void vdp_update_palette(u16* colors, u32 offset, u32 count);
extern u32  vdp_enabled(void);


#endif
