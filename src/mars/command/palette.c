/*
 * Palette commands
 */

#include "mars.h"
#include "command.h"
#include "vdp.h"
#include "palette.h"


static void process(u16* param_base, u32 command_id);
static void post_process(u32 command_id);


command CMD_PALETTE =
{
    process,
    post_process
};


static void process(u16* param_base, u32 command_id)
{
    u32 palette_id  = command_id & 0x01;
    u32 action_id   = command_id & 0xfe;

    switch (action_id)
    {
        case CMD_PALETTE_FILL:
            {
                palette_fill_parameters* fill_parameters = (palette_fill_parameters*) param_base;

                pal_fill(palette_id, fill_parameters->offset, fill_parameters->count + 1, fill_parameters->color);
            }
            break;

        case CMD_PALETTE_LOAD:
            // TODO...
            break;
    }
}


static void post_process(u32 command_id)
{
    u32 action_id = command_id & 0xfe;

    switch (action_id)
    {
        case CMD_PALETTE_COMMIT:
            pal_commit();
            break;

        case CMD_PALETTE_TRANSITION:
        {
            while (pal_transition_step(2))
            {
                vdp_vsync_wait(1);

                pal_commit();
            }
        }
        break;
    }
}
