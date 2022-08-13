/*
 * 32X VDP routines
 */

#include "mars.h"
#include "vdp.h"


void vdp_vsync_wait(u32 frames)
{
    if (!vdp_enabled())
    {
        return;
    }

    while (frames--)
    {
        // If in vblank wait for the next one (frame skip)
        while (MARS_VDP_FBCTL & MARS_VDP_FBCTL_VBLK);

        // Wait for vblank
        while ((MARS_VDP_FBCTL & MARS_VDP_FBCTL_VBLK) == 0);
    }
}


void vdp_set_display_mode(u32 mode)
{
    MARS_VDP_DISPMODE = (MARS_VDP_DISPMODE & ~0x03) | (mode & 0x03);
}


void vdp_swap_frame_buffer(void)
{
    MARS_VDP_FBCTL ^= MARS_VDP_FBCTL_FS;
}


void vdp_update_palette(u16* colors, u32 offset, u32 count)
{
    //while ((MARS_VDP_FBCTL & MARS_VDP_FBCTL_PEN) == 0);

    u16 *cram_entry = MARS_CRAM + offset;
    for (u32 i = 0; i < count; i++)
    {
        *cram_entry++ = *colors++;
    }
}


u32 vdp_enabled(void)
{
    return MARS_VDP_DISPMODE & 0x03;
}
