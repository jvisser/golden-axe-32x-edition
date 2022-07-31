/*
 * Palette support functions
 */

#include "types.h"
#include "mars.h"
#include "vdp.h"
#include "palette.h"


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


void pal_replace(u32 palette_id, u32 offset, u32 count, u16 const *colors)
{
    u16* target = palettes[palette_id] + offset;

    for (u32 i = 0; i < count; i++)
    {
        *target++ = *colors++;
    }
}


void pal_copy(u32 palette_id)
{
    u16* source = palettes[palette_id];
    u16* target = palettes[palette_id ^ 1];

    for (u32 i = 0; i < 256; i++)
    {
        *target++ = *source++;
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


u32 pal_transition_step(u32 offset, u32 count, u32 step_size)
{
    u16* source = current_palette + offset;
    u16* target = target_palette + offset;

    u16 b_step = step_size & 0x7c00;
    u16 g_step = step_size & 0x03e0;
    u16 r_step = step_size & 0x001f;

    u32 changed = 0;
    for (u32 i = 0; i < count; i++)
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

            u16 rb = step(sb, tb, b_step);
            u16 rg = step(sg, tg, g_step);
            u16 rr = step(sr, tr, r_step);

            u16 color = rb | rg | rr | (target_color & 0x8000);

            *source = color;

            changed = 1;
        }
        source++;
    }

    return changed;
}


void pal_subtract(u32 offset, u32 count, u16 color)
{
    u16* source = target_palette + offset;
    u16* target = current_palette + offset;

    u16 b_step = color & 0x7c00;
    u16 g_step = color & 0x03e0;
    u16 r_step = color & 0x001f;

    for (u32 i = 0; i < count; i++)
    {
        u16 source_color = *source++;

        u16 sb = source_color & 0x7c00;
        u16 sg = source_color & 0x03e0;
        u16 sr = source_color & 0x001f;

        u16 rb = step(sb, 0, b_step);
        u16 rg = step(sg, 0, g_step);
        u16 rr = step(sr, 0, r_step);

        *target++ = rb | rg | rr | (source_color & 0x8000);
    }
}


void pal_commit(void)
{
    vdp_update_palette(current_palette, 0, 256);
}


void pal_transition(u32 offset, u32 count, u32 step_size, u32 wait_frames)
{
    while (pal_transition_step(offset, count, step_size))
    {
        vdp_vsync_wait(wait_frames);

        pal_commit();
    }
}
