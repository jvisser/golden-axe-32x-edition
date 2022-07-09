#include "mars.h"
#include "command.h"

static void process();
static void post_process();


md_command CMD_IMAGE =
{
    process,
    post_process
};


static void process()
{
    // Load image
}


static void post_process()
{
    // Swap buffer
    // Vsync wait
    // Load palette
    // Enable display mode
}
