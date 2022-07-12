/*
 * Master SH2 main loop
 *
 * Executes commands received from the MD
 */

#include "mars.h"
#include "command.h"


static void init(void)
{
    // Wait for the SH2 to gain access to the VDP
    while ((MARS_SYS_INTMSK & MARS_SYS_INTMSK_FM) == 0);

    // Signal ready to the m68k side
    MARS_COMM0L = 0;
}


void master(void)
{
    init();

    command_main(&MARS_COMM0);
}
