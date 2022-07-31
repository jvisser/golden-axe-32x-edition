/*
 * Map commands
 */

#include "mars.h"
#include "command.h"
#include "noop.h"
#include "vdp.h"
#include "palette.h"


static void process(u32 command_id, u16* param_base);
static void post_process(u32 command_id, u16* param_base);


command CMD_MAP =
{
    process,
    post_process
};


typedef struct
{
    u32 width;
    u32 height;
    u32 tile_map_offset;
    u32 blocks_offset;
    u32 palette_offsets[4];
    u32 data_size;
    u32 data[];
} map_def;

typedef u16 const block[32];

typedef struct
{
    u16 color_count;
    u16 colors[];
} map_palette;

typedef struct
{
    u32                             width;
    u32                             height;
    u16         const ALIGNED(4)*   tile_map;
    block       const ALIGNED(4)*   blocks;
    map_palette const ALIGNED(4)*   palettes[4];
} map_data;


static map_def const ALIGNED(4)* const * const md_map_table = (map_def const**) 0x22080000;
static map_def const ALIGNED(4)* map_definition = 0;
static map_data map;

static u32 vertical_scroll;
static u32 horizontal_scroll;


static void process(u32 command_id, u16* param_base)
{
    u32 action_id = command_id & 0xff;

    if (action_id == CMD_MAP_LOAD)
    {
        map_load_parameters* load_parameters = (map_load_parameters*) param_base;

        map_definition = HINT_ALIGN(md_map_table[load_parameters->map_index], 4);
        if (map_definition)
        {
            u32* map_base = (u32*) UNCACHED(&_free_ram_start);

            u32* target = map_base;
            u32 const* source = map_definition->data;
            for (u32 i = 0; i < map_definition->data_size; i++)
            {
                *target++ = *source++;
            }

            map.width    = map_definition->width;
            map.height   = map_definition->height;
            map.tile_map = (u16*) (map_base + map_definition->tile_map_offset);
            map.blocks   = (block*) (map_base + map_definition->blocks_offset);
            for (u32 i = 0; i < 4; i++)
            {
                map.palettes[i] = (map_palette*) (map_base + map_definition->palette_offsets[i]);
            }

            vertical_scroll = load_parameters->vertical_scroll << 4;
            horizontal_scroll = load_parameters->horizontal_scroll << 4;

            // Set initial palette
            pal_replace(PAL_CURRENT, 0, map.palettes[0]->color_count, map.palettes[0]->colors);
            pal_commit();

            // Render initial frame
            // TODO...
        }
    }
}


static void post_process(u32 command_id, u16* param_base)
{
    if (!map_definition)
    {
        return;
    }

    u32 action_id = command_id & 0xff;

    switch (action_id)
    {
        case CMD_MAP_SCROLL:
            {
                map_scroll_parameters* scroll_parameters = (map_scroll_parameters*) param_base;

                vertical_scroll = scroll_parameters->vertical_scroll;
                horizontal_scroll = scroll_parameters->horizontal_scroll;
            }
            break;

        case CMD_MAP_PALETTE:
            {
                map_palette_parameters* palette_parameters = (map_palette_parameters*) param_base;
                map_palette const* palette = map.palettes[palette_parameters->palette_index];

                if (palette_parameters->transition)
                {
                    pal_replace(PAL_TARGET, 0, palette->color_count, palette->colors);
                    pal_transition(0, palette->color_count, COLOR(1, 1, 1), 4);
                }
                else
                {
                    pal_replace(PAL_CURRENT, 0, palette->color_count, palette->colors);
                    vdp_vsync_wait(1);
                    pal_commit();
                }
            }
            break;
    }
}
