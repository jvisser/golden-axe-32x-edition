/*
 * Image command
 *
 * Load and display the specified image
 *
 * Parameters:
 * - COMM4L: ROM offset of the compressed image data
 */

#include "mars.h"
#include "vdp.h"
#include "command.h"
#include "comper.h"


static void process();
static void post_process();


md_command CMD_IMAGE =
{
    process,
    post_process
};


static void reset_line_table()
{
    u16 offset = 256;
    for (u32 i = 0; i < 224; i++)
    {
        MARS_FRAMEBUFFER[i] = offset;
        offset += 160;
    }
}


static void process()
{
    // Disable display
    vdp_set_display_mode(DISPLAY_MODE_BLANK);

    u16* palette = (u16*) (MARS_ROM + MARS_COMM4L);
    u16 color_count = *palette++;
    u16* pixel_data = palette + color_count;

    // Compress directly into the framebuffer
    comper_decompress(pixel_data, (MARS_FRAMEBUFFER + 256));

    reset_line_table();

    vdp_update_palette(palette, 0, color_count);
}


static void post_process()
{
    // Set framebuffer to the front
    vdp_swap_frame_buffer();

    // Enable display
    vdp_set_display_mode(DISPLAY_MODE_PACKED);
}
