/*
 * Command processing main loop
 */

#include "command.h"

extern command CMD_DISPLAY;
extern command CMD_IMAGE;
extern command CMD_PALETTE;
extern command CMD_VERTICAL_SCROLL;
extern command CMD_MAP;


static command* commands[] =
{
    &CMD_DISPLAY,
    &CMD_IMAGE,
    &CMD_PALETTE,
    &CMD_VERTICAL_SCROLL,
    &CMD_MAP
};


void command_main(volatile u16* comm_base)
{
    volatile u16* comm0 = comm_base;
    volatile u16* comm1 = comm_base + 1;
    volatile u32* param = (u32*)(comm_base + 4);

    u32 command_param;

    while (1)
    {
        // Wait for command from the MD
        u16 command_id;
        while (!(command_id = *comm0));

        // Copy parameters
        command_param = *param;

        // Get command handler
        command* command = commands[(command_id >> 8) - 1];

        // Run command main task
        command->process(command_id, (u16*) &command_param);

        // Send ready signal to MD
        *comm1 = command_id;

        // Wait for ACK from MD
        while (*comm0);

        // Run post command tasks
        command->post_process(command_id, (u16*) &command_param);
    }
}
