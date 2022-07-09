#include "mars.h"

static void init()
{
    // Wait for the SH2 to gain access to the VDP
    while ((MARS_SYS_INTMSK & MARS_SYS_INTMSK_FM) == 0);

    // Signal ready to the m68k side
    MARS_COMM0L = 0;
}


void master_int_vblank(void)
{
}


void master(void)
{
    init();

    while (1);
}