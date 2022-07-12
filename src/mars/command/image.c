/*
 * Image command
 *
 * Load and display the specified image
 *
 * Parameters:
 * - COMM4L: ROM offset of the compressed image data
 */

#include "mars.h"
#include "command.h"
#include "comper.h"
#include "noop.h"
#include "palette.h"


static void process(u16* param_base);


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


static void process(u16* param_base)
{
    image_command_parameters* parameters = (image_command_parameters*) param_base;

    u16* palette = (u16*) ROM_ADDR(parameters->data_address);
    u16  color_count = *palette++;
    u16* pixel_data = palette + color_count;

    reset_line_table();

    comper_decompress(pixel_data, (MARS_FRAMEBUFFER + 256)); // Decompress directly into the framebuffer

    pal_replace(parameters->palette_id, palette, 0, color_count);
}
