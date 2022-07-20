/*
 * Image command
 *
 * Load and display the specified image
 */

#include "mars.h"
#include "command.h"
#include "comper.h"
#include "noop.h"
#include "palette.h"


static void process(u32 command_id, u16* image_data_address);


command CMD_IMAGE =
{
    process,
    no_operation
};


static void reset_line_table(void)
{
    u16 offset = 256;
    for (u32 i = 0; i < 224; i++)
    {
        MARS_FRAMEBUFFER[i] = offset;
        offset += 160;
    }
}


static void process(u32 command_id, u16* image_data_address)
{
    u16* palette = (u16*) ROM_ADDR(*(u32*)image_data_address);
    u16  color_count = *palette++;
    u16* pixel_data = palette + color_count;

    pal_replace(command_id & 0xff, 0, color_count, palette);

    reset_line_table();

    comper_decompress(pixel_data, (MARS_FRAMEBUFFER + 256)); // Decompress directly into the framebuffer
}
