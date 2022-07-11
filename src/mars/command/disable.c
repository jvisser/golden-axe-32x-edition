/*
 * Disable command
 *
 * Disables the 32X display and clears the front facing framebuffer.
 *
 * Parameters:
 * - None
 */

#include "mars.h"
#include "vdp.h"
#include "draw.h"
#include "command.h"


static void process(u16* param_base);
static void post_process();


md_command CMD_DISABLE =
{
    process,
    post_process
};


static void process(__attribute__((unused)) u16* param_base)
{
    vdp_set_display_mode(DISPLAY_MODE_BLANK);
}


static void post_process()
{
// Disable for now, could cause unnecessary wait time when multiple commands arrive in quick succession
//    // Clear framebuffers
//    for (u32 i = 0; i < 2; i++)
//    {
//        draw_fill(0);
//
//        // Should have immediate effect since we disabled the display
//        vdp_swap_frame_buffer();
//    }
}
