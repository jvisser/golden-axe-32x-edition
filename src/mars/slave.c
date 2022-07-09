#include "mars.h"


static void init()
{
    // Wait for the SH2 to gain access to the VDP
    while ((MARS_SYS_INTMSK & MARS_SYS_INTMSK_FM) == 0);

    // Signal ready to the m68k side
    MARS_COMM2L = 0;
}


void slave(void)
{
    init();

    while (1);
}