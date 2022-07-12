/*
 * Palette support functions
 */

#include "types.h"
#include "mars.h"
#include "vdp.h"


static u16 current_palette[256];
static u16 target_palette[256];


static u16* palettes[] =
{
    current_palette,
    target_palette
};


void pal_fill(u32 palette_id, u32 offset, u32 count, u16 color)
{
    u16* target = palettes[palette_id] + offset;

    for (u32 i = 0; i < count; i++)
    {
        *target++ = color;
    }
}


void pal_replace(u32 palette_id, u16 *colors, u32 offset, u32 count)
{
    u16* target = palettes[palette_id] + offset;

    for (u32 i = 0; i < count; i++)
    {
        *target++ = *colors++;
    }
}


static u16 step(s32 s, s32 t, s32 step_size)
{
    if (s > t)
    {
        s -= step_size;
        if (s < t)
        {
            s = t;
        }
    }
    else if (s < t)
    {
        s += step_size;
        if (s > t)
        {
            s = t;
        }
    }

    return s;
}


u32 pal_transition_step(u32 step_size)
{
    u16* source = current_palette;
    u16* target = target_palette;

    u32 changed = 0;
    for (u32 i = 0; i < 256; i++)
    {
        u16 source_color = *source;
        u16 target_color = *target++;

        if (source_color != target_color)
        {
            u16 sb = source_color & 0x7c00;
            u16 sg = source_color & 0x03e0;
            u16 sr = source_color & 0x001f;

            u16 tb = target_color & 0x7c00;
            u16 tg = target_color & 0x03e0;
            u16 tr = target_color & 0x001f;

            u16 rb = step(sb, tb, step_size << 10);
            u16 rg = step(sg, tg, step_size << 5);
            u16 rr = step(sr, tr, step_size);

            u16 color = rb | rg | rr | (target_color & 0x8000);

            *source = color;

            changed = 1;
        }
        source++;
    }

    return changed;
}


void pal_commit(void)
{
    vdp_update_palette(current_palette, 0, 256);
}
