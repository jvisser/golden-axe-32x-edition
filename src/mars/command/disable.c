#include "mars.h"
#include "command.h"

static void process();
static void post_process();


md_command CMD_DISABLE =
{
    process,
    post_process
};


static void process()
{
    MARS_SYS_INTMSK = MARS_SYS_INTMSK_FM;
    MARS_VDP_DISPMODE = 0;
}


static void post_process()
{
    // Clear framebuffer
    for (int i = 0; i < 0x10000; i++)
    {
        MARS_FRAMEBUFFER[i] = 0;
    }

    // Swap buffer on next vblank
    MARS_VDP_FBCTL ^= 1;
}
