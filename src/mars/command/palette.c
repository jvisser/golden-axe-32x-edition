/*
 * Disable command
 *
 * Disables the 32X display and clears the front facing framebuffer.
 *
 * Parameters:
 * - None
 */

#include "mars.h"
#include "command.h"
#include "vdp.h"
#include "palette.h"


static void process(u16* param_base);
static void post_process();


command CMD_PALETTE =
{
    process,
    post_process
};


static u32 sub_command;


static void process(u16* param_base)
{
    palette_command_parameters* parameters = (palette_command_parameters*) param_base;

    sub_command = parameters->sub_command;
    switch (sub_command)
    {
        case CMD_PALETTE_FILL:
            pal_fill(parameters->palette_id, 0, 256, parameters->data);
            break;

        case CMD_PALETTE_LOAD:
            // TODO...
            break;

        case CMD_PALETTE_COMMIT:
            pal_commit();
            break;
    }
}


static void post_process()
{
    if (sub_command == CMD_PALETTE_TRANSITION)
    {
        while (pal_transition_step(2))
        {
            vdp_vsync_wait(1);

            pal_commit();
        }
    }
}
