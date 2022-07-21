/*
 * Display commands
 */

#include "mars.h"
#include "vdp.h"
#include "draw.h"
#include "noop.h"
#include "command.h"


static void process(u32 command_id, u16* param_base);


command CMD_DISPLAY =
{
    process,
    no_operation
};


static void process(u32 command_id, UNUSED u16* param_base)
{
    switch (command_id & 0xff)
    {
        case CMD_DISPLAY_ENABLE:
            vdp_set_display_mode(DISPLAY_MODE_PACKED);
            break;

        case CMD_DISPLAY_DISABLE:
            vdp_set_display_mode(DISPLAY_MODE_BLANK);
            break;

        case CMD_DISPLAY_SWAP:
            vdp_swap_frame_buffer();
            break;
    }
}
