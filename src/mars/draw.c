/*
 * Draw to frame buffer routines
 */

#include "mars.h"


void draw_fill(u16 color)
{
    for (u32 i = 0; i < 0x10000; i++)
    {
        MARS_FRAMEBUFFER[i] = color;
    }
}
