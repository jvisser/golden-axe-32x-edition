/*
 * Map commands
 */

#include "mars.h"
#include "sh2.h"
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
    u16         const ATTR_ALIGNED(4)*   tile_map;
    block       const ATTR_ALIGNED(4)*   blocks;
} map_data;


static map_def const ATTR_ALIGNED(4)* const * const md_map_table = (map_def const**) 0x22080000;
static map_def const ATTR_ALIGNED(4)* map_definition ATTR_UNCACHED = 0;
static map_palette const ATTR_ALIGNED(4)* palettes[4] ATTR_UNCACHED;
static map_data map;

static u32 vertical_scroll;
static u32 horizontal_scroll;

static u16 ATTR_ALIGNED(4)* line_table_buffer;
static u16 ATTR_ALIGNED(4)* render_buffer;
static u32 render_buffer_slope;
static u32 h_diff_accumulated;


static void recalculate_line_table(void)
{
    u32 fb_line_base = vertical_scroll + (horizontal_scroll / 328);
    u32 fb_x_offset = (horizontal_scroll % 328) >> 1;

    for (u32 y = 0; y < 224; y++)
    {
        line_table_buffer[y] = 256 + ((fb_line_base + y) & 0xff) * 164 + fb_x_offset;
    }
}


static u16* render_line(u32 screen_line, u16* frame_buffer)
{
    u32 yy = vertical_scroll + screen_line;
    u32 tile_row_offset = (yy & 0x07) << 2;

    u16 const *tile_id = &map.tile_map[((yy >> 3) * map.width) + (horizontal_scroll >> 3)];
    for (u32 x = 0; x < 41; x++)
    {
        u16 const* tile_line = map.blocks[*tile_id++] + tile_row_offset;

        *frame_buffer++ = *tile_line++;
        *frame_buffer++ = *tile_line++;
        *frame_buffer++ = *tile_line++;
        *frame_buffer++ = *tile_line;
    }

    return frame_buffer;
}


static u16* render_column(u16* rb)
{
    u32 full_blocks = 28;
    u16 const *tile_id = &map.tile_map[((vertical_scroll >> 3) * map.width) + ((horizontal_scroll + 320) >> 3)];

    u32 tile_column_offset = (horizontal_scroll & 0x07) >> 1;
    u32 tile_row_index = vertical_scroll & 0x07;

    // Render first block
    if (tile_row_index)
    {
        u32 first_block_row_count = 8 - tile_row_index;
        u16 const* first_block = map.blocks[*tile_id] + (tile_row_index << 2) + tile_column_offset;
        for (u32 i = 0; i < first_block_row_count; i++)
        {
            *rb++ = *first_block;
            first_block += 4;
        }

        tile_id += map.width;
        full_blocks--;
    }

    for (u32 y = 0; y < full_blocks; y++)
    {
        u16 const* block = map.blocks[*tile_id] + tile_column_offset;

        *rb++ = *block;
        *rb++ = *(block + 4);
        *rb++ = *(block + 8);
        *rb++ = *(block + 12);
        *rb++ = *(block + 16);
        *rb++ = *(block + 20);
        *rb++ = *(block + 24);
        *rb++ = *(block + 28);

        tile_id += map.width;
    }

    // Render last block
    if (tile_row_index)
    {
        u32 last_block_row_count = tile_row_index;
        u16 const* last_block = map.blocks[*tile_id] + tile_column_offset;
        for (u32 i = 0; i < last_block_row_count; i++)
        {
            *rb++ = *last_block;
            last_block += 4;
        }
    }

    return rb;
}


static u16* copy_line(u16 *src, u16* dest)
{
    for (u32 i = 0; i < 41; i++)
    {
        *dest++ = *src++;
        *dest++ = *src++;
        *dest++ = *src++;
        *dest++ = *src++;
    }

    return src;
}


static void copy_line_table(void)
{
    u16* line_table = MARS_FRAMEBUFFER;
    u16* line_table_src = line_table_buffer;
    for (u32 i = 0; i < 224 / 8; i++)
    {
        *line_table++ = *line_table_src++;
        *line_table++ = *line_table_src++;
        *line_table++ = *line_table_src++;
        *line_table++ = *line_table_src++;
        *line_table++ = *line_table_src++;
        *line_table++ = *line_table_src++;
        *line_table++ = *line_table_src++;
        *line_table++ = *line_table_src++;
    }
}

static void render_full(void)
{
    recalculate_line_table();

    // Render
    for (u32 y = 0; y < 224; y++)
    {
        u32 frame_buffer_offset = MARS_FRAMEBUFFER[y] = line_table_buffer[y];
        u16* fb_line = MARS_FRAMEBUFFER + (frame_buffer_offset & ~0x03);

        render_line(y, fb_line);
    }

    // Output to screen
    vdp_vsync_wait(1);
    vdp_swap_frame_buffer();

    MARS_VDP_SHIFTREG = horizontal_scroll;
}


static void scroll(s32 new_horizontal_scroll, s32 new_vertical_scroll)
{
    s32 h_diff = new_horizontal_scroll - horizontal_scroll;
    s32 v_diff = new_vertical_scroll - vertical_scroll;

    if (!(v_diff | h_diff))
    {
        return;
    }

    h_diff_accumulated += h_diff;
    vertical_scroll = new_vertical_scroll;
    horizontal_scroll = new_horizontal_scroll;

    u16* rb = render_buffer;

    // Buffer wrap?
    render_buffer_slope -= h_diff;
    u16 buffer_wrap = render_buffer_slope <= 0;
    if (buffer_wrap)
    {
        render_buffer_slope += 328;
    }

    recalculate_line_table();

    // Render lines to render buffer
    u32 lines = 0;
    if (v_diff)
    {
        u16 screen_line_base;
        if (v_diff < 0)
        {
            lines = -v_diff;
            screen_line_base = 0;             // Scroll up
        }
        else if (v_diff > 0)
        {
            lines = v_diff;
            screen_line_base = 224 - lines;   // Scroll down
        }

        for (u32 i = 0; i < lines; i++)
        {
            u32 screen_line = screen_line_base + i;

            *rb++ = line_table_buffer[screen_line] & ~0x03;

            rb = render_line(screen_line, rb);
        }
    }

    // Render column to render buffer
    u32 h_diff_words = h_diff_accumulated >> 1;
    if (h_diff_words)
    {
        render_column(rb);

        h_diff_accumulated -= h_diff_words << 1;
    }

    vdp_vsync_wait(1);
    vdp_swap_frame_buffer();

    copy_line_table();

    // Copy frame buffer line to top
    if (buffer_wrap)
    {
        copy_line(MARS_FRAMEBUFFER + 256 + 164 * 256, MARS_FRAMEBUFFER + 256);
    }

    rb = render_buffer;

    // Render new lines
    for (u32 i = 0; i < lines; i++)
    {
        u16 offset = *rb++;
        rb = copy_line(rb, MARS_FRAMEBUFFER + offset);
    }

    // Render new column
    if (h_diff_words)
    {
        volatile u16* frame_buffer_base = MARS_FRAMEBUFFER + 160;
        u16* line_offset = line_table_buffer;
        for (u32 y = 0; y < 224; y++)
        {
            frame_buffer_base[*line_offset++] = *rb++;
        }
    }
    vdp_swap_frame_buffer();

    MARS_VDP_SHIFTREG = horizontal_scroll;
}


static void load_map(map_load_parameters* load_parameters)
{
    map_definition = HINT_ALIGN(md_map_table[load_parameters->map_index], 4);

    if (map_definition)
    {
        //SH2_CACHE_PURGE;

        u32* map_base = (u32*) UNCACHED(&_free_ram_start);

        u32* target = map_base;
        u32 const* source = map_definition->data;
        for (u32 i = 0; i < map_definition->data_size; i++)
        {
            *target++ = *source++;
        }

        line_table_buffer = (u16*) CACHED(target);
        render_buffer = (u16*) CACHED(target + 128);

        map.width    = map_definition->width;
        map.height   = map_definition->height;
        map.tile_map = (u16*) (map_base + map_definition->tile_map_offset);
        map.blocks   = (block*) (map_base + map_definition->blocks_offset);
        for (u32 i = 0; i < 4; i++)
        {
            palettes[i] = (map_palette*) (map_base + map_definition->palette_offsets[i]);
        }

        vertical_scroll = load_parameters->vertical_scroll << 4;
        horizontal_scroll = load_parameters->horizontal_scroll << 4;

        render_buffer_slope = 328 - horizontal_scroll;
        h_diff_accumulated = 0;

        // Set initial palette
        pal_replace(PAL_CURRENT, 0, palettes[0]->color_count, palettes[0]->colors);
        pal_commit();

        // Render initial frame
        render_full();
    }
}


static void process(u32 command_id, u16* param_base)
{
    u32 action_id = command_id & 0xff;

    switch (action_id)
    {
        case CMD_MAP_LOAD:
            load_map((map_load_parameters*) param_base);
            break;

        case CMD_MAP_RESET:
            {
                map_reset_parameters* reset_parameters = (map_reset_parameters*) param_base;

                horizontal_scroll = reset_parameters->horizontal_scroll;
                vertical_scroll = reset_parameters->vertical_scroll;

                render_full();
            }
            break;
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

                scroll(scroll_parameters->horizontal_scroll, scroll_parameters->vertical_scroll);
            }
            break;

        case CMD_MAP_PALETTE:
            {
                map_palette_parameters* palette_parameters = (map_palette_parameters*) param_base;
                map_palette const* palette = palettes[palette_parameters->palette_index];

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
