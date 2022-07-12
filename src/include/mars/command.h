/*
 * Command structure used to handle commands received from the MD.
 */

#ifndef __COMMAND_H__
#define __COMMAND_H__

#include "types.h"


typedef void (*command_handler)(u16* param_base);
typedef void (*command_post_handler)(void);

typedef struct
{
    command_handler      process;               // All procesing that requires ROM access must be done here!
    command_post_handler post_process;
} command;


extern void command_main(volatile u16* comm_base);


#define CMD_ID_DISPLAY          0x01
// Sub commands
#define CMD_DISPLAY_ENABLE      0x00
#define CMD_DISPLAY_DISABLE     0x01
#define CMD_DISPLAY_SWAP        0x02

typedef struct
{
    u16 sub_command;
} display_command_parameters;


#define CMD_ID_IMAGE            0x02

typedef struct
{
    u32 palette_id      : 8;                    // PAL_BASE or PAL_TARGET
    u32 data_address    : 24;
} image_command_parameters;


#define CMD_ID_PALETTE          0x03
// Sub commands
#define CMD_PALETTE_FILL        0x00
#define CMD_PALETTE_LOAD        0x01
#define CMD_PALETTE_COMMIT      0x02
#define CMD_PALETTE_TRANSITION  0x03

typedef struct
{
    u32 sub_command     : 4;
    u32 palette_id      : 4;                    // PAL_BASE or PAL_TARGET
    u32 data            : 24;
} palette_command_parameters;


#endif
