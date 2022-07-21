/*
 * Palette commands
 */

#include "mars.h"
#include "command.h"
#include "noop.h"
#include "vdp.h"
#include "palette.h"


static void process(u32 command_id, u16* param_base);
static void post_process(u32 command_id, u16* param_base);


command CMD_PALETTE =
{
    process,
    post_process
};


static void process(u32 command_id, UNUSED u16* param_base)
{
    u32 action_id   = command_id & 0xfe;

    switch (action_id)
    {
        case CMD_PALETTE_LOAD:
            // TODO...
            break;
    }
}


static void post_process(u32 command_id, u16* param_base)
{
    u32 palette_id  = command_id & 0x01;
    u32 action_id   = command_id & 0xfe;

    palette_parameters* parameters = (palette_parameters*) param_base;

    switch (action_id)
    {
        case CMD_PALETTE_COMMIT:
            pal_commit();
            break;

        case CMD_PALETTE_FILL:
            pal_fill(palette_id, parameters->offset, parameters->count + 1, parameters->color);
            break;

        case CMD_PALETTE_SUBTRACT:
            {
                pal_subtract(parameters->offset, parameters->count + 1, parameters->color);

                vdp_vsync_wait(1);

                pal_commit();
            }
            break;

        case CMD_PALETTE_TRANSITION:
            {
                while (pal_transition_step(parameters->offset, parameters->count + 1, parameters->color))
                {
                    vdp_vsync_wait(1);

                    pal_commit();
                }
            }
            break;

        case CMD_PALETTE_COPY:
            pal_copy(palette_id);
            break;
    }
}
