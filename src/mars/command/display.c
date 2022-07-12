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
#include "noop.h"
#include "command.h"


static void process();


command CMD_DISPLAY =
{
    process,
    no_operation
};


static void process(u16* param_base)
{
    display_command_parameters* parameters = (display_command_parameters*) param_base;

    switch (parameters->sub_command)
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
