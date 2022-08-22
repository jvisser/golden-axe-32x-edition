/*
 * Command structure used to handle commands received from the MD.
 */

#ifndef __COMMAND_H__
#define __COMMAND_H__

#include "types.h"


typedef void (*command_handler)(u32 command_id, u16* param_base);

typedef struct
{
    command_handler process;        // All procesing that requires ROM access must be done here!
    command_handler post_process;
} command;


extern void command_main(volatile u16* comm_base);


// Main commands
#define CMD_ID_DISPLAY              0x01
#define CMD_ID_IMAGE                0x02
#define CMD_ID_PALETTE              0x03
#define CMD_ID_VERTICAL_SCROLL      0x04
#define CMD_ID_MAP                  0x05


// Sub commands
#define CMD_DISPLAY_ENABLE          0x00
#define CMD_DISPLAY_DISABLE         0x01
#define CMD_DISPLAY_SWAP            0x02

#define CMD_ID_IMAGE_PAL0           0x00    // Current palette
#define CMD_ID_IMAGE_PAL1           0x01    // Target palette

#define CMD_PALETTE_FILL            0x00
#define CMD_PALETTE_FILL_PAL0       0x00
#define CMD_PALETTE_FILL_PAL1       0x01
#define CMD_PALETTE_LOAD            0x02
#define CMD_PALETTE_LOAD_PAL0       0x02
#define CMD_PALETTE_LOAD_PAL1       0x03
#define CMD_PALETTE_COMMIT          0x04
#define CMD_PALETTE_TRANSITION      0x06
#define CMD_PALETTE_SUBTRACT        0x08
#define CMD_PALETTE_COPY            0x0a
#define CMD_PALETTE_COPY_PAL0       0x0a
#define CMD_PALETTE_COPY_PAL1       0x0b

typedef struct
{
    u8  offset;
    u8  count;
    u16 color;
} palette_parameters;

#define CMD_MAP_LOAD                0x00
#define CMD_MAP_SCROLL              0x01
#define CMD_MAP_PALETTE             0x02
#define CMD_MAP_RESET               0x03

typedef struct
{
    u8  vertical_scroll;
    u8  horizontal_scroll;
    u16 map_index;
} map_load_parameters;

typedef struct
{
    u16  vertical_scroll;
    u16  horizontal_scroll;
} map_scroll_parameters;

typedef struct
{
    u8  transition;
    u8  palette_index;
} map_palette_parameters;

typedef struct
{
    u16  vertical_scroll;
    u16  horizontal_scroll;
} map_reset_parameters;

#endif
