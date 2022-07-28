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

typedef u16 block[32];

typedef struct
{
    u16 color_count;
    u16 colors[];
} map_palette;

typedef struct
{
    u32                     width;
    u32                     height;
    u16         ALIGNED(4)* tile_map;
    block       ALIGNED(4)* blocks;
    map_palette ALIGNED(4)* palettes[4];
} map_data;


static map_def ALIGNED(4)** md_map_table = (map_def**) 0x22080000;
static map_def ALIGNED(4)*  map_definition = 0;
static map_data             map;


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
            u32* source = map_definition->data;
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
        }
    }
}


static void post_process(u32 command_id, u16* param_base)
{
    if (!map_definition)
    {
        return;
    }
}
