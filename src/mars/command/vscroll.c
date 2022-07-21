/*
 * Vertical scroll command
 */

#include "mars.h"
#include "command.h"
#include "vdp.h"
#include "noop.h"


static void post_process(u32 command_id, u16* param_base);


command CMD_VERTICAL_SCROLL =
{
    no_operation,
    post_process
};


static void post_process(u32 command_id, UNUSED u16* param_base)
{
    u32 vertical_scroll = command_id & 0xff;

    vdp_vsync_wait(1);
    vdp_swap_frame_buffer();

    // Update line table
    u16* line = MARS_FRAMEBUFFER;
    for (u32 i = 0; i < 256; i++)
    {
        *line++ = 256 + ((vertical_scroll + i) & 0xff) * 160;
    }

    vdp_swap_frame_buffer();
}
