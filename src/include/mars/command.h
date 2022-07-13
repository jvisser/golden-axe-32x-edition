/*
 * Command structure used to handle commands received from the MD.
 */

#ifndef __COMMAND_H__
#define __COMMAND_H__

#include "types.h"


typedef void (*command_handler)(u16* param_base, u32 command_id);
typedef void (*command_post_handler)(u32 command_id);

typedef struct
{
    command_handler      process;               // All procesing that requires ROM access must be done here!
    command_post_handler post_process;
} command;


extern void command_main(volatile u16* comm_base);


// Main commands
#define CMD_ID_DISPLAY              0x01
#define CMD_ID_IMAGE                0x02
#define CMD_ID_PALETTE              0x03

// Sub commands
#define CMD_DISPLAY_ENABLE          0x00
#define CMD_DISPLAY_DISABLE         0x01
#define CMD_DISPLAY_SWAP            0x02

#define CMD_ID_IMAGE_PAL0           0x00
#define CMD_ID_IMAGE_PAL1           0x01

#define CMD_PALETTE_FILL            0x00
#define CMD_PALETTE_FILL_PAL0       0x00
#define CMD_PALETTE_FILL_PAL1       0x01
#define CMD_PALETTE_LOAD            0x02
#define CMD_PALETTE_LOAD_PAL0       0x02
#define CMD_PALETTE_LOAD_PAL1       0x03
#define CMD_PALETTE_COMMIT          0x04
#define CMD_PALETTE_TRANSITION      0x06


typedef struct
{
    u8  offset;
    u8  count;
    u16 color;
} palette_fill_parameters;


#endif
